import QtQuick
import QtQuick.Controls
import RearrangeableTreeView

ApplicationWindow {
    id: app;
    title: typeof appTitle !== "undefined" ? appTitle : "QML Rearrangeable Tree View";
    width: 400;
    height: 480;
    visible: true;
    color: "#eee";

    QMLRearrangeableTreeView {
        id: rearrangeableTreeView;

        model: typeof treeModel !== "undefined" ? treeModel : null;
        openerImage: typeof appOpenerImage !== "undefined" ? appOpenerImage : "opener.png";
        numStationary: bottomToolbar.numStationary;
        scaleFactor: bottomToolbar.scaleFactor;

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
