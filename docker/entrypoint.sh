#!/bin/bash

# toc: https://taskwarrior.org/docs/taskserver/setup.html

# 3: https://taskwarrior.org/docs/taskserver/configure.html

cd /opt/

export TASKDDATA=/var/taskd

cp fixture/pki/client.cert.pem $TASKDDATA
cp fixture/pki/client.key.pem  $TASKDDATA
cp fixture/pki/server.cert.pem $TASKDDATA
cp fixture/pki/server.key.pem  $TASKDDATA
cp fixture/pki/server.crl.pem  $TASKDDATA
cp fixture/pki/ca.cert.pem     $TASKDDATA

# 4: https://taskwarrior.org/docs/taskserver/user.html

taskd add org Public
taskd add user 'Public' 'First Last'

# 4: https://taskwarrior.org/docs/taskserver/taskwarrior.html

cp    fixture/.taskrc.template ~/.taskrc
cp -r fixture/.task            ~/

task rc.confirmation:no config confirmation -- no
task config taskd.credentials -- Public/First Last/`ls $TASKDDATA/orgs/Public/users`
task config confirmation      -- yes

cp ~/.taskrc fixture

task rc.confirmation:no config confirmation -- no
task config taskd.certificate -- ~/.task/first_last.cert.pem
task config taskd.key         -- ~/.task/first_last.key.pem
task config taskd.ca          -- ~/.task/ca.cert.pem
task config confirmation      -- yes

exec "$@"
