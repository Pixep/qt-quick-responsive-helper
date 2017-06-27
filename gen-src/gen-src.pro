TEMPLATE = aux
OBJECTS_DIR = ./
DESTDIR = ./

system(python combine-qml.py)

OTHER_FILES = \
    combine-qml.py \
    ResponsiveHelper.original.qml \
    Button.qml
