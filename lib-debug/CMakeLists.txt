cmake_minimum_required(VERSION 3.17)
project(a_out)

if(NOT CMAKE_CXX_STANDARD)
  set(CMAKE_CXX_STANDARD 17)
endif()

# set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fsanitize=address -g -O0")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -g -O0")

add_library(hello STATIC stack-buffer.cpp)
target_include_directories(hello PUBLIC ${PROJECT_SOURCE_DIR})

add_library(world SHARED world.cpp)
target_link_libraries(world PUBLIC hello)

add_executable(a_out main.cpp)

target_link_libraries(a_out PRIVATE world)

message(
  STATUS
    "summary of uvwasi build options:
    Target system:   ${CMAKE_SYSTEM_NAME}
    Compiler:
      C compiler:    ${CMAKE_C_COMPILER}
      CFLAGS:        ${CMAKE_CXX_FLAGS}
")
