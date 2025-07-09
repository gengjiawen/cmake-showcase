#define _XOPEN_SOURCE 600 // Needed for posix_openpt on some systems
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <sys/wait.h>

#if defined(__linux__)
#include <pty.h>          // For openpty/forkpty on Linux
#include <sys/epoll.h>    // For epoll I/O multiplexing on Linux
#else
#include <util.h> // For openpty/forkpty on BSD/macOS
#endif

int main() {
    int master_fd;
    char *slave_name;
    pid_t pid;

    // 1. Create a PTY Master/Slave pair
    // O_RDWR: Read and write
    // O_NOCTTY: Prevent the PTY from becoming the controlling terminal of this process
    master_fd = posix_openpt(O_RDWR | O_NOCTTY);
    if (master_fd == -1) {
        perror("posix_openpt failed");
        return 1;
    }

    // 2. Grant permissions and unlock the slave side
    if (grantpt(master_fd) == -1) {
        perror("grantpt failed");
        close(master_fd);
        return 1;
    }
    if (unlockpt(master_fd) == -1) {
        perror("unlockpt failed");
        close(master_fd);
        return 1;
    }

    // 3. Obtain the device name of the slave side
    slave_name = ptsname(master_fd);
    if (slave_name == NULL) {
        perror("ptsname failed");
        close(master_fd);
        return 1;
    }

    printf("Master: PTY Master is on fd %d\n", master_fd);
    printf("Master: PTY Slave is at %s\n", slave_name);

    // 4. fork() to create a child process
    pid = fork();
    if (pid == -1) {
        perror("fork failed");
        close(master_fd);
        return 1;
    }

    // ====================================================================
    // Child process (Slave) logic
    // ====================================================================
    if (pid == 0) {
        int slave_fd;

        // The child process does not need the master file descriptor
        close(master_fd);

        // Create a new session and make the child the session leader
        // This is required to make it the controlling terminal
        if (setsid() == -1) {
            perror("Child: setsid failed");
            exit(1);
        }

        // Open the PTY slave end
        // This sets the PTY as the controlling terminal for this process
        slave_fd = open(slave_name, O_RDWR);
        if (slave_fd == -1) {
            perror("Child: open slave failed");
            exit(1);
        }

        printf("Child: Slave opened at %s\n", slave_name);

        // Redirect the child's stdin, stdout, and stderr to the PTY slave
        // dup2 automatically closes the first argument (0, 1, 2) and then duplicates slave_fd
        dup2(slave_fd, STDIN_FILENO);   // fd 0
        dup2(slave_fd, STDOUT_FILENO);  // fd 1
        dup2(slave_fd, STDERR_FILENO);  // fd 2

        // After redirection, the original slave_fd is no longer needed
        close(slave_fd);

        // Replace the current child process with a new shell
        // The shell will inherit the redirected standard streams
        printf("Child: Starting shell...\n");
        execlp("/bin/bash", "bash", NULL);

        // If execlp succeeds, the code below will not be executed
        perror("Child: execlp failed");
        exit(1);
    }

    // ====================================================================
    // Parent process (Master) logic
    // ====================================================================
    else {
        char buffer[256];
        ssize_t bytes_read;

        printf("Parent: Child process created with PID %d\n", pid);

        // Wait briefly to ensure the child's shell has started
        sleep(1);

        // 5. Master writes commands to the slave
        const char *command = "echo 'Hello from the Slave Shell!'\nls -l\nexit\n";
        printf("Parent (Master): Writing command to slave: \n---\n%s---\n", command);
        write(master_fd, command, strlen(command));

        // 6. Master reads output from the slave (blocking read)
        printf("Parent (Master): Reading output from slave:\n---\n");

        while ((bytes_read = read(master_fd, buffer, sizeof(buffer) - 1)) > 0) {
            buffer[bytes_read] = '\0';
            printf("%s", buffer);
            fflush(stdout); // Flush to display output immediately
        }

        if (bytes_read == -1) {
            perror("read from master_fd failed");
        }

        printf("---\n");


        // Wait for the child process to exit
        waitpid(pid, NULL, 0);

        // Close the master file descriptor
        close(master_fd);
    }

    return 0;
}
