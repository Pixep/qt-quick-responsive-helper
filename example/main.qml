import QtQuick 2.3
import QtQuick.Window 2.2

Window {
    id: window
    visible: true
    width: 640
    height: 480
    title: qsTr("Hello World")

    // Simply include it in your project
    ResponsiveHelper {
        appWindow: window
        active: true // Can be disabled in production environment

        // List your favorite resolutions to test your application
        resolutions: ListModel {
            ListElement { width: 720; height: 1024 }
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
