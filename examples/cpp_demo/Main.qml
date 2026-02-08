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

    // Scale factor for DPI awareness.
    property real scaleFactor: 1.0;

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
        anchors.bottom: bottomRow.top;

        ListView {
            id: treeView

            interactive: height < childrenRect.height

            delegate: RearrangeableDelegate {
                id: titleDelegate

                // Use C++ model API.
                qmlListModel: false;

                ListView.onIsCurrentItemChanged: {
                    if (ListView.isCurrentItem) {
                        console.log("item selected")
                    }
                }

                color: index == treeView.currentIndex ? "#fff" : "transparent";

                numStationary: spinbox.value;

                dragEnabled: draggable;

                openerImage: Qt.resolvedUrl("opener.png");
                openerOffsetX: 5;
                openerOffsetY: 2;
                openerAnimationDuration: 250;

                dragOnLongPress: false;

                onClicked: (mouse) => {
                    if (mouse.button === Qt.LeftButton) {
                        treeView.currentIndex = index;
                    } else if (mouse.button === Qt.RightButton) {
                        contextMenu.popup();
                    }
                }

                onDoubleClicked: (mouse) => {
                    console.log("double click on: " + title);
                }

                onOrderChanged: {
                    console.log("order changed")
                }

                visible: isFolder ? true : (parentFolder == -1 || folderOpen ? true : false);
                height: visible ? Math.round(30 * app.scaleFactor) : 0;

                Menu {
                    id: contextMenu;

                    MenuItem {
                        text: "Rename";
                        onTriggered: console.log("Rename: " + title);
                    }

                    MenuItem {
                        text: "Remove";
                        visible: draggable;
                        height: visible ? implicitHeight : 0;
                        onTriggered: console.log("Remove: " + title);
                    }
                }

                Row {

                    Text {
                        id: itemName;

                        text: title + (index < titleDelegate.numStationary ? " [stationary]" : "")
                              + (!draggable ? " [fixed]" : "");

                        width: 200
                        height: Math.round(30 * app.scaleFactor)

                        font.pointSize: Math.round(12 * app.scaleFactor)

                        elide: Text.ElideRight;
                    }

                    Text {
                        id: itemUID;

                        text: uid;

                        width: 40
                        height: Math.round(30 * app.scaleFactor)

                        color: "gray"

                        font.pointSize: Math.round(12 * app.scaleFactor)

                        elide: Text.ElideRight;
                    }

                    Text {
                        id: itemParentUID;

                        text: parentFolder;

                        width: 40
                        height: Math.round(30 * app.scaleFactor)

                        color: "gray"

                        font.pointSize: Math.round(12 * app.scaleFactor)

                        elide: Text.ElideRight;
                    }
                }
            }

            model: treeModel;

            displaced: Transition {
                NumberAnimation { properties: "x,y"; duration: 50 }
            }
        }
    }

    Row {
        id: bottomRow;

        anchors.right: parent.right;
        anchors.left: parent.left;
        anchors.bottom: parent.bottom;
        anchors.bottomMargin: 10;
        anchors.leftMargin: 10;
        anchors.rightMargin: 10;

        spacing: 20;

        Text {
            text: "Stationary items:";
            verticalAlignment: Text.AlignVCenter;
            height: parent.height;
        }

        SpinBox {
            id: spinbox;
            width: 50;

            value: 0;
        }

        Text {
            text: "Scale:";
            verticalAlignment: Text.AlignVCenter;
            height: parent.height;
        }

        Slider {
            id: scaleSlider;
            width: 100;
            from: 0.5;
            to: 2.0;
            value: 1.0;

            onValueChanged: app.scaleFactor = value;
        }
    }
}
