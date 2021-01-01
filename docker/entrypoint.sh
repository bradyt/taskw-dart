#!/bin/bash

dart --disable-analytics

# toc: https://taskwarrior.org/docs/taskserver/setup.html
cd /opt/fixture
dart pub global activate -sgit https://github.com/bradyt/taskd-setup-dart.git
taskd-setup

exec "$@"
