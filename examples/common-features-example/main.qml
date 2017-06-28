import QtQuick 2.2
import QtQuick.Window 2.0
import QtQuick.Controls 1.0

Window {
    id: window
    visible: true
    width: 640
    height: 480
    title: qsTr("Responsive helper example")

    // This demonstrates some settings of the component
    ResponsiveHelper {
        id: helperBar
        width: 125
        targetWindow: window

        // Can be completely disabled (not loaded) in production environment
        active: true

        // Hide responsive-related buttons (dpi, resolution)
        //showResponiveToolbar: false

        // Place it where you want
        anchors.left: parent.right
        anchors.leftMargin: 30

        // Lists the presets (resolution, dpi) shown as shortcuts for your application
        initialPreset: 0
        presets: ListModel {
            ListElement { width: 720; height: 1024; dpi: 150}
            ListElement { width: 480; height: 800 }
        }

        // Your custom action buttons
        actions: ListModel {
            ListElement { text: "MyAction1" }
            ListElement { text: "MyAction2" }
        }

        // Handle clicks on your actions
        onActionClicked: {
            console.log("Action " + actionIndex + " clicked")
        }

        // Your buttons or content
        extraContent: [
            Button {
                text: "My Close Button"
                width: parent.width
                onClicked: {
                    window.close()
                }
            }
        ]

        // Handle dpi or pixelDensity changes as you wish, instead of "Screen.pixelDensity"
        onDpiChanged: {
            console.log("Dpi set to " + dpi)
        }
        onPixelDensityChanged: {
            //console.log("Pixel density set to " + pixelDensity)
        }
    }

    //------------------------------------------------------------
    //  Simple usage example
    //------------------------------------------------------------
    property real scaleFactor: width / 640
    property real dpiScaleFactor: helperBar.dpi / 20

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
