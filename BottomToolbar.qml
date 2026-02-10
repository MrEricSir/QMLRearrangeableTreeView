import QtQuick
import QtQuick.Controls

Column {
    property int numRows: 0;

    property alias numStationary: stationaryItemsSlider.value;
    property alias scaleFactor: scaleSlider.value;
    property alias folderIndent: folderIndentSlider.value;
    property alias folderMargin: folderMarginSlider.value;

    spacing: 5;

    Row {
        spacing: 20;

        Text {
            text: "Stationary items:";
            verticalAlignment: Text.AlignVCenter;
            height: parent.height;
        }

        // Sets the number of stationary items at the top that can't be moved.
        Slider {
            id: stationaryItemsSlider;
            width: 100;

            // Set default after model is loaded.
            Component.onCompleted: value = 1;

            from: 0;
            to: numRows;
            stepSize: 1;
            snapMode: Slider.SnapAlways;
        }

        Text {
            text: "Scale:";
            verticalAlignment: Text.AlignVCenter;
            height: parent.height;
        }

        // Sets scaling amount to simulate DPI settings, etc.
        Slider {
            id: scaleSlider;
            width: 100;
            from: 0.5;
            to: 2.0;
            value: 1.0;
        }
    }

    Row {
        spacing: 20;

        Text {
            text: "Folder indent:";
            verticalAlignment: Text.AlignVCenter;
            height: parent.height;
        }

        Slider {
            id: folderIndentSlider;
            width: 100;
            from: 0;
            to: 50;
            value: 25;
            stepSize: 1;
            snapMode: Slider.SnapAlways;
        }

        Text {
            text: "Folder margin:";
            verticalAlignment: Text.AlignVCenter;
            height: parent.height;
        }

        Slider {
            id: folderMarginSlider;
            width: 100;
            from: 0;
            to: 20;
            value: 0;
            stepSize: 1;
            snapMode: Slider.SnapAlways;
        }
    }
}
