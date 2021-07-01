#!/bin/bash

dart --disable-analytics

# toc: https://taskwarrior.org/docs/taskserver/setup.html
cd /opt/fixture
dart pub global activate -spath /opt/taskw
taskd-setup \
    -t /opt/fixture/var/taskd \
    -H /opt/assets \
    -b 0.0.0.0

exec "$@"
