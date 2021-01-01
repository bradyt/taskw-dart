#!/bin/bash

dart --disable-analytics

# toc: https://taskwarrior.org/docs/taskserver/setup.html
cd /opt/fixture
dart pub get
dart setup.dart

exec "$@"
