import QtQuick
import QtQuick.Controls
import QtQuick.Window
import QtQuick.Dialogs

ApplicationWindow {
    id: app;
    title: "QML Rearrangeable Tree View";
    width: 400;
    height: 480;
    visible: true;
    color: "#eee";

    // Scale factor for DPI awareness. In production you might bind this to
    // Screen.devicePixelRatio or a user preference.
    property real scaleFactor: 1.0;

    // This is used for generating UIDs for folders. This method is simplistic
    // and isn't intended for production code.
    property int uid: 10;
    function uidNext() {
        return ++uid;
    }

    // Note: You must provide an insertFolder() function to create and insert a folder in your
    //       model. Chances are you'll want to do something fancier than this in production code.
    function insertFolder(index) {
        // Generate a unique ID for our new parent folder.
        var uid = uidNext();

        console.log("insert folder ", index)

        // Create our new folder.
        sampleList.insert(index, {
                         "uid": uid,
                         "title": "New folder",
                         "dropTarget":"none",
                         "isFolder":true,
                         "parentFolder":-1,
                         "folderOpen": true,
                         "draggable": true
                     });

        return uid;
    }

    ScrollView {
        id: scrollView;
        anchors.top: parent.top;
        anchors.right: parent.right;
        anchors.left: parent.left;
        anchors.bottom: bottomRow.top;

        ListView {
            id: treeView

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

                // Per-item drag control. Items with draggable: false can't be moved regardless
                // of their position. (Compare with numStationary which is position-based.)
                dragEnabled: draggable;

                // Style the opener.
                openerImage: "opener.png";
                openerOffsetX: 5;
                openerOffsetY: 2;
                openerAnimationDuration: 250;

                // Don't require a long-press to begin drag. (Set to true for mobile, touchscreens, etc.)
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

                // Folders are always visible, but their children are not.
                visible: isFolder ? true : (parentFolder == -1 || folderOpen ? true : false);
                height: visible ? Math.round(30 * app.scaleFactor) : 0;

                ContextMenu.menu: Menu {
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

                // Draw the opener, title in a row with uid and parentUID (for debugging)
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

            // Some sample data.  This also demonstrates the required properties and their data types.
            model: ListModel {
                id: sampleList

                ListElement {
                    title: "All Items";

                    // Required:
                    uid: 1;              // Unique id (integer)
                    dropTarget: "none";  // Used for drag and drop UI. (Persistence not required.)
                    isFolder: false;     // True if a folder, else false
                    parentFolder: -1;    // -1 if not in a folder, else the uid of the parent
                    folderOpen: true;    // For folders, this indicates whether their children are
                                         // displayed. Otherwise, indicates if visible.

                    // Optional:
                    draggable: false;    // Per-item drag control (e.g. for "special" items)
                }
                ListElement {
                    title: "two";

                    uid: 2;
                    dropTarget: "none";
                    isFolder: false;
                    parentFolder: -1;
                    folderOpen: true;
                    draggable: true;
                }
                ListElement {
                    title: "three";

                    uid: 3;
                    dropTarget: "none";
                    isFolder: false;
                    parentFolder: -1;
                    folderOpen: true;
                    draggable: true;
                }
                ListElement {
                    title: "four";

                    uid: 4;
                    dropTarget: "none";
                    isFolder: false;
                    parentFolder: -1;
                    folderOpen: true;
                    draggable: true;
                }
                ListElement {
                    title: "five";

                    uid: 5;
                    dropTarget: "none";
                    isFolder: false;
                    parentFolder: -1;
                    folderOpen: true;
                    draggable: true;
                }
                ListElement {
                    title: "six";

                    uid: 6;
                    dropTarget: "none";
                    isFolder: false;
                    parentFolder: -1;
                    folderOpen: true;
                    draggable: true;
                }
                ListElement {
                    title: "seven";

                    uid: 7;
                    dropTarget: "none";
                    isFolder: false;
                    parentFolder: -1;
                    folderOpen: true;
                    draggable: true;
                }
                ListElement {
                    title: "eight";

                    uid: 8;
                    dropTarget: "none";
                    isFolder: false;
                    parentFolder: -1;
                    folderOpen: true;
                    draggable: true;
                }
                ListElement {
                    title: "nine";

                    uid: 9;
                    dropTarget: "none";
                    isFolder: false;
                    parentFolder: -1;
                    folderOpen: true;
                    draggable: true;
                }
            }

            // Perform an animation when the list is rearranged.
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
            text: "Stationary items at top:";
            verticalAlignment: Text.AlignVCenter;
            height: parent.height;
        }

        SpinBox {
            id: spinbox;
            width: 50;

            value: 1;
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
