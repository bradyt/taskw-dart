#!/bin/bash

task rc.confirmation:no config confirmation -- no

task config taskd.certificate -- docker/home/.task/brady_trainor.cert.pem
task config taskd.key         -- docker/home/.task/brady_trainor.key.pem
task config taskd.ca          -- docker/home/.task/ca.cert.pem

cp -r ~/.task /opt/home
cp ~/.taskrc /opt/home
cp /opt/output /opt/home

task config taskd.certificate -- ~/.task/brady_trainor.cert.pem
task config taskd.key         -- ~/.task/brady_trainor.key.pem
task config taskd.ca          -- ~/.task/ca.cert.pem

task config confirmation -- yes

exec "$@"
