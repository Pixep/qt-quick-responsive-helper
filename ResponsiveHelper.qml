import QtQuick 2.2
import QtQuick.Window 2.0
import QtQuick.Controls 1.0

Item {
    id: root

    //**********************
    // Public input properties
    //
    // Load or unloads the helper window
    property bool active: true

    // Window element of the target application to test
    property Window appWindow

    // List of presets to display
    property ListModel presets: ListModel {
        ListElement { width: 480; height: 800; dpi: 150 }
        ListElement { width: 1024; height: 720 }
    }

    // Align helper window on "Qt.LeftEdge" or "Qt.RightEdge" of the application
    property int position: Qt.RightEdge
    // Distance from the edge
    property int distanceFromEdge: 20

    //**********************
    // Public properties
    //
    // Custom pixel density value
    property real pixelDensity: Screen.pixelDensity
    // Custom DPI value
    readonly property real dpi: (pixelDensity * 25.4).toFixed()

    // Initial application window settings
    readonly property int initialWidth: d.initialWidth
    readonly property int initialHeight: d.initialHeight
    readonly property int initialPixelDensity: d.initialPixelDensity

    //**********************
    // Public functions
    //
    function setDpi(dpiValue) {
        pixelDensity = dpiValue / 25.4;
    }

    function setWindowWidth(value) {
        var newWidth = (1*value).toFixed(0);
        var diff = value - appWindow.width;

        // Move the application window to keep our window at the same spot when possible
        if (root.position === Qt.LeftEdge) {
            var availableSpace = Screen.desktopAvailableWidth - appWindow.x - appWindow.width;
            if (diff > 0 && availableSpace <= diff)
                appWindow.x -= diff - availableSpace;
        }
        else {
            if (diff < 0)
                appWindow.x -= diff;
            else if (appWindow.x > 0)
                appWindow.x = Math.max(0, appWindow.x - diff)
        }

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
    }

    QtObject {
        id: d
        property int initialWidth
        property int initialHeight
        property real initialPixelDensity: Screen.pixelDensity

        property int textHeight: 20
    }

    Loader {
        active: root.active && root.appWindow
        sourceComponent: responsiveHelperComponent
    }


    //**********************
    // GUI
    //
    Component {
        id: responsiveHelperComponent

        Window {
            id: helperWindow
            visible: true
            x: {
                if (root.position === Qt.LeftEdge)
                    return appWindow.x - helperWindow.width - root.distanceFromEdge
                else
                    return appWindow.x + appWindow.width + root.distanceFromEdge
            }
            y: appWindow.y
            width: column.width
            height: column.height
            color: "#202020"
            flags: Qt.FramelessWindowHint

            Connections {
                target: appWindow
                onClosing: {
                    helperWindow.close();
                }
                onActiveChanged: {
                    helperWindow.raise();
                }
            }

            Connections {
                target: root
                onAppWindowChanged: {
                    dpiEdit.bind();
                    widthEdit.bind();
                    heightEdit.bind();
                }
            }

            Column {
                id: column
                spacing: 1
                width: 125

                Button {
                    text: "Hide"
                    width: parent.width
                    onClicked: {
                        helperWindow.close()
                    }
                }

                Item {
                    width: parent.width
                    height: 10
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

                Button {
                    width: parent.width
                    text: (appWindow.height > appWindow.width) ? "Landscape" : "Portrait"
                    onClicked: {
                        var height = appWindow.height
                        root.setWindowHeight(root.appWindow.width)
                        root.setWindowWidth(height)
                    }
                }

                Text {
                    text: "DPI"
                    color: "white"
                    height: d.textHeight
                    width: parent.width
                    wrapMode: Text.Wrap
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignBottom
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
                    verticalAlignment: Text.AlignBottom
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
                            root.setWindowWidth(root.appWindow.width / 1.1)
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
                            text = Qt.binding(function() { return root.appWindow.width } )
                        }
                    }

                    Button {
                        height: widthEdit.height
                        width: parent.width / 4
                        text: "+"
                        onClicked: {
                            root.setWindowWidth(root.appWindow.width * 1.1)
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
                    verticalAlignment: Text.AlignBottom
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
                            root.setWindowHeight(root.appWindow.height / 1.1)
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
                            text = Qt.binding(function() { return root.appWindow.height } )
                        }
                    }

                    Button {
                        height: heightEdit.height
                        width: parent.width / 4
                        text: "+"
                        onClicked: {
                            root.setWindowHeight(root.appWindow.height * 1.1)
                        }
                    }
                }

                Text {
                    text: "Presets"
                    width: parent.width
                    height: d.textHeight
                    color: "white"
                    wrapMode: Text.Wrap
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignBottom
                    visible: root.presets.count > 0
                }

                Repeater {
                    model: root.presets

                    Button {
                        width: parent.width
                        text: {
                            var label = model.width + " x " + model.height;
                            if (model.dpi)
                                label += " (" + model.dpi + "dpi)";

                            return label;
                        }
                        onClicked: {
                            root.setWindowWidth(model.width)
                            root.setWindowHeight(model.height)

                            if (model.dpi)
                                root.setDpi(model.dpi)
                        }
                    }
                }
            }
        }
    }
}
