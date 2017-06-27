import QtQuick 2.2

Rectangle {
    color: "#555"
    width: 100
    height: 30

    property string text: ""
    signal clicked

    Text {
        text: parent.text
        anchors.centerIn: parent
        color: "#EEE"
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            parent.clicked()
        }
        onPressed: {
            parent.color = "#999"
        }
        onReleased: {
            parent.color = "#555"
        }
    }
}
