import QtQuick 2.2
import QtQuick.Window 2.0
import QtQuick.Controls 1.0

Window {
    id: window
    visible: true
    width: 640
    height: 480
    title: qsTr("Responsive helper example")

    // Minimal example, simply include this in your QML
    ResponsiveHelper {
        id: helperBar
        targetWindow: window

        // Place it where you want
        anchors.left: parent.right
        anchors.leftMargin: 30
    }

    //------------------------------------------------------------
    //  Simple usage example
    //------------------------------------------------------------
    property real scaleFactor: width / 640
    property real dpiScaleFactor: helperBar.dpi / 20

    Text {
        id: textEdit
        text: qsTr("Some text")
        verticalAlignment: Text.AlignVCenter
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 20
        font.pixelSize: 20 * window.scaleFactor
    }

    Flow {
        anchors.top: textEdit.bottom
        anchors.topMargin: 10
        height: 4000//parent.height - textEdit.y - textEdit.height
        width: parent.width
        spacing: 10

        Repeater {
            model: 15
            Rectangle {
                width: 25 * window.dpiScaleFactor
                height: width
                color: "blue"
            }
        }
    }
}
