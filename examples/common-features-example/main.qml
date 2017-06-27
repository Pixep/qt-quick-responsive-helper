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
