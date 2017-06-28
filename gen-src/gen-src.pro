TEMPLATE = aux
OBJECTS_DIR = ./
DESTDIR = ./

system(python combine-qml.py)

OTHER_FILES = \
    combine-qml.py \
    Button.qml \
    TextField.qml

DISTFILES += \
    ResponsiveHelper-base.qml
