import QtQuick 2.2
import QtQuick.Window 2.0

Window {
    id: window
    visible: true
    width: 640
    height: 480
    title: qsTr("Responsive helper example")

    // Minimal example, simply include this in your QML
    ResponsiveHelper {
        id: helperBar

        // Reference to your Window
        targetWindow: window

        // Reference to the content root, for resizing and scaling
        // It is not possible to use window.contentItem. If not set,
        // the content will not be scaled to fit on the screen.
        rootItem: root

        // Position it where you want
        anchors.left: parent.right
        anchors.leftMargin: 30
    }

    // Root item used to scale the content to fit on the screen.
    Item {
        id: root
        anchors.centerIn: parent

        // width, height and scale will be adapted automatically
        width: parent.width
        height: parent.height

        // Scale with resolution, from a 640x480 reference
        property real resolutionScaleFactor: (width * height) / (640 * 480)
        // Scale with pixel density, from a 72ppi reference
        property real dpiScaleFactor: helperBar.dpi / 72

        Rectangle {
            id: header
            width: parent.width
            height: childrenRect.height
            color: "#DDD"

            Column {
                Text {
                    text: qsTr("Scales with resolution")
                    font.pixelSize: 20 * root.resolutionScaleFactor
                }
                Text {
                    text: qsTr("Scales with DPI")
                    font.pixelSize: 20 * root.dpiScaleFactor
                }
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

                property int rectSize: 25 * root.dpiScaleFactor

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
