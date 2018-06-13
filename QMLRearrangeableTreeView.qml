// Original code by Eric Gregory, see LICENSE
// basic editing and JSON save/load added Oliver Heggelbacher

import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.3

Rectangle {
    // This is used for generating UIDs for folders. This method is simplistic
    // and isn't intended for production code.
    property int uid: 10;
    function uidNext() {
        return ++uid;
    }

    // Note: You must provide an insertFolder() function to create and insert a folder in your
    //        model. Chances are you'll want to do something fancier than this in production code.
    function insertFolder(model, index) {
        // Generate a unique ID for our new parent folder.
        var uid = uidNext();

        console.log("insert folder ", index)

        // Create our new folder.
        model.insert(index, {
                         "uid": uid,
                         "title": "New folder",
                         "dropTarget":"none",
                         "isFolder":true,
                         "parentFolder":-1,
                         "folderOpen": true
                     });

        return uid;
    }

    function removeNode(model, index) {
        model.remove(index)
    }

    function jsonParse(datastore) {
        if (datastore) {
            treeView.model.clear()
            var datamodel = JSON.parse(datastore)
            for (var i = 0; i < datamodel.length; ++i) treeView.model.append(datamodel[i])
        }
    }

    function jsonStringify() {
        var datamodel = []
        for (var i = 0; i < treeView.model.count; ++i) datamodel.push(treeView.model.get(i))
        return JSON.stringify(datamodel)
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
            numStationary: spinbox.value;

            // Style the opener.
            openerImage: "opener.png";
            openerOffsetX: 5;
            openerOffsetY: 2;
            openerAnimationDuration: 250;

            // Don't require a long-press to begin drag. (Set to true for mobile, touchscreens, etc.)
            dragOnLongPress: false;

            // basic edit popup title using double click or right click
            onDoubleClicked: {
                console.log("on double click")
                itemNameInput.text = title
                popupItemName.open()
            }
            onRightClicked: {
                console.log("on right click")
                itemNameInput.text = title
                popupItemName.open()
            }

            onClicked: {
                console.log("on click")
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

                    text: title + (index < titleDelegate.numStationary ? " [stationary]" : "");

                    width: 200
                    height: 30

                    font.pointSize: 12
                    font.family: "Segoe UI"

                }

                // Edit title using double click
                Popup {
                    id: popupItemName
                    x: itemName.x - 15
                    y: itemName.y - 15
                    width: itemName.width + 30
                    height: itemName.height + 100
                    modal: true
                    focus: true
                    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
                    ColumnLayout{
                        Text {
                            text: qsTr("Change Name")
                            font.pixelSize: 12
                        }
                        TextInput  {
                            id: itemNameInput
                            font.pixelSize: 16
                            focus: true
                            onAccepted: {
                                title = itemNameInput.text
                                popupItemName.close()
                            }
                        }
                        Rectangle {
                            height: 15
                        }
                        RowLayout {
                            Button {
                                id: buttonDelete
                                text: qsTr("Delete\n(press and hold)")
                                onPressAndHold: {
                                    popupItemName.close()
                                    console.log("delete index " + index)
                                    removeNode(treeView.model, index)
                                }
                            }
                            Button {
                                id: buttonOK
                                text: qsTr("OK\n")
                                onClicked: {
                                    title = itemNameInput.text
                                    popupItemName.close()
                                }
                            }
                        }
                    }
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
                title: "one";

                // Required:
                uid: 1;              // Unique id (integer)
                dropTarget: "none";  // Used for drag and drop UI. (Persistence not required.)
                isFolder: false;     // True if a folder, else false
                parentFolder: -1;    // -1 if not in a folder, else the uid of the parent
                folderOpen: true;    // For folders, this indicates whether their children are
                                     // displayed. Otherwise, indicates if visible.
            }
            ListElement {
                title: "two";

                uid: 2;
                dropTarget: "none";
                isFolder: false;
                parentFolder: -1;
                folderOpen: true;
            }
            ListElement {
                title: "three";

                uid: 3;
                dropTarget: "none";
                isFolder: false;
                parentFolder: -1;
                folderOpen: true;
            }
            ListElement {
                title: "four";

                uid: 4;
                dropTarget: "none";
                isFolder: false;
                parentFolder: -1;
                folderOpen: true;
            }
            ListElement {
                title: "five";

                uid: 5;
                dropTarget: "none";
                isFolder: false;
                parentFolder: -1;
                folderOpen: true;
            }
            ListElement {
                title: "six";

                uid: 6;
                dropTarget: "none";
                isFolder: false;
                parentFolder: -1;
                folderOpen: true;
            }
            ListElement {
                title: "seven";

                uid: 7;
                dropTarget: "none";
                isFolder: false;
                parentFolder: -1;
                folderOpen: true;
            }
            ListElement {
                title: "eight";

                uid: 8;
                dropTarget: "none";
                isFolder: false;
                parentFolder: -1;
                folderOpen: true;
            }
            ListElement {
                title: "nine";

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
            from: 0;
            to: sampleList.count;
            value: 0;
        }
    }
}
