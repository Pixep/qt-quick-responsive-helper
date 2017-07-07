TEMPLATE = aux
OBJECTS_DIR = ./
DESTDIR = ./

system(python combine-qml/combine-qml.py ResponsiveHelper-base.qml ../ResponsiveHelper.qml -c Button.qml Button -c TextField.qml TextField)

OTHER_FILES = \
    generate.py \
    Button.qml \
    TextField.qml

DISTFILES += \
    ResponsiveHelper-base.qml
