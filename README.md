# QMLRearrangeableTreeView

Copyright 2015 Eric Gregory

***WARNING*** As of Qt 5.5 this is obsolete. I haven't had time to backport this yet to the new built-in QML TreeView.

QMLRearrangeableTreeView is a list-based TreeView that can be rearranged with a mouse or touch device.  This was originally built for an RSS reader I'm working on.  Someday maybe there will be a built-in QML component that does this, but alas, that day is not today.  In the meantime I'm giving this code away for free (see the included LICENSE file for details.)

On the web at: https://github.com/MrEricSir/QMLRearrangeableTreeView

Features:

* Rearrangeable by either pressing or long-pressing (configurable) on an item and dragging it.
* One item can be "selected" with a mouse click.
* One-level deep folders (similar to iOS home screen folders.)
* Arbitrary number of stationary items can't be rearranged at the top of the list.
* Works with a standard QML ListView.
* Data is stored entirely in the list model itself.

Much like the GIFs on every 90's website warned you, this code too is under construction.  If you find a bug feel free to open an issue on GitHub or submit a pull request.
