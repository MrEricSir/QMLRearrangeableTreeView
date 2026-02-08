import QtQuick
import QtQuick.Controls

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

    QMLRearrangeableTreeView {
        anchors.top: parent.top;
        anchors.right: parent.right;
        anchors.left: parent.left;
        anchors.bottom: bottomRow.top;

        numStationary: spinbox.value;
        scaleFactor: app.scaleFactor;
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
