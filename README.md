# QMLRearrangeableTreeView

Copyright 2026 Eric Gregory

QMLRearrangeableTreeView is a list-based TreeView for Qt 6 that can be rearranged with a mouse or touch device.  This was originally built for an RSS reader I'm working on.  Someday maybe there will be a built-in QML component that does this, but alas, that day is not today.  In the meantime I'm giving this code away for free (see the included LICENSE file for details.)

On the web at: https://github.com/MrEricSir/QMLRearrangeableTreeView


## Features

* Rearrangeable by either pressing or long-pressing (configurable) on an item and dragging it.
* One item can be "selected" with a mouse click.
* One-level deep folders (similar to iOS home screen folders.)
* Arbitrary number of stationary items can't be rearranged at the top of the list.
* Works with a standard QML ListView.
* Data is stored entirely in the list model itself.


## Try It Out

There are two ways to test out the project to see if it meets your needs; with the `qml` tool or with the full `C++` example.

The easiest way is with the `qml` command line tool. From within the project directory, run this command:

```bash
qml -I . main.qml
```

In a real world scenario you would use QMLRearrangeableTreeView in a C++ project. Use `cmake` to build the example project.

In your own implementation, look at the `TreeModel` class to see how to create a `QAbstractListModel` that represents your
list data and expose it to the QML layer.


## Pitching In

Much like the GIFs on every 90's website warned you, this code too is under construction.  If you find a bug feel free to open an issue on GitHub or submit a pull request.

Contributions are welcome.
