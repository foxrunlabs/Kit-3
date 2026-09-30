cmake_minimum_required(VERSION 3.17)

project(kit3 VERSION 0.1 LANGUAGES CXX)

find_package(verilator REQUIRED)
find_package(SFML 2.5 COMPONENTS graphics REQUIRED)

add_executable(Vkit3)

set(VERILOG ../../hdl/kit3.v ../../hdl/vram.v ../../hdl/display.v ../../hdl/ALU.v ../../hdl/cpu_65c02.v ../../hdl/ram.v)
verilate(Vkit3 SOURCES ${VERILOG} TOP_MODULE kit3 PREFIX Vkit3 TRACE)

set_target_properties(Vkit3 PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")
target_sources(Vkit3 PRIVATE main.cpp Kit3.hpp Kit3.cpp)
target_compile_features(Vkit3 PRIVATE cxx_std_17)
target_compile_options(Vkit3 PRIVATE -W -Wall)
target_link_libraries(Vkit3 PRIVATE nexys4ddr sfml-system sfml-window sfml-graphics)

install(TARGETS Vkit3 DESTINATION bin)
