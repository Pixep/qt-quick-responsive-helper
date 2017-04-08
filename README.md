# Qt Quick Responsive Helper
A small window for QtQuick based applications to help developers test with different resolutions and dpi settings. It was made to be integrated with minimal effort (one QML file), and to be configurable for your specific usage.

## Installation ##
Clone or simply copy the `ResponsiveHelper.qml` file to your project's qml files

## Minimal working example ##
Just drop it in your project, and set the `appWindow` property to be the Window instance of your application

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

        // List your favorite resolutions to test your application
        resolutions: ListModel {
            ListElement { width: 720; height: 1024 }
            ListElement { width: 480; height: 800 }
        }

        // Handle dpi or pixelDensity changes as you wish, instead of "Screen.pixelDensity"
        onDpiChanged: { }
        onPixelDensityChanged: { }
    }
}
```
