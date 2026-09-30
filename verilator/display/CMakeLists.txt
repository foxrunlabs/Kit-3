cmake_minimum_required(VERSION 3.17)

project(display VERSION 0.1 LANGUAGES CXX)

find_package(verilator REQUIRED)

add_executable(Vdisplay)

set(VERILOG ../../hdl/display.v)
verilate(Vdisplay SOURCES ${VERILOG} TOP_MODULE display PREFIX Vdisplay TRACE)

set_target_properties(Vdisplay PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")
target_sources(Vdisplay PRIVATE main.cpp Display.hpp Display.cpp)
target_compile_features(Vdisplay PRIVATE cxx_std_17)
target_compile_options(Vdisplay PRIVATE -W -Wall)
target_link_libraries(Vdisplay PRIVATE nexys4ddr)

install(TARGETS Vdisplay DESTINATION bin)
