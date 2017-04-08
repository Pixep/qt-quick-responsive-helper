TEMPLATE = app

QT += qml quick
CONFIG += c++11

SOURCES += main.cpp
RESOURCES += qml.qrc

OTHER_FILES += \
    ../ResponsiveHelper.qml \
    main.qml

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target
