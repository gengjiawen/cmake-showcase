cmake_minimum_required(VERSION 3.17)
project(macro_out)

if(MSVC)
  set(CMAKE_CXX_FLAGS "/Zc:__cplusplus")
endif()

add_executable(macro_out main.cpp)
