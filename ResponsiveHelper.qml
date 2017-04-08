import QtQuick 2.2
import QtQuick.Window 2.0
import QtQuick.Controls 1.0

Window {
    id: root
    visible: true
    x: appWindow.x + appWindow.width + 20
    y: appWindow.y
    width: column.width
    height: column.height
    color: "#202020"
    flags: Qt.FramelessWindowHint

    //**********************
    // Public input properties
    //
    property Window appWindow
    property ListModel resolutions: ListModel {
        ListElement { width: 480; height: 800 }
        ListElement { width: 1024; height: 720 }
    }

    //**********************
    // Public properties
    //
    readonly property int initialWidth: d.initialWidth
    readonly property int initialHeight: d.initialHeight
    readonly property int initialPixelDensity: d.initialPixelDensity

    property real pixelDensity: Screen.pixelDensity
    readonly property real dpi: pixelDensity * 25.4

    //**********************
    // Public functions
    //
    function resetPixelDensity() {
        pixelDensity = Screen.pixelDensity;
    }

    function setDpi(dpiValue) {
        pixelDensity = dpiValue / 25.4;
    }

    function setWindowWidth(value) {
        var newWidth = (1*value).toFixed(0);
        var diff = value - appWindow.width;
        if (diff < 0 || (diff > 0 && appWindow.x > diff))
            appWindow.x -= diff;

        appWindow.width = value;
    }

    function setWindowHeight(value) {
        appWindow.height = value;
    }

    //**********************
    // Internal logic
    //
    onAppWindowChanged: {
        d.initialWidth = appWindow.width;
        d.initialHeight = appWindow.height;
        d.initialPixelDensity = Screen.pixelDensity;

        dpiEdit.bind();
        widthEdit.bind();
        heightEdit.bind();
    }

    QtObject {
        id: d
        property int initialWidth
        property int initialHeight
        property int initialPixelDensity

        property int textHeight: 30
    }

    Connections {
        target: appWindow
        onClosing: {
            root.close();
        }
        onActiveChanged: {
            root.raise();
        }
    }

    //**********************
    // GUI
    //
    Column {
        id: column
        spacing: 1
        width: 100

        Button {
            text: "Close"
            width: parent.width
            onClicked: {
                root.close()
            }
        }

        Button {
            text: "Reset"
            width: parent.width
            onClicked: {
                root.setWindowWidth(d.initialWidth)
                root.setWindowHeight(d.initialHeight)
                root.pixelDensity = d.initialPixelDensity
            }
        }

        Text {
            text: "DPI"
            color: "white"
            height: d.textHeight
            width: parent.width
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        Row {
            width: parent.width
            height: childrenRect.height
            spacing: 0

            Button {
                height: dpiEdit.height
                width: parent.width / 4
                text: "-"
                onClicked: {
                    root.pixelDensity /= 1.3
                }
            }
            TextField {
                id: dpiEdit
                width: parent.width / 2
                text: "N/A"
                validator: IntValidator {bottom: 1; top: 999;}
                horizontalAlignment: Text.AlignHCenter

                Component.onCompleted: {
                    bind();
                }
                onEditingFinished: {
                    root.setDpi(text)
                    bind();
                }
                Keys.onEscapePressed: {
                    bind();
                    focus = false
                }

                function bind() {
                    text = Qt.binding(function() { return root.dpi.toFixed(0) } )
                }
            }

            Button {
                height: dpiEdit.height
                width: parent.width / 4
                text: "+"
                onClicked: {
                    root.pixelDensity *= 1.3
                }
            }
        }

        Text {
            text: "Width"
            color: "white"
            height: d.textHeight
            width: parent.width
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        Row {
            id: row
            width: parent.width
            height: childrenRect.height
            spacing: 0

            Button {
                height: widthEdit.height
                width: parent.width / 4
                text: "-"
                onClicked: {
                    root.setWindowWidth(appWindow.width / 1.1)
                }
            }
            TextField {
                id: widthEdit
                width: parent.width / 2
                text: "N/A"
                validator: IntValidator {bottom: 10; top: 5000;}
                horizontalAlignment: Text.AlignHCenter

                Component.onCompleted: {
                    bind();
                }
                onEditingFinished: {
                    root.setWindowWidth(text)
                    bind();
                }
                Keys.onEscapePressed: {
                    bind();
                    focus = false
                }

                function bind() {
                    text = Qt.binding(function() { return appWindow.width } )
                }
            }

            Button {
                height: widthEdit.height
                width: parent.width / 4
                text: "+"
                onClicked: {
                    root.setWindowWidth(appWindow.width * 1.1)
                }
            }
        }

        Text {
            text: "Height"
            color: "white"
            width: parent.width
            height: d.textHeight
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        Row {
            width: parent.width
            height: childrenRect.height
            spacing: 0

            Button {
                height: heightEdit.height
                width: parent.width / 4
                text: "-"
                onClicked: {
                    root.setWindowHeight(appWindow.height / 1.1)
                }
            }
            TextField {
                id: heightEdit
                width: parent.width / 2
                text: "N/A"
                validator: IntValidator {bottom: 10; top: 5000;}
                horizontalAlignment: Text.AlignHCenter

                Component.onCompleted: {
                    bind();
                }
                onEditingFinished: {
                    root.setWindowHeight(text)
                    bind();
                }
                Keys.onEscapePressed: {
                    bind();
                    focus = false
                }

                function bind() {
                    text = Qt.binding(function() { return appWindow.height } )
                }
            }

            Button {
                height: heightEdit.height
                width: parent.width / 4
                text: "+"
                onClicked: {
                    root.setWindowHeight(appWindow.height * 1.1)
                }
            }
        }

        Button {
            width: parent.width
            text: (appWindow.height > appWindow.width) ? "Landscape" : "Portrait"
            onClicked: {
                var height = appWindow.height
                root.setWindowHeight(appWindow.width)
                root.setWindowWidth(height)
            }
        }

        Text {
            text: "Sizes"
            width: parent.width
            height: d.textHeight
            color: "white"
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        Repeater {
            model: root.resolutions

            Button {
                width: parent.width
                text: model.width + " x " + model.height
                onClicked: {
                    root.setWindowWidth(model.width)
                    root.setWindowHeight(model.height)
                }
            }
        }
    }
}
