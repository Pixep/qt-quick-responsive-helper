import QtQuick 2.2
Rectangle {
    color: "#555"
    width: 100
    height: 30

    property string text
    property int minimum: 0
    property int maximum: 5000

    signal discarded()
    signal editingFinished(string value)

    TextInput {
        anchors.fill: parent
        horizontalAlignment: TextEdit.AlignHCenter
        verticalAlignment: TextEdit.AlignVCenter
        color: "#EEE"
        font.bold: true
        validator: IntValidator{bottom: 0; top: 5000;}
        property Item componentRoot: parent

        onFocusChanged: {
            parent.color = focus ? "#999" : "#555"
        }
        Component.onCompleted: {
            bind()
            validator.bottom = parent.minimum
            validator.top = parent.maximum
        }
        Keys.onEscapePressed: {
            focus = false
            bind()
        }
        onEditingFinished: {
            focus = false
            parent.editingFinished(text)
            bind()
        }
        function bind() {
            text = Qt.binding(function() { return parent.text } )
        }
    }
}
