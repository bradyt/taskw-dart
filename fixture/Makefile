run:
	TASKDDATA=./var/taskd taskd server --debug

setup:
	taskd-setup

android:
	taskd-setup --CN=10.0.2.2 --address=127.0.0.1

install:
	dart pub global activate -sgit https://github.com/bradyt/taskd-setup-dart.git
