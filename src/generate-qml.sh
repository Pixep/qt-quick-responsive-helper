#!/bin/bash

DIR="$( cd "$( dirname "$0" )" && pwd )"
python2 ${DIR}/combine-qml/combine-qml.py ${DIR}/ResponsiveHelper-base.qml ${DIR}/../ResponsiveHelper.qml -c ${DIR}/Button.qml Button -c ${DIR}/TextField.qml TextField
