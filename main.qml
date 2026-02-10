import QtQuick
import QtQuick.Controls
import RearrangeableTreeView

ApplicationWindow {
    id: app;
    title: typeof appTitle !== "undefined" ? appTitle : "QML Rearrangeable Tree View";
    width: 500;
    height: 480;
    visible: true;
    color: "#ccc";

    Rectangle {
        anchors.fill: parent;
        anchors.margins: 15;
        color: "#eee";

        QMLRearrangeableTreeView {
            id: rearrangeableTreeView;

            model: typeof treeModel !== "undefined" ? treeModel : null;
            numStationary: bottomToolbar.numStationary;
            scaleFactor: bottomToolbar.scaleFactor;
            folderIndent: bottomToolbar.folderIndent;
            folderMargin: bottomToolbar.folderMargin;

            anchors.top: parent.top;
            anchors.right: parent.right;
            anchors.left: parent.left;
            anchors.bottom: bottomToolbar.top;
        }

        BottomToolbar {
            id: bottomToolbar;

            numRows: rearrangeableTreeView.numRows;

            anchors.right: parent.right;
            anchors.left: parent.left;
            anchors.bottom: parent.bottom;
            anchors.bottomMargin: 10;
            anchors.leftMargin: 10;
            anchors.rightMargin: 10;
        }
    }
}
