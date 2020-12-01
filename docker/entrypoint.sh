#!/bin/bash

dart --disable-analytics

# toc: https://taskwarrior.org/docs/taskserver/setup.html
dart /opt/setup.dart

exec "$@"
