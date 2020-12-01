#!/bin/bash

cp -r ~/.task /opt/root
cp ~/.taskrc /opt/root
cp /opt/output /opt/root

exec "$@"
