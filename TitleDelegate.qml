import QtQuick
import QtQuick.Controls

RearrangeableDelegate {
    id: titleDelegate;

    property real scaleFactor: 1.0;

    openerImage: "opener.png";
    openerOffsetX: 5;
    openerOffsetY: 2;
    openerAnimationDuration: 250;

    dragOnLongPress: false;

    dragEnabled: draggable;

    color: index == ListView.view.currentIndex ? "#fff" : "transparent";

    visible: isFolder ? true : (parentFolder == -1 || folderOpen ? true : false);
    height: visible ? Math.round(30 * scaleFactor) : 0;

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

    Row {

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
