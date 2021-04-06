
```bash
mkdir build && cd build
cmake -DCMAKE_TOOLCHAIN_FILE=../toolchains/arm-linux-gnueabi.toolchain.cmake ..
cmake --build .
qemu-arm -L /usr/arm-linux-gnueabi ./hello_as
```