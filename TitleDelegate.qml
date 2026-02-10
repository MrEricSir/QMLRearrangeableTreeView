import QtQuick
import QtQuick.Controls

RearrangeableDelegate {
    id: titleDelegate;

    property real scaleFactor: 1.0;

    // Opener style.
    property url openerImage: "opener.png";
    property real openerOffsetX: 5;
    property real openerOffsetY: 2;
    property int openerAnimationDuration: 250;

    toggleAreaWidth: isFolder ? Math.round(30 * scaleFactor) : 0;

    dragOnLongPress: false;

    dragEnabled: draggable;

    color: index == ListView.view.currentIndex ? "#fff" : "transparent";

    visible: isFolder ? true : (parentFolder == -1 || folderOpen ? true : false);
    height: visible ? Math.round(30 * scaleFactor) + _folderTopMargin + _folderBottomMargin : 0;

    ListView.onIsCurrentItemChanged: {
        if (ListView.isCurrentItem) {
            console.log("item selected");
        }
    }

    onClicked: (mouse) => {
        if (mouse.button === Qt.LeftButton) {
            ListView.view.currentIndex = index;
        } else if (mouse.button === Qt.RightButton) {
            contextMenu.popup();
        }
    }

    onDoubleClicked: (mouse) => {
        console.log("double click on: " + title);
    }

    onOrderChanged: {
        console.log("order changed");
    }

    Menu {
        id: contextMenu;

        MenuItem {
            text: "Rename";
            onTriggered: console.log("[Demo] Rename: " + title);
        }

        MenuItem {
            text: "Remove";
            visible: draggable;
            height: visible ? implicitHeight : 0;
            onTriggered: console.log("[Demo] Remove: " + title);
        }
    }

    Item {
        id: opener;

        visible: isFolder;

        width: titleDelegate.toggleAreaWidth;
        height: Math.round(30 * titleDelegate.scaleFactor);

        Image {
            id: openerIcon;

            source: titleDelegate.openerImage;
            x: titleDelegate.openerOffsetX;
            y: titleDelegate.openerOffsetY;

            width: sourceSize.width;
            height: sourceSize.height;

            fillMode: Image.PreserveAspectCrop;
            asynchronous: true;

            states: [
                State { name: "open"; },
                State { name: "closed"; }
            ]

            state: folderOpen ? "open" : "closed";

            Component.onCompleted: {
                if (!folderOpen) {
                    rotation = -90;
                }
            }

            transitions: [
                Transition {
                    from: "*";
                    to: "closed";
                    RotationAnimation {
                        running: false;
                        direction: RotationAnimation.Counterclockwise;

                        target: openerIcon;
                        to: -90;
                        duration: titleDelegate.openerAnimationDuration;

                        // Supress warning message.
                        property: "rotation";
                    }
                },
                Transition {
                    from: "*";
                    to: "open";
                    RotationAnimation {
                        running: false;
                        direction: RotationAnimation.Clockwise;

                        target: openerIcon;
                        to: 0;
                        duration: titleDelegate.openerAnimationDuration;

                        // Supress warning message.
                        property: "rotation";
                    }
                }
            ]
        }

        MouseArea {
            anchors.fill: parent;
            onClicked: (mouse) => {
                toggleFolder();
            }
        }
    }

    Row {
        anchors.left: opener.right;

        Text {
            id: itemName;

            text: title + (index < titleDelegate.numStationary ? " [stationary]" : "")
                  + (!draggable ? " [fixed]" : "");

            width: 200;
            height: Math.round(30 * titleDelegate.scaleFactor);

            font.pointSize: Math.round(12 * titleDelegate.scaleFactor);

            verticalAlignment: Text.AlignVCenter;
            elide: Text.ElideRight;
        }

        Text {
            id: itemUID;

            text: uid;

            width: 40;
            height: Math.round(30 * titleDelegate.scaleFactor);

            color: "gray";

            font.pointSize: Math.round(12 * titleDelegate.scaleFactor);

            verticalAlignment: Text.AlignVCenter;
            elide: Text.ElideRight;
        }

        Text {
            id: itemParentUID;

            text: parentFolder;

            width: 40;
            height: Math.round(30 * titleDelegate.scaleFactor);

            color: "gray";

            font.pointSize: Math.round(12 * titleDelegate.scaleFactor);

            verticalAlignment: Text.AlignVCenter;
            elide: Text.ElideRight;
        }
    }
}
