import QtQuick 2.2

Rectangle {
    color: "darkgrey"
    width: 100
    height: 30

    property string text: ""
    signal clicked

    Text {
        text: parent.text
        anchors.centerIn: parent
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            parent.clicked()
        }
    }
}
