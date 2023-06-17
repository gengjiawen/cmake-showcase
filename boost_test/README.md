##  setup

```bash
conan install . --build missing -if build
cmake -S ./ -B ./build
```