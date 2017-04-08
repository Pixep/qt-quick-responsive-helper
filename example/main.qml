import QtQuick 2.2
import QtQuick.Window 2.0

Window {
    id: window
    visible: true
    width: 640
    height: 480
    title: qsTr("Hello World")

    // Simply include it in your project
    ResponsiveHelper {
        appWindow: window
        active: true // Helper can be disabled in production environment

        //position: Qt.LeftEdge
        //distanceFromEdge: 60

        // List the presets (resolution, dpi) shown as shortcuts for your application
        presets: ListModel {
            ListElement { width: 720; height: 1024; dpi: 150}
            ListElement { width: 480; height: 800 }
        }

        // Handle dpi or pixelDensity changes as you wish, instead of "Screen.pixelDensity"
        onDpiChanged: {
            console.log("Dpi set to " + dpi)
        }
        onPixelDensityChanged: {
            console.log("Pixel density set to " + pixelDensity)
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            console.log(qsTr('Clicked on background. Text: "' + textEdit.text + '"'))
        }
    }

    TextEdit {
        id: textEdit
        text: qsTr("Enter some text...")
        verticalAlignment: Text.AlignVCenter
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 20
        Rectangle {
            anchors.fill: parent
            anchors.margins: -10
            color: "transparent"
            border.width: 1
        }
    }
}
