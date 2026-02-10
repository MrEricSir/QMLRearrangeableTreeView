#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "TreeModel.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;

    TreeModel model;

    // Sample data.
    model.addItem({1, "All Items", false, -1, true, "none", false});
    model.addItem({2, "two",       false, -1, true, "none", true});
    model.addItem({3, "three",     false, -1, true, "none", true});
    model.addItem({4, "four",      false, -1, true, "none", true});
    model.addItem({5, "five",      false, -1, true, "none", true});
    model.addItem({6, "six",       false, -1, true, "none", true});
    model.addItem({7, "seven",     false, -1, true, "none", true});
    model.addItem({8, "eight",     false, -1, true, "none", true});
    model.addItem({9, "nine",      false, -1, true, "none", true});

    engine.rootContext()->setContextProperty("treeModel", &model);
    engine.rootContext()->setContextProperty("appTitle", "QML Rearrangeable Tree View (C++ Model)");
    engine.rootContext()->setContextProperty("appOpenerImage", QStringLiteral("qrc:/opener.png"));

    // Add the project root to the import path and load main.qml from there.
    engine.addImportPath(QStringLiteral(PROJECT_ROOT));
    engine.load(QUrl::fromLocalFile(QStringLiteral(PROJECT_ROOT "/main.qml")));

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}
