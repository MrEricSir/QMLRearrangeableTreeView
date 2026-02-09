import QtQuick
import QtQuick.Controls

Item {
    id: root;

    // Number of items at the top of the list that can never be reordered
    // or put into folders.
    property int numStationary: 0;

    // Scale factor for DPI awareness.
    property real scaleFactor: 1.0;

    // Number of rows in the model.
    readonly property alias numRows: treeView.count;

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
        anchors.fill: parent;

        ListView {
            id: treeView

            // Only enable scrolling if there's a need.
            interactive: height < childrenRect.height

            delegate: TitleDelegate {
                numStationary: root.numStationary;
                scaleFactor: root.scaleFactor;
                openerImage: "opener.png";
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
}
