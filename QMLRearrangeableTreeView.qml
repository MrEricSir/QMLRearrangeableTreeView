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
        anchors.fill: parent

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
            numSpecial: 2;

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

                // This is the opener, you'll want to restyle this however you like.
                Item {
                    id: opener

                    visible: isFolder

                    width: 30
                    height: 30

                    Image {
                        id: openerIcon

                        source: "opener.png"

                        x: 5
                        y: 2

                        width: 20
                        height: 20

                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true

                        states: [
                            State { name: "open"; },
                            State { name: "closed"; }
                        ]

                        state: folderOpen ? "open" : "closed";

                        // Animate the opener with a quick rotation.
                        transitions: [
                            Transition {
                                from: "*";
                                to: "closed";
                                RotationAnimation {
                                    running: false;
                                    direction: RotationAnimation.Counterclockwise;

                                    target: openerIcon;
                                    to: -90;
                                    duration: 250;

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
                                    duration: 250;

                                    // Supress warning message.
                                    property: "rotation";
                                }
                            }
                        ]
                    }

                    MouseArea {
                        anchors.fill: parent;

                        onClicked: {
                            console.log("opener changing folder state")

                            // Open/close children.
                            var listModel = titleDelegate.ListView.view.model;
                            for (var i = index + 1; i < listModel.count; i++) {
                                if (listModel.get(i).parentFolder !== uid) {
                                    break;
                                }

                                setMyProperty(i, "folderOpen", !folderOpen);
                            }

                            // Open/close self.
                            setMyProperty(index, "folderOpen", !folderOpen);
                        }
                    }
                }

                Text {
                    id: itemName;

                    text: name;

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
                name: "one [special]";

                // Required:
                uid: 1;              // Unique id (integer)
                dropTarget: "none";  // Used for drag and drop UI
                isFolder: false;     // True if there are subfolders, else false
                parentFolder: -1;    // -1 if in a subfolder, else the uid of the parent
                folderOpen: true;    // For folders, this indicates whether their children are
                                     // displayed. For folders, whether they are open or closed.
            }
            ListElement {
                name: "two [special]";

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
}
