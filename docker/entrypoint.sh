#!/bin/bash

dart --disable-analytics

# toc: https://taskwarrior.org/docs/taskserver/setup.html
cp /opt/fixture/setup.dart /opt/setup.dart
dart /opt/setup.dart

exec "$@"
