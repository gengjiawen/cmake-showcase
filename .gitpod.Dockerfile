FROM gitpod/workspace-full

# Install custom tools, runtimes, etc.
# For example "bastet", a command-line tetris clone:
# RUN brew install bastet
#
# More information: https://www.gitpod.io/docs/config-docker/
RUN sudo apt update && sudo apt install gcc-arm-linux-gnueabihf g++-arm-linux-gnueabi qemu qemu-user -y

RUN echo "fish" >> ~/.bashrc