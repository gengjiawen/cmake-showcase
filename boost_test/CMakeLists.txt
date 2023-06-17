cmake_minimum_required(VERSION 3.25)
project(boost_test)

set(CMAKE_CXX_STANDARD 23)

include(${CMAKE_BINARY_DIR}/conanbuildinfo.cmake)
conan_basic_setup()

find_package(Boost REQUIRED COMPONENTS stacktrace_basic)

add_executable(boost_test main.cpp)
target_link_libraries(boost_test ${CONAN_LIBS})

