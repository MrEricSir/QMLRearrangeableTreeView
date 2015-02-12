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

    // So we don't have to keep typing this out.
    // Note: For some reason delegate properies can't be aliased, so we use a var here.
    property var model: ListView.view.model;

    function setMyProperty(myIndex, name, value) {
        //
        // Note: In C++ the method is "setData", but it's called "setProperty" with a QML ListModel.
        //
        if (qmlListModel) {
            model.setProperty(myIndex, name, value);
        } else {
            model.setData(myIndex, name, value);
        }
    }

    function moveFromTo(oldPosition, newPosition) {
        //
        // Note: The last parameter is needed for a QML ListModel.  If you're using a C++-based
        //       model you don't need it..
        //
        if (qmlListModel) {
            model.move(oldPosition, newPosition, 1);
        } else {
            model.move(oldPosition, newPosition);
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
        for (var i = 0; i < model.count; i++) {
            drawDnDBorders(i, "none");
        }
    }

    // Creates a folder at the given space, and consumes the next two items.
    function createFolder(firstItemIndex) {
        // Generate a unique ID for our new parent folder.
        var uid = app.uidNext();

        // Create our new folder.
        model.insert(firstItemIndex, {
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
        for (var i = 0; i < model.count; i++) {
            var item = model.get(i);
            if (item.isFolder) {
                // Get UID of current folder.
                var uid = model.get(i).uid;

                var nextItem = i === model.count -1 ? null : model.get(i + 1);

                // If there's no next item or it's got a different UID for its parent,
                // the folder is empty and therefore safe to remove.
                if (nextItem === null || nextItem.parentFolder !== uid) {
                    console.log('deleting folder')
                    model.remove(i, 1);
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

    // (Debug feature) Logs the current model to the console.
    function logModel() {
        for (var i = 0; i < model.count; i++) {
            var item = model.get(i);
            console.log(i, ". ", item.uid, " ", item.name, item.folderOpen ? " " : " [closed] ", item.parentFolder)
        }
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

            // Returns an adjusted index that skips over closed folders.
            function folderSkipIndex(newIndex) {
                if (!model) {
                    return 0; // Haven't fully initialized yet!
                }

                // Start with the basic case.
                var position = clipPosition(newIndex);

                var add = 0;
                var i = index;
                var item;

                // Skip items in closed folders.
                if (movingUp) {
                    // We're moving up.
                    while (i >= 0) {
                        item = model.get(i);
                        if (!item.folderOpen && !item.isFolder) {
                            // Skip anything inside a closed folder.
                            add -= 1;
                        } else if (i <= position && item.folderOpen) {
                            break;
                        }

                        i--;
                    }
                } else {
                    // We're moving down.
                    while (i < model.count) {
                        item = model.get(i);
                        if (item && !item.folderOpen && !item.isFolder) {
                            // Skip anything inside a closed folder.
                            add += 1;
                        } else if (!item || (i >= position && item.folderOpen)) {
                            break;
                        }

                        i++;
                    }
                }

                // We're done!
                return position + add;
            }

            // Number of spaces moved up/down the list (negative is up, pos is down)
            //
            // Maths: The gist of this calculation is we take the difference in layout pixels,
            //        then divide by the (fixed) height of each item.
            property int spacesMoved:  Math.floor((positionEnded - positionStarted +
                                                  (movingUp ? rearrangeableDelegate.height : 0))
                                                  / rearrangeableDelegate.height);

            // New index, used for in-between positions.
            property int newPosition: clipPosition(folderSkipIndex(index + spacesMoved));

            // Cursor's position (positionEnded) mod'd to the delegate height.
            property real cursorModHeight: (positionEnded + (rearrangeableDelegate.height / 2)) % rearrangeableDelegate.height;

            // True if the drag border is in the middle of the current item.
            // Will be set to false if we're out of range.
            property bool isInMiddle: {
                if (!model) {
                    return false;
                }

                // Out of range (top)
                if ((positionEnded <= 0 && numSpecial == 0) || newPosition <= numSpecial) {
                    return false;
                }

                // Out of range (bottom.)
                if (newPosition + 1 >= model.count) {
                    return false;
                }

                // Check if we're in the middle of something.
                return (cursorModHeight > rearrangeableDelegate.height / 4.0) &&
                       (cursorModHeight < rearrangeableDelegate.height - (rearrangeableDelegate.height / 4.0));
            }

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

                // Special handling if we're at the top.
                var atTop = numSpecial == 0 && positionEnded <= 0;

                //console.log("Height of list: ", dragDelegateBorder.ListView.view.childrenRect.height)
                //console.log("Position started: ", positionStarted, " ended: ", positionEnded + rearrangeableDelegate.height, " moved: ", spacesMoved);

                // Erase all existing drag borders.
                removeDragBorders();

                // Unset the on top of space.
                isOnTopOf = -1;

                // Check if the position is on top of an item that could produce subchildren.
                if (isInMiddle && !isFolder && !atTop) {
                    // Math(s): This is a tweaked version of index + spacesMoved (see above)
                    var currentSpace = index + Math.floor((positionEnded - positionStarted +
                        (movingUp ? -(rearrangeableDelegate.height / 2) : (rearrangeableDelegate.height / 2)))
                        / rearrangeableDelegate.height);

                    if (movingUp) {
                        currentSpace += 1;
                    }

                    // Adjust for closed folders.
                    currentSpace = folderSkipIndex(currentSpace);

                    // Same space we started on? Early exit.
                    if (currentSpace === index) {
                        return;
                    }

                    // If we're outside the bounds, this check will fail and we can stop now.
                    if (currentSpace !== clipPosition(currentSpace)) {
                        console.log("ne clipped!")
                        return;
                    }

                    // We're only doing folders one level deep (for now?) so you can't drop on top
                    // of an item that's in a folder.
                    if (model.get(currentSpace).parentFolder >= 0) {
                        return;
                    }

                    //console.log("Currently on top of space: ", currentSpace)

                    // Do a hover roll (unless we're on a folder.)
                    if (!model.get(currentSpace).isFolder) {
                        // Set the on top of space.
                        isOnTopOf = currentSpace;

                        drawDnDBorders(currentSpace, "hover");
                    }

                    return;
                }

                if (spacesMoved === 0 && !atTop) {
                    // Nothing to draw!
                    return;
                }

                // Draw our new border, either on the top or bottom.
                if (newPosition < model.count) {
                    if (spacesMoved > 0 && positionEnded > 0 && !atTop) {
                        // Special case for last time: don't draw a bottom drag border -- ever.
                        if (index !== model.count - 1) {
                            var pos = newPosition;

                            // If we're in a closed folder, skip back up to the folder itself because
                            // we can't draw a border on an invisible item.
                            if (!model.get(pos).folderOpen) {
                                for (pos; pos >= 0; pos--) {
                                    if (model.get(pos).isFolder) {
                                        break;
                                    }
                                }
                            }

                            drawDnDBorders(pos, "bottom");
                        }
                    } else if (atTop && index != 0) {
                        // Special handling for top item.
                        drawDnDBorders(0, "top");
                    } else {
                        // Otherwise, just check if it's a different space and draw the
                        // stupid border.
                        if (index != newPosition) {
                            drawDnDBorders(newPosition, "top");
                        }
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
                        if (positionEnded == 0 && mouse.y >= 0) {
                            // We didn't move.
                            myNewPosition = index;
                        } else {
                            // We moved!
                            myNewPosition = newPosition;
                            if (numSpecial == 0 && positionEnded <= 0) {
                                // Special case for top item.
                                myNewPosition = 0;
                            }
                        }
                    } else {
                        // Drag on top of another item.
                        myNewPosition = isOnTopOf + (movingUp ? 1 : -1);
                    }

                    // Assuming this is a move, this represents the number of spaces we actually
                    // moved when all was said and done.
                    var spacesActuallyMoved = -1;

                    // Only move between valid targets.
                    var itemAboveNewPos = model.get(movingUp ? myNewPosition - 1 : myNewPosition);
                    if ((myNewPosition === index) ||
                            /////////////////////////////////////////////////
                            /////////////////////////////////////////////////
                            // TODO: allow folder to be positioned after another folder at bottom
                            /////////////////////////////////////////////////
                            /////////////////////////////////////////////////
                        (isFolder && itemAboveNewPos && (itemAboveNewPos.isFolder || itemAboveNewPos.parentFolder !== -1) ) ) {
                        // We didn't move; snap the rectangle back in place.
                        rearrangeableDelegate.y = positionStarted;
                    } else {
                        // Do the move!
                        spacesActuallyMoved = myNewPosition - index;
                        moveTo(myNewPosition);
                        weMoved = true; // remember
                    }


                    if (isOnTopOf !== -1 && !isFolder) {
                        // We're on top of another item.
                        console.log("You dropped it in the middle, dawg: ", isOnTopOf)
                        var onTopOfItem = model.get(isOnTopOf);

                        if (onTopOfItem.isFolder && !onTopOfItem.folderOpen) {
                            // We're on top of a closed folder.  This is a no-op because we
                            // don't allow dragging into a closed folder.
                        } else if (onTopOfItem.isFolder) {
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
                        var item, i;

                        if (!weMoved) {
                            // noop: We didn't move! Don't do anything.
                        } else if (spacesActuallyMoved < 0) {
                            // Move children UP.
                            for (i = 0; i < model.count; i++) {
                                item = model.get(i);
                                if (item.parentFolder === uid) {
                                    moveFromTo(i, clipPosition(i + spacesActuallyMoved));
                                }
                            }
                        } else {
                            // Move children DOWN.
                            // 1. Count the number of items in the folder.
                            var itemsInFolder = 0;
                            for (i = 0; i < model.count; i++) {
                                item = model.get(i);
                                if (item.parentFolder === uid) {
                                    itemsInFolder++;
                                }
                            }

                            // 2. Perform the move.
                            for (i = model.count - 1; i > 0 ; i--) {
                                item = model.get(i);
                                if (item.parentFolder === uid) {
                                    moveFromTo(i, clipPosition(i + spacesActuallyMoved - (itemsInFolder - 1)));
                                }
                            }
                        }
                    } else {
                        // We're between two items.  Adjust our parent folder accordingly.
                        if (index > 0) {
                            var aboveItem = model.get(index - 1);
                            var parentFolderUID;

                            if (!aboveItem.folderOpen) {
                                // If the item above is closed, ignore it and make this a root
                                // level item.
                                parentFolderUID = -1;
                            } else if (aboveItem.isFolder) {
                                // If the item above is a folder, reparent.
                                parentFolderUID = aboveItem.uid;
                            } else {
                                // Otherwise, set our parent to the same parent as the item above.
                                parentFolderUID = aboveItem.parentFolder;
                            }

                            setMyProperty(index, "parentFolder", parentFolderUID);
                        }
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
