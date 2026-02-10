qt_add_executable(cpp_demo
    main.cpp
    TreeModel.h
    TreeModel.cpp
)

# Point the QML engine at the project root so it can find main.qml and
# the RearrangeableTreeView/qmldir module for local development.
target_compile_definitions(cpp_demo PRIVATE
    PROJECT_ROOT="${CMAKE_SOURCE_DIR}"
)

set_source_files_properties(../opener.png PROPERTIES QT_RESOURCE_ALIAS opener.png)
qt_add_resources(cpp_demo "shared_resources"
    PREFIX "/"
    FILES ../opener.png
)

target_link_libraries(cpp_demo PRIVATE rearrangeabletreeview)
