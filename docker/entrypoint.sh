#!/bin/bash

cp -r ~/.task /opt/home
cp ~/.taskrc /opt/home
cp /opt/output /opt/home

exec "$@"
