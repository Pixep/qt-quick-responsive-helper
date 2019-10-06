import QtQuick 2.2
import QtQuick.Window 2.0

Window {
    id: window
    visible: true
    width: 640
    height: 480
    title: qsTr("Responsive helper example")

    //------------------------------------------------------------
    //  Simple usage example
    //------------------------------------------------------------
    property real scaleFactor: width / 640
    property real dpiScaleFactor: 72 / 20

    // Minimal example, simply include this in your QML
    ResponsiveHelper {
        id: helperBar
        targetWindow: window
        scaleItem: scaleItemd
        // Place it where you want
        anchors.left: parent.right
        anchors.leftMargin: 30
    }

    Item {
        id: scaleItemd
        anchors.centerIn: parent
        width: parent.width
        height: parent.height

    Rectangle {
        id: header
        width: parent.width
        height: 30 * window.scaleFactor
        color: "#DDD"

        Text {
            id: textEdit
            text: qsTr("Some text")
            font.pixelSize: 20 * window.scaleFactor
            anchors.centerIn: parent
        }
    }

    Flickable {
        width: parent.width
        anchors.top: header.bottom
        anchors.topMargin: 10
        height: parent.height - header.height - header.y
        contentHeight: flow.height
        clip: true

        Grid {
            id: flow
            height: childrenRect.height
            width: columns * (spacing + rectSize)
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10
            columns: parent.width / (spacing + rectSize)
            rows: 15

            property int rectSize: 25 * window.dpiScaleFactor

            Repeater {
                model: 15
                Rectangle {
                    width: parent.rectSize
                    height: width
                    color: "blue"
                }
            }
        }
    }
    }
}
