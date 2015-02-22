import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2

ApplicationWindow {
    id: app;
    title: "QML Rearrangeable Tree View";
    width: 400;
    height: 480;
    color: "#eee";

    // This is used for generating UIDs for folders. This method is simplistic
    // and isn't intended for production code.
    property int uid: 10;
    function uidNext() {
        return ++uid;
    }

    ListView {
        id: treeView
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.bottom: bottomRow.top

        // Only enable scrolling if there's a need.
        interactive: height < childrenRect.height

        delegate: RearrangeableDelegate {
            id: titleDelegate

            ListView.onIsCurrentItemChanged: {
                if (ListView.isCurrentItem) {
                    console.log("item selected")
                }
            }

            color: index == treeView.currentIndex ? "#fff" : "transparent";

            // This sets the number of items at the top of the list that can never be reordered
            // or put into folders.
            numStationary: spinbox.value;

            // Style the opener.
            openerImage: "opener.png";
            openerOffsetX: 5;
            openerOffsetY: 2;
            openerAnimationDuration: 250;

            // Don't require a long-press to begin drag. (Set to true for mobile, touchscreens, etc.)
            dragOnLongPress: true;

            onClicked: {
                console.log("on click")
                treeView.currentIndex = index;
            }

            onOrderChanged: {
                console.log("order changed")
            }

            width: parent.width

            // Folders are always visible, but their children are not.
            visible: isFolder ? true : (parentFolder == -1 || folderOpen ? true : false);
            height: visible ? 30 : 0

            // Draw the opener, title in a row with uid and parentUID (for debugging)
            Row {

                Text {
                    id: itemName;

                    text: name + (index < titleDelegate.numStationary ? " [stationary]" : "");

                    width: 200
                    height: 30

                    font.pointSize: 12
                    font.family: "Segoe UI"
                    renderType: Text.NativeRendering;

                    elide: Text.ElideRight;
                }

                Text {
                    id: itemUID;

                    text: uid;

                    width: 40
                    height: 30

                    color: "gray"

                    font.pointSize: 12
                    font.family: "Segoe UI"
                    renderType: Text.NativeRendering;

                    elide: Text.ElideRight;
                }

                Text {
                    id: itemParentUID;

                    text: parentFolder;

                    width: 40
                    height: 30

                    color: "gray"

                    font.pointSize: 12
                    font.family: "Segoe UI"
                    renderType: Text.NativeRendering;

                    elide: Text.ElideRight;
                }
            }
        }

        // Some sample data.  This also demonstrates the required properties and their data types.
        model: ListModel {
            id: sampleList

            ListElement {
                name: "one";

                // Required:
                uid: 1;              // Unique id (integer)
                dropTarget: "none";  // Used for drag and drop UI. (Persistence not required.)
                isFolder: false;     // True if a folder, else false
                parentFolder: -1;    // -1 if not in a folder, else the uid of the parent
                folderOpen: true;    // For folders, this indicates whether their children are
                                     // displayed. Otherwise, indicates if visible.
            }
            ListElement {
                name: "two";

                uid: 2;
                dropTarget: "none";
                isFolder: false;
                parentFolder: -1;
                folderOpen: true;
            }
            ListElement {
                name: "three";

                uid: 3;
                dropTarget: "none";
                isFolder: false;
                parentFolder: -1;
                folderOpen: true;
            }
            ListElement {
                name: "four";

                uid: 4;
                dropTarget: "none";
                isFolder: false;
                parentFolder: -1;
                folderOpen: true;
            }
            ListElement {
                name: "five";

                uid: 5;
                dropTarget: "none";
                isFolder: false;
                parentFolder: -1;
                folderOpen: true;
            }
            ListElement {
                name: "six";

                uid: 6;
                dropTarget: "none";
                isFolder: false;
                parentFolder: -1;
                folderOpen: true;
            }
            ListElement {
                name: "seven";

                uid: 7;
                dropTarget: "none";
                isFolder: false;
                parentFolder: -1;
                folderOpen: true;
            }
            ListElement {
                name: "eight";

                uid: 8;
                dropTarget: "none";
                isFolder: false;
                parentFolder: -1;
                folderOpen: true;
            }
            ListElement {
                name: "nine";

                uid: 9;
                dropTarget: "none";
                isFolder: false;
                parentFolder: -1;
                folderOpen: true;
            }
        }

        // Perform an animation when the list is rearranged.
        displaced: Transition {
            NumberAnimation { properties: "x,y"; duration: 50 }
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

        Text {
            text: "Stationary items:   ";
            verticalAlignment: Text.AlignVCenter;
            height: parent.height;
        }

        SpinBox {
            id: spinbox;
            width: 50;
            minimumValue: 0;
            maximumValue: sampleList.count;

            value: 0;
        }
    }
}
