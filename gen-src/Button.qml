import QtQuick 2.2

Rectangle {
    color: baseColor
    width: 100
    height: 30

    property string text: ""
    property bool selected: false
    property color baseColor: "#555"

    signal clicked

    Rectangle {
        anchors.fill: parent
        color: "#FFF"
        opacity: 0.3
        visible: parent.selected
    }

    Text {
        text: parent.text
        anchors.centerIn: parent
        color: parent.selected ? "#FFF" : "#EEE"
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            parent.clicked()
        }
        onPressed: {
            parent.color = Qt.lighter(parent.baseColor)
        }
        onReleased: {
            parent.color = parent.baseColor
        }
    }
}
