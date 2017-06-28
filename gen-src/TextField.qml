import QtQuick 2.2

Rectangle {
    color: "#555"
    width: 100
    height: 30

    signal discarded()
    signal editingFinished(string value)

    property string text
    property int minimum: 0
    property int maximum: 5000

    TextInput {
        anchors.fill: parent
        horizontalAlignment: TextEdit.AlignHCenter
        verticalAlignment: TextEdit.AlignVCenter
        color: "#EEE"
        validator: IntValidator{bottom: 0; top: 5000;}
        property Item componentRoot: parent

        onFocusChanged: {
            parent.color = focus ? "#999" : "#555"

            if (!focus) {
                parent.text = text
                validated(text)
            }
        }
        Component.onCompleted: {
            bind()
        }
        Keys.onEscapePressed: {
            bind()
        }
        onEditingFinished: {
            parent.editingFinished(text)
            bind()
        }
        function bind() {
            text = Qt.binding(function() { return parent.text } )
        }
    }
}
