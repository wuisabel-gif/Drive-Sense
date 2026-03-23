cmake_minimum_required(VERSION 3.16)
project(DriveSense LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

add_executable(drivesense
    src/main.cpp
    src/parser.cpp
    src/analyzer.cpp
)

target_include_directories(drivesense PRIVATE include)
