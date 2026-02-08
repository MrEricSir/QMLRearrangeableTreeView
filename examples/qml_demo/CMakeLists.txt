qt_add_executable(qml_demo main.cpp)

qt_add_resources(qml_demo "qml_files"
    PREFIX "/"
    FILES
        ../../QMLRearrangeableTreeView.qml
        ../../RearrangeableDelegate.qml
        ../../opener.png
)

target_link_libraries(qml_demo PRIVATE Qt6::Quick)
