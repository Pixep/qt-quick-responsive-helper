# Qt Quick Responsive Helper
A simple helper window for QtQuick based applications, to let developers test different resolutions and dpi settings eaisly. It was made to be integrated with minimal effort (only one QML file), and to be configurable for your specific usage.

Main features:
- Set application width and height
- Set dpi / pixelDensity (without altering Screen.pixelDensity)
- Switch to landscape and portrait mode
- Use presets to quickly test your commonly used settings
- Can be disabled for production with a single property

Compatible with Qt 5.2 and higher.

![Responsive helper window screenshot](http://i.imgur.com/YGlP5Xc.png)

## Installation ##
Clone or simply copy the `ResponsiveHelper.qml` file to your project's qml files.
When cloning the repository, you can build a simple example application from the `example` folder.

## Minimal working example ##
Just drop it in your project, and set the `appWindow` property to be the Window instance of your application:

`main.qml`
```
Window {
    id: window

    ResponsiveHelper {
        appWindow: window
    }
}
```

## QML usage ##
You can add a set of resolutions as shortcuts for a one click change with the `resolutions` property. The element cannot overwrite DPI / pixel density, but let you use the value to stub the usual `Screen.pixelDensity`.

`main.qml`
```
// If you placed it in a folder, relative to your main.qml
import "qt-quick-responsive-helper"

Window {
    id: window
    width: 480
    height: 800

    // Place it in a Loader to avoid loading it in production
    ResponsiveHelper {
        active: true
        appWindow: window

        position: Qt.LeftEdge
        distance: 50

        // List your common presets to be applied to your application
        presets: ListModel {
            ListElement { width: 720; height: 1024; dpi: 150 }
            ListElement { width: 480; height: 800 }
        }

        // Handle dpi or pixelDensity changes as you wish, instead of "Screen.pixelDensity"
        onDpiChanged: { }
        onPixelDensityChanged: { }
    }
}
```
