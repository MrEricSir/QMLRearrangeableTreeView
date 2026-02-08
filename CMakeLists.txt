cmake_minimum_required(VERSION 3.16)
project(QMLRearrangeableTreeView LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)
qt_policy(SET QTP0001 NEW)

qt_add_library(rearrangeabletreeview STATIC)

qt_add_qml_module(rearrangeabletreeview
    URI RearrangeableTreeView
    VERSION 1.0
    OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/RearrangeableTreeView"
    QML_FILES RearrangeableDelegate.qml
)

target_link_libraries(rearrangeabletreeview PUBLIC Qt6::Quick)

if(CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
    set(_default_examples ON)
else()
    set(_default_examples OFF)
endif()
option(BUILD_EXAMPLES "Build example applications" ${_default_examples})

if(BUILD_EXAMPLES)
    add_subdirectory(examples/cpp_demo)
endif()
