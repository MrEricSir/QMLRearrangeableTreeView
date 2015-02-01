import QtQuick 2.4

/**
  * This is a rearrangeable delegate for a simple 1-level folder tree ListView.
  */
Rectangle {
    id: rearrangeableDelegate;

    // Don't use a MouseArea!!  Instead, use these signals to find when the item is clicked.
    signal clicked();
    signal doubleClicked();

    // Subscribe to this signal to know when the list may have changed order.
    signal orderChanged();

    // Sets the number of undraggable items at the top of the list.
    property int numSpecial: 0;

    // How much to indent for a folder.
    property int folderIndent: 25;

    // Drag border color and height.
    property color dragBorderColor: "black";
    property int dragBorderHeight: 1;
    property bool dragEnabled: true;

    // I put this flag in because I'm using a C++ based list model that's not 100% API compatible
    // with QML's ListModel.  Depending on your list model backend some fiddling may be necessary.
    property bool qmlListModel: true;


    // PRIVATE:

    // This allows children to be positioned within the element.
    default property alias contents: placeholder.children;

    width: parent.width;
    height: placeholder.childrenRect.height;

    color: "transparent";

    function setMyProperty(myIndex, name, value) {
        //
        // Note: In C++ the method is "setData", but it's called "setProperty" with a QML ListModel.
        //
        if (qmlListModel) {
            rearrangeableDelegate.ListView.view.model.setProperty(myIndex, name, value);
        } else {
            rearrangeableDelegate.ListView.view.model.setData(myIndex, name, value);
        }
    }

    function moveFromTo(oldPosition, newPosition) {
        //
        // Note: The last parameter is needed for a QML ListModel.  If you're using a C++-based
        //       model you don't need it..
        //
        if (qmlListModel) {
            rearrangeableDelegate.ListView.view.model.move(oldPosition, newPosition, 1);
        } else {
            rearrangeableDelegate.ListView.view.model.move(oldPosition, newPosition);
        }
    }

    // Moves this item to a new position.
    function moveTo(position) {
        moveFromTo(index, position);
    }

    // Draws d&d drop-target borders for a given index.
    // Valid positions are "top", "bottom", and "none"
    function drawDnDBorders(index, position) {
        setMyProperty(index, "dropTarget", position);
    }

    // Makes all the drag borders from a DND job go away.
    function removeDragBorders() {
        for (var i = 0; i < rearrangeableDelegate.ListView.view.model.count; i++) {
            drawDnDBorders(i, "none");
        }
    }

    // Creates a folder at the given space, and consumes the next two items.
    function createFolder(firstItemIndex) {
        // Generate a unique ID for our new parent folder.
        var uid = app.uidNext();

        // Create our new folder.
        rearrangeableDelegate.ListView.view.model.insert(firstItemIndex, {
                                                          "uid": uid,
                                                          "name": "New folder",
                                                          "dropTarget":"none",
                                                          "isFolder":true,
                                                          "parentFolder":-1,
                                                          "folderOpen": true
                                                      });

        // Consume next two items by poppin' em out!
        for (var i = 1; i < 3; i++) {
            setMyProperty(firstItemIndex + i, "parentFolder", uid);
        }
    }

    // If you drag everything out of a folder, we delete it.
    // (my pary are with the father who lost his chrilden)
    function clearEmptyFolders() {
        var listModel = rearrangeableDelegate.ListView.view.model;
        for (var i = 0; i < listModel.count; i++) {
            var item = listModel.get(i);
            if (item.isFolder) {
                // Get UID of current folder.
                var uid = rearrangeableDelegate.ListView.view.model.get(i).uid;

                var nextItem = i === listModel.count -1 ? null : listModel.get(i + 1);

                // If there's no next item or it's got a different UID for its parent,
                // the folder is empty and therefore safe to remove.
                if (nextItem === null || nextItem.parentFolder !== uid) {
                    console.log('deleting folder')
                    listModel.remove(i, 1);
                    if (i > 0) {
                        i--; // Back up one.
                    }
                }
            }
        }
    }

    // Given an integer position, this clips it to within the min and max available in the list.
    // Note that numSpecial is the min!
    function clipPosition(index) {
        return Math.max(numSpecial, Math.min(rearrangeableDelegate.ListView.view.count - 1, index));
    }

    Rectangle {
        color: "transparent";
        anchors.fill: parent;

        Rectangle {
            id: topBorder;

            color: dragBorderColor;
            height: dragBorderHeight;
            width: parent.width;
            visible: dropTarget === "top";

            anchors.top: parent.top;
        }

        Item {
            id: placeholder;

            // Show as indented if it's a folder or if we're hovering over it.
            x: parentFolder >= 0 ? folderIndent : (dropTarget === "hover" ? folderIndent : 0);
        }

        Rectangle {
            id: bottomBorder;

            color: dragBorderColor;
            height: dragBorderHeight;
            width: parent.width;
            visible: dropTarget === "bottom";

            anchors.bottom: parent.bottom;
        }

        MouseArea {
            id: dragArea;
            anchors.fill: parent;

            // Starting position (in layout pixels)
            property real positionStarted: 0;

            // Ending position (in layout pixels)
            property real positionEnded: 0;

            // True if we're moving upwardly.
            property bool movingUp: positionEnded < positionStarted;

            // Number of spaces moved up/down the list (negative is up, pos is down)
            //
            // Maths: The gist of this calculation is we take the difference in layout pixels,
            //        then divide by the (fixed) height of each item.
            property int spacesMoved:  Math.floor((positionEnded - positionStarted +
                                                  (movingUp ? rearrangeableDelegate.height : 0))
                                                  / rearrangeableDelegate.height);

            // New index (within range)
            property int newPosition: clipPosition(index + spacesMoved);

            // Cursor's position (positionEnded) mod'd to the delegate height.
            property real cursorModHeight: (positionEnded + (rearrangeableDelegate.height / 2)) % rearrangeableDelegate.height;

            // True if the drag border is in the middle of the current item.
            property bool isInMiddle: (cursorModHeight > rearrangeableDelegate.height / 4.0) &&
                                      (cursorModHeight < rearrangeableDelegate.height - (rearrangeableDelegate.height / 4.0));

            // If we're on top of a space, this is set to that space.  It's a rather complex
            // calculation that occurs below in the drag handler.
            property int isOnTopOf: -1;

            // Whether or not the rect is currently being held.
            property bool held: false;

            propagateComposedEvents: true;

            drag.axis: Drag.YAxis;

            onClicked: {
                if (isFolder && mouse.x < 30) {
                    // Bail and let the opener MouseArea handle this.
                    mouse.accepted = false;
                    return;
                }

                rearrangeableDelegate.clicked();
            }

            onDoubleClicked: rearrangeableDelegate.doubleClicked();

            onPressAndHold: {
                if (!dragEnabled || index < numSpecial) {
                    return;
                }

                rearrangeableDelegate.z = 2;
                positionStarted = rearrangeableDelegate.y;
                dragArea.drag.target = rearrangeableDelegate;
                rearrangeableDelegate.opacity = 0.6;
                rearrangeableDelegate.ListView.view.interactive = false;
                drag.maximumY = (rearrangeableDelegate.ListView.view.height - rearrangeableDelegate.height - 1 + rearrangeableDelegate.ListView.view.contentY);
                drag.minimumY = 0;

                held = true;
            }

            onPositionChanged: {
                if (!held) {
                    return;
                }

                positionEnded = rearrangeableDelegate.y;

                //console.log("Height of list: ", dragDelegateBorder.ListView.view.childrenRect.height)
                console.log("Position started: ", positionStarted, " ended: ", positionEnded + rearrangeableDelegate.height, " moved: ", spacesMoved);

                // Erase all existing drag borders.
                removeDragBorders();

                // Unset the on top of space.
                isOnTopOf = -1;

                // Check if the position is on top of an item that could produce subchildren.
                if (isInMiddle) {
                    // Folders cannot be dragged around this way.
                    if (isFolder) {
                        return;
                    }

                    // Math: This is a tweaked version of spacesMoved (see above)
                    var currentSpace = index + Math.floor((positionEnded - positionStarted +
                        (movingUp ? -(rearrangeableDelegate.height / 2) : (rearrangeableDelegate.height / 2)))
                        / rearrangeableDelegate.height);// + 1;

                    if (movingUp) {
                        currentSpace += 1;
                    }

                    // If we're outside the bounds, this check will fail and we can stop now.
                    if (currentSpace !== clipPosition(currentSpace)) {
                        return;
                    }

                    // Same space we started on? Early exit.
                    if (currentSpace === index) {
                        return;
                    }

                    // We're only doing folders one level deep (for now?) so you can't drop on top
                    // of an item that's in a folder.
                    if (rearrangeableDelegate.ListView.view.model.get(currentSpace).parentFolder >= 0) {
                        return;
                    }

                    console.log("Currently on top of space: ", currentSpace)

                    // Set the on top of space.
                    isOnTopOf = currentSpace;

                    // Do a hover roll (unless we're on a folder.)
                    if (!rearrangeableDelegate.ListView.view.model.get(currentSpace).isFolder) {
                        drawDnDBorders(currentSpace, "hover");
                    }

                    return;
                }

                if (spacesMoved === 0) {
                    // Nothing to draw!
                    return;
                }

                // Draw our new border, either on the top or bottom.
                if (newPosition < rearrangeableDelegate.ListView.view.count) {
                    if (spacesMoved > 0) {
                        // Special case for last time: don't draw a bottom drag border -- ever.
                        if (index !== rearrangeableDelegate.ListView.view.count - 1) {
                            drawDnDBorders(newPosition, "bottom");
                        }
                    } else {
                        drawDnDBorders(newPosition, "top");
                    }
                }
            }

            onReleased: {
                // Handle Press & Hold events
                if (held) {
                    held = false;

                    rearrangeableDelegate.z = 1;
                    rearrangeableDelegate.opacity = 1;
                    rearrangeableDelegate.ListView.view.interactive = true;
                    dragArea.drag.target = null;

                    removeDragBorders();

                    var weMoved = false;

                    // Our real new position depends on whether we're dropping on top of a
                    // list item, or in between two items.
                    var myNewPosition;
                    if (isOnTopOf == -1) {
                        // Drag between two items (or drop back where we started if we haven't moved.)
                        myNewPosition = positionEnded == 0 ? index : newPosition;
                        if (positionEnded == 0) {
                            console.log("You haven't moved, numb nuts.")
                            console.log("(and yes, your nuts really are numb)")

                        }
                    } else {
                        // Drag on top of another item.
                        myNewPosition = isOnTopOf + (movingUp ? 1 : -1);
                    }

                    // Only move between valid targets.
                    var itemAboveNewPos = rearrangeableDelegate.ListView.view.model.get(movingUp ? myNewPosition - 1 : myNewPosition);
                    if ((myNewPosition === index) ||
                            /////////////////////////////////////////////////
                            /////////////////////////////////////////////////
                            // TODO: allow folder to be positioned after another folder at bottom
                            /////////////////////////////////////////////////
                            /////////////////////////////////////////////////
                        (isFolder && (itemAboveNewPos.isFolder || itemAboveNewPos.parentFolder !== -1) ) ) {
                        // We didn't move; snap the rectangle back in place.
                        rearrangeableDelegate.y = positionStarted;
                    } else {
                        // Do the move!
                        moveTo(myNewPosition);
                        weMoved = true; // remember
                    }


                    if (isOnTopOf !== -1 && !isFolder) {
                        // We're on top of another item.
                        console.log("You dropped it in the middle, dawg: ", isOnTopOf)
                        var onTopOfItem = rearrangeableDelegate.ListView.view.model.get(isOnTopOf);

                        if (onTopOfItem.isFolder) {
                             // If we're dropped on top of a folder, add ourselves to the folder.
                            console.log("dropped on a folder")

                            // BUGFIX: Sometimes the sub item is placed above the folder.  This
                            //         is a hacky workaround to correct for that case.
                            if (index === isOnTopOf - 1) {
                                moveTo(isOnTopOf);
                            }

                            setMyProperty(index, "parentFolder", onTopOfItem.uid)
                        } else {
                            // If we're on top of a regular item, create a new folder.
                            var createFolderAt = movingUp ? isOnTopOf : isOnTopOf - 1;
                            createFolder(createFolderAt);
                        }
                    } else if (isFolder) {
                        // I am a folder! Drag my children too!
                        if (!weMoved) {
                            // noop: We didn't move! Don't do anything.
                        } else if (spacesMoved < 0) {
                            // Move children UP.
                            for (var i = 0; i < rearrangeableDelegate.ListView.view.model.count; i++) {
                                var item = rearrangeableDelegate.ListView.view.model.get(i);
                                if (item.parentFolder === uid) {
                                    moveFromTo(i, i + spacesMoved);
                                }
                            }
                        } else {
                            // Move children DOWN.
                            for (var i = rearrangeableDelegate.ListView.view.model.count - 1; i > 0 ; i--) {
                                var item2 = rearrangeableDelegate.ListView.view.model.get(i);
                                if (item2.parentFolder === uid) {
                                    moveFromTo(i, i + spacesMoved - 1);
                                    //i++;
                                }
                            }
                        }
                    } else {
                        // We're between two items.  If the item above is a folder, reparent.
                        // Otherwise, set our parent to the same parent as the item above.
                        var aboveItem = rearrangeableDelegate.ListView.view.model.get(index - 1);
                        var parentFolderUID = aboveItem.isFolder ? aboveItem.uid : aboveItem.parentFolder;
                        setMyProperty(index, "parentFolder", parentFolderUID);
                    }

                    // If any folders are empty, delete 'em.
                    clearEmptyFolders();

                    // We emit signal.  Main screen turn on.
                    orderChanged();

                    return;
                }
            }
        }
    }

}
