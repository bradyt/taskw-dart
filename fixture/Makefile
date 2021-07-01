.PHONY: android

run:
	TASKDDATA=./var/taskd taskd server --debug

android:
	TASKDDATA=./android/var/taskd taskd server --debug

setup:
	taskd-setup -t $(PWD)/var/taskd -H $(PWD)/../task/assets

setup-android:
	taskd-setup -t $(PWD)/android/var/taskd -H $(PWD)/../task/assets --binding-address=127.0.0.1 --client-address=10.0.2.2

install:
	dart pub global activate -spath ../taskw
