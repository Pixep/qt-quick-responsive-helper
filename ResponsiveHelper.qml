import QtQuick 2.2
import QtQuick.Window 2.0
import QtQuick.Controls 1.0

Item {
    id: root
    width: 0
    height: 0

    //**********************
    // Public input properties
    //
    // Load or unloads the helper window
    property bool active: true

    // Window element of the target application to test
    property Window targetWindow

    // Shows or hide responsive toolbar
    property bool showResponiveToolbar: true

    // List of presets to display
    property ListModel presets: ListModel {}
    // Index of the initial preset used
    property int initialPreset: -1
    // Current preset index
    property int currentPreset: -1

    // List of custom actions
    property ListModel actions: ListModel {}

    // List of custom actions
    property alias extraContent: extraContentColumn.children

    //**********************
    // Public properties
    //
    // Custom pixel density value
    property real pixelDensity: Screen.pixelDensity
    // Custom DPI value
    readonly property int dpi: pixelDensity * 25.4

    // Initial application window settings
    readonly property int initialWidth: d.initialWidth
    readonly property int initialHeight: d.initialHeight
    readonly property int initialPixelDensity: d.initialPixelDensity

    // Bar width
    readonly property int barWidth: 125

    //**********************
    // Signals
    //
    signal actionClicked(int actionIndex)

    //**********************
    // Public functions
    //
    function setDpi(dpiValue) {
        pixelDensity = dpiValue / 25.4;
    }

    function setWindowWidth(value) {
        var newWidth = (1*value).toFixed(0);
        var diff = value - targetWindow.width;

        // Move the application window to keep our window at the same spot when possible
        if (root.x < targetWindow.x / 2) {
            var availableSpace = Screen.desktopAvailableWidth - targetWindow.x - targetWindow.width;
            if (diff > 0 && availableSpace <= diff)
                targetWindow.x -= diff - availableSpace;
        }
        else {
            if (diff < 0)
                targetWindow.x -= diff;
            else if (targetWindow.x > 0)
                targetWindow.x = Math.max(0, targetWindow.x - diff)
        }

        targetWindow.width = value;
    }

    function setWindowHeight(value) {
        targetWindow.height = value;
    }

    //**********************
    // Internal logic
    //
    onTargetWindowChanged: {
        if (initialPreset >= 0) {
            d.setPreset(initialPreset);
        }

        d.initialWidth = targetWindow.width;
        d.initialHeight = targetWindow.height;
        d.initialPixelDensity = root.pixelDensity;
    }

    onDpiChanged: {
        var preset = presets.get(root.currentPreset);
        if (preset && targetWindow.dpi !== preset.dpi)
            root.currentPreset = -1
    }

    onCurrentPresetChanged: {
        d.setPreset(currentPreset);
    }

    QtObject {
        id: d
        property int initialWidth
        property int initialHeight
        property real initialPixelDensity: Screen.pixelDensity

        property int textHeight: 20

        function setPreset(index) {
            if (index < 0 || index > presets.count-1) {
                return;
            }

            if (root.currentPreset !== index) {
                root.currentPreset = index
                return;
            }

            setWindowWidth(presets.get(index).width)
            setWindowHeight(presets.get(index).height)

            if (presets.get(index).dpi)
                setDpi(presets.get(index).dpi)
        }
    }

    Connections {
        target: targetWindow
        onWidthChanged: {
            var preset = presets.get(root.currentPreset);
            if (preset && targetWindow.width !== preset.width)
                root.currentPreset = -1
        }
        onHeightChanged: {
            var preset = presets.get(root.currentPreset);
            if (preset && targetWindow.height !== preset.height)
                root.currentPreset = -1
        }
    }

    Loader {
        active: root.active && root.targetWindow
        sourceComponent: responsiveHelperComponent
    }

    Column {
        id: extraContentColumn
        visible: false
    }

    //**********************
    // GUI
    //
    Component {
        id: responsiveHelperComponent

        Window {
            id: helperWindow
            visible: true
            x: targetWindow.x + root.x
            y: targetWindow.y + root.y
            width: root.width
            height: root.height
            color: "#202020"
            flags: Qt.FramelessWindowHint

            Component.onCompleted: {
                if (root.width === 0)   root.width = Qt.binding(function() { return barColumn.width; });
                if (root.height === 0)  root.height = Qt.binding(function() { return barColumn.height; });
            }

            Connections {
                target: targetWindow
                onClosing: {
                    helperWindow.close();
                }
                onActiveChanged: {
                    helperWindow.raise();
                }
            }

            Connections {
                target: root
                onTargetWindowChanged: {
                    dpiEdit.bind();
                    widthEdit.bind();
                    heightEdit.bind();
                }
            }

            Column {
                id: barColumn
                spacing: 1
                width: root.barWidth

                Component.onCompleted: {
                    extraContentColumn.parent = barColumn
                    extraContentColumn.visible = true
                }

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

                Column {
                    width: parent.width
                    height: visible ? childrenRect.height : 0
                    visible: root.showResponiveToolbar

                    Button {
                        width: parent.width
                        text: (targetWindow.height > targetWindow.width) ? "Landscape" : "Portrait"
                        onClicked: {
                            var height = targetWindow.height
                            root.setWindowHeight(root.targetWindow.width)
                            root.setWindowWidth(height)
                        }
                    }

                    //**********************
                    // DPI
                    //
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

                    //**********************
                    // Width
                    //
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
                                root.setWindowWidth(root.targetWindow.width / 1.1)
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
                                text = Qt.binding(function() { return root.targetWindow.width } )
                            }
                        }

                        Button {
                            height: widthEdit.height
                            width: parent.width / 4
                            text: "+"
                            onClicked: {
                                root.setWindowWidth(root.targetWindow.width * 1.1)
                            }
                        }
                    }

                    //**********************
                    // Height
                    //
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
                                root.setWindowHeight(root.targetWindow.height / 1.1)
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
                                text = Qt.binding(function() { return root.targetWindow.height } )
                            }
                        }

                        Button {
                            height: heightEdit.height
                            width: parent.width / 4
                            text: "+"
                            onClicked: {
                                root.setWindowHeight(root.targetWindow.height * 1.1)
                            }
                        }
                    }

                    //**********************
                    // Presets
                    //
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

                                if (root.currentPreset === index)
                                    return "[" + label + "]";

                                return label;
                            }
                            onClicked: {
                                root.currentPreset = index;
                            }
                        }
                    }
                }

                //**********************
                // Actions & Buttons
                //
                Text {
                    text: "Actions"
                    width: parent.width
                    height: d.textHeight
                    color: "white"
                    wrapMode: Text.Wrap
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignBottom
                    visible: root.actions.count > 0 || root.buttons.length > 0
                }

                Repeater {
                    model: root.actions

                    Button {
                        width: parent.width
                        text: model.text
                        onClicked: {
                            root.actionClicked(index);
                        }
                    }
                }
            }
        }
    }
}
