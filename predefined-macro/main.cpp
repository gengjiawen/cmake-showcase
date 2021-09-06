#include <iostream>

int main() {
  auto b = __cplusplus;
  std::cout << "cpplus: " << b << std::endl;
#if defined(_MSC_VER)
  auto c = _MSC_VER;
  std::cout << "ms version: " << c << std::endl;
#endif
}