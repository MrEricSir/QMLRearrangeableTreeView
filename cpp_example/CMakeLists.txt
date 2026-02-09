qt_add_executable(cpp_demo
    main.cpp
    TreeModel.h
    TreeModel.cpp
)

qt_add_qml_module(cpp_demo
    URI CppDemo
    VERSION 1.0
    QML_FILES Main.qml
)

set_source_files_properties(../opener.png PROPERTIES QT_RESOURCE_ALIAS opener.png)
qt_add_resources(cpp_demo "shared_resources"
    PREFIX "/"
    FILES ../opener.png
)

target_link_libraries(cpp_demo PRIVATE rearrangeabletreeview rearrangeabletreeviewplugin)
