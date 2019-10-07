//-------------------------------------------------
// This file is available under the MIT license.
// For more information, refer to "https://github.com/Pixep/qt-quick-responsive-helper"
// Copyright 2017-2019, Adrien Leravat
//-------------------------------------------------

import QtQuick 2.2
import QtQuick.Window 2.0

Item {
    id: root
    width: defaultBarWidth
    height: 0

    //**********************
    // Public input properties
    //
    // Load or unloads the helper window
    property bool active: true

    // Window element of the target application to test
    property Window targetWindow
    property Item rootItem

    // Shows or hide responsive toolbar
    property bool showResponiveToolbar: true

    // List of presets to display
    property ListModel presets: ListModel {
        ListElement { label: "Galaxy Note 9"; width: 1440; height: 2960; dpi: 516}
        ListElement { label: "Galaxy S7"; width: 1440; height: 2560; dpi: 577}
        ListElement { label: "Galaxy S5"; width: 1080; height: 1920; dpi: 432}
        ListElement { label: "iPhone 6/7"; width: 750; height: 1334; dpi: 326}
        ListElement { label: "Galaxy S3"; width: 720; height: 1280; dpi: 306}
    }
    // Index of the initial preset used
    property int initialPreset: -1
    // Current preset index
    property int currentPreset: -1

    // Portrait or Landscape orientation
    readonly property int portraitMode: 0
    readonly property int landscapeMode: 1
    readonly property int orientation:
            (d.currentHeight > d.currentWidth)
                ? portraitMode
                : landscapeMode

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
    readonly property int dpi: pixelDensity * d.pixelDensityToPpiRatio

    // Initial application window settings
    readonly property int initialWidth: d.initialWidth
    readonly property int initialHeight: d.initialHeight
    readonly property int initialPixelDensity: d.initialPixelDensity

    // Current width/height
    readonly property int currentWidth: d.currentWidth
    readonly property int currentHeight: d.currentHeight

    // Bar width
    readonly property int defaultBarWidth: 125

    //**********************
    // Signals
    //
    signal actionClicked(int actionIndex)

    //**********************
    // Public functions
    //
    function setDpi(dpiValue) {
        pixelDensity = dpiValue / d.pixelDensityToPpiRatio;
    }

    function setWindowWidth(value) {
        var width = (1*value).toFixed(0);
        d.applyWindowSize(width, d.currentHeight)
    }

    function setWindowHeight(value) {
        var height = (1*value).toFixed(0);
        d.applyWindowSize(d.currentWidth, height)
    }

    //**********************
    // Internal logic
    //
    onTargetWindowChanged: {
        if (initialPreset >= 0) {
            d.setPreset(initialPreset);
        }

        d.initialWidth = targetWindow.width;
        d.currentWidth = targetWindow.width;
        d.initialHeight = targetWindow.height;
        d.currentHeight = targetWindow.height;
        d.initialPixelDensity = root.pixelDensity;
    }

    onDpiChanged: {
        var preset = presets.get(root.currentPreset);
        if (preset && root.dpi !== preset.dpi)
            root.currentPreset = -1
    }

    onCurrentPresetChanged: {
        d.setPreset(currentPreset);
    }

    QtObject {
        id: d
        readonly property real pixelDensityToPpiRatio: 25.4
        property int initialWidth
        property int initialHeight
        property real initialPixelDensity: Screen.pixelDensity
        property real initialDpi: initialPixelDensity * pixelDensityToPpiRatio

        property int currentWidth
        property int currentHeight

        property int lastPresetSelected: root.initialPreset

        property real widthMaxScale: 1
        property real heightMaxScale: 1

        property int textHeight: 20
        readonly property real sizeIncrementFactor: 1.1;

        function updateCurrentPreset() {
            var preset = presets.get(root.currentPreset);
            if (!preset || (targetWindow.width !== preset.width || targetWindow.height !== preset.height)) {
                for (var i = 0; i < presets.count; ++i) {
                    var p = presets.get(i)
                    if (p.width === targetWindow.width && p.height === targetWindow.height) {
                        root.currentPreset = i
                        return
                    }
                }
                root.currentPreset = -1
            }
        }

        function setPreset(index) {
            if (index < 0 || index > presets.count-1) {
                return;
            }

            if (root.currentPreset !== index) {
                root.currentPreset = index
                return;
            }

            applyWindowSize(presets.get(index).width, presets.get(index).height);

            if (presets.get(index).dpi)
                setDpi(presets.get(index).dpi)
            else
                setDpi(d.initialDpi)
        }

        function applyWindowSize(width, height) {
            var previousWindowWidth = targetWindow.width;
            var previousWindowX = targetWindow.x;

            if (root.rootItem) {
                var maxSizeFactor = 0.85;
                if (width > maxSizeFactor * Screen.width) {
                    d.widthMaxScale = (maxSizeFactor * Screen.width / width);
                } else {
                    d.widthMaxScale = 1;
                }

                if (height > maxSizeFactor * Screen.height) {
                    d.heightMaxScale = (maxSizeFactor * Screen.height / height);
                } else {
                    d.heightMaxScale = 1;
                }

                var scale = Math.min(d.widthMaxScale, d.heightMaxScale);
                var actualWidth = scale * width;
                var actualHeight = scale * height;

                if (targetWindow.x + actualWidth > Screen.width) {
                    targetWindow.x = (Screen.width - actualWidth) / 2;
                }
                if (targetWindow.y + actualHeight > Screen.height) {
                    targetWindow.y = (Screen.height - actualHeight) / 2;
                }

                targetWindow.width = actualWidth;
                targetWindow.height = actualHeight;
                root.rootItem.scale = scale;
                root.rootItem.width = width;
                root.rootItem.height = height;
            } else {
                targetWindow.width = width;
                targetWindow.height = height;
            }

            var widthDelta = targetWindow.width - previousWindowWidth;

            // Move the application window to keep our window at the same spot when possible
            if (root.x < targetWindow.x / 2) {
                var availableSpace = Screen.width - previousWindowX - previousWindowWidth;
                if (widthDelta > 0 && availableSpace <= widthDelta)
                    targetWindow.x -= widthDelta - availableSpace;
            }
            else {
                if (widthDelta < 0)
                    targetWindow.x -= widthDelta;
                else if (previousWindowX > 0)
                    targetWindow.x = Math.max(0, previousWindowX - widthDelta);
            }

            d.currentWidth = width;
            d.currentHeight = height;
        }
    }

    Connections {
        target: targetWindow
        onWidthChanged: { d.updateCurrentPreset() }
        onHeightChanged: { d.updateCurrentPreset() }
    }

    Loader {
        active: root.active && root.targetWindow
        sourceComponent: responsiveHelperComponent
    }

    Column {
        id: extraContentColumn
        width: parent.width
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
            x: targetWindow.x + root.x + windowOffset.x
            y: targetWindow.y + root.y + windowOffset.y
            width: root.width
            height: root.height
            color: "#202020"
            flags: Qt.FramelessWindowHint
            contentItem.opacity: handleMouseArea.pressed ? 0.3 : 1

            property point windowOffset: Qt.point(0, 0)

            Component.onCompleted: {
                root.width = Qt.binding(function() { return barColumn.width; });
                root.height = Qt.binding(function() { return barColumn.height; });
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
                width: root.width

                Component.onCompleted: {
                    extraContentColumn.parent = barColumn
                    extraContentColumn.visible = true
                }

                MouseArea {
                    id: handleMouseArea
                    width: parent.width
                    height: 20

                    property point originMousePosition

                    onPressed: {
                        originMousePosition.x = mouseX
                        originMousePosition.y = mouseY
                    }
                    onReleased: {
                        helperWindow.windowOffset.x += mouseX - originMousePosition.x
                        helperWindow.windowOffset.y += mouseY - originMousePosition.y
                    }

                    Grid {
                        anchors.centerIn: parent
                        columns: 5
                        rows: 2
                        spacing: 3
                        Repeater { model: 10; Rectangle { width: 4; height: width; radius: width/2 } }
                    }
                }

                @Button {
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

                //***************************************************************************
                // Responsive-related settings
                //
                Column {
                    width: parent.width
                    height: visible ? childrenRect.height : 0
                    visible: root.showResponiveToolbar
                    spacing: 1

                    @Button {
                        width: parent.width
                        text: (root.orientation === root.portraitMode) ? "Portrait"
                                                                       : "Landscape"
                        onClicked: {
                            d.applyWindowSize(d.currentHeight, d.currentWidth);
                        }
                    }

                    @Button {
                        text: "Reset"
                        width: parent.width
                        onClicked: {
                            d.applyWindowSize(d.initialWidth, d.initialHeight);
                            root.pixelDensity = d.initialPixelDensity;
                            d.lastPresetSelected = -1;
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
                        spacing: 1

                        @Button {
                            height: dpiEdit.height
                            width: parent.width / 4
                            text: "-"
                            onClicked: {
                                root.pixelDensity /= 1.3
                            }
                        }
                        @TextField {
                            id: dpiEdit
                            width: parent.width / 2
                            text: root.dpi.toFixed(0)
                            minimum: 1
                            maximum: 999
                            onEditingFinished: {
                                root.setDpi(value)
                            }
                        }

                        @Button {
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
                        spacing: 1

                        @Button {
                            height: widthEdit.height
                            width: parent.width / 4
                            text: "-"
                            onClicked: {
                                root.setWindowWidth(d.currentWidth / d.sizeIncrementFactor)
                            }
                        }
                        @TextField {
                            id: widthEdit
                            width: parent.width / 2
                            minimum: 10
                            maximum: 5000
                            text: d.currentWidth

                            onEditingFinished: {
                                root.setWindowWidth(value)
                            }
                        }

                        @Button {
                            height: widthEdit.height
                            width: parent.width / 4
                            text: "+"
                            onClicked: {
                                root.setWindowWidth(d.currentWidth * d.sizeIncrementFactor)
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
                        spacing: 1

                        @Button {
                            height: heightEdit.height
                            width: parent.width / 4
                            text: "-"
                            onClicked: {
                                root.setWindowHeight(d.currentHeight / d.sizeIncrementFactor)
                            }
                        }
                        @TextField {
                            id: heightEdit
                            width: parent.width / 2
                            text: d.currentHeight
                            minimum: 10
                            maximum: 5000

                            onEditingFinished: {
                                root.setWindowHeight(value)
                            }
                        }

                        @Button {
                            height: heightEdit.height
                            width: parent.width / 4
                            text: "+"
                            onClicked: {
                                root.setWindowHeight(d.currentHeight * d.sizeIncrementFactor)
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

                        @Button {
                            width: parent.width
                            text: {
                                var label = "";
                                if (model.label) {
                                    label = model.label;
                                } else {
                                    label = model.width + " x " + model.height;

                                    if (model.dpi)
                                        label += " (" + model.dpi + "dpi)";
                                }

                                return label;
                            }
                            selected: d.lastPresetSelected === index
                            onClicked: {
                                root.currentPreset = index;
                                d.lastPresetSelected = index;
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
                    visible: root.actions.count > 0
                }

                Repeater {
                    model: root.actions

                    @Button {
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
