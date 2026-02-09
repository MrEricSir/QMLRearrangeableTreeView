import QtQuick
import QtQuick.Controls
import RearrangeableTreeView

ApplicationWindow {
    id: app;
    title: "QML Rearrangeable Tree View (C++ Model)";
    width: 400;
    height: 480;
    visible: true;
    color: "#eee";

    // The delegate calls insertFolder(index) via scope resolution.
    // We forward it to the C++ model.
    function insertFolder(index) {
        return treeModel.insertFolder(index);
    }

    ScrollView {
        id: scrollView;
        anchors.top: parent.top;
        anchors.right: parent.right;
        anchors.left: parent.left;
        anchors.bottom: bottomToolbar.top;

        ListView {
            id: treeView

            interactive: height < childrenRect.height

            delegate: TitleDelegate {
                qmlListModel: false;
                numStationary: bottomToolbar.numStationary;
                scaleFactor: bottomToolbar.scaleFactor;
                openerImage: "qrc:/opener.png";
            }

            model: treeModel;

            displaced: Transition {
                NumberAnimation { properties: "x,y"; duration: 50 }
            }
        }
    }

    BottomToolbar {
        id: bottomToolbar;

        numRows: treeView.count;

        anchors.right: parent.right;
        anchors.left: parent.left;
        anchors.bottom: parent.bottom;
        anchors.bottomMargin: 10;
        anchors.leftMargin: 10;
        anchors.rightMargin: 10;
    }
}
