#include <boost/stacktrace.hpp>
#include <iostream>

void function() {
  auto s = boost::stacktrace::stacktrace();
  std::cout << s;
  std::cout << "done";
}

int main() {
  function();
  return 0;
}