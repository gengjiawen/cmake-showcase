#include <boost/stacktrace.hpp>

void function() {
  std::cout << boost::stacktrace::stacktrace();
}

int main() {
  function();
  return 0;
}