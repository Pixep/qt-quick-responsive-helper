TEMPLATE = subdirs

SUBDIRS = \
    examples \
    src

OTHER_FILES = \
    ResponsiveHelper.qml

OTHER_FILES += \
    gen-src/ResponsiveHelper.original.qml

#examples.depends = gen-src
