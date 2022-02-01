watch: get task/.packages
	flutter analyze --watch

analyze: get
	cd taskc && dart analyze
	cd taskj && dart analyze
	cd taskw && dart analyze

get: taskc/pubspec.lock taskj/pubspec.lock taskw/pubspec.lock

taskc/pubspec.lock:
	cd taskc && dart pub get

taskj/pubspec.lock:
	cd taskj && dart pub get

taskw/pubspec.lock:
	cd taskw && dart pub get

task/.packages:
	cd task && dart pub get

docs: get
	cd taskw && dartdoc .
	cd taskc && dartdoc .
	cd taskj && dartdoc .

format:
	dart format taskc --fix --output none --set-exit-if-changed --summary none
	dart format taskw --fix --output none --set-exit-if-changed --summary none

install:
	dart pub global activate -spath taskc

test: get
	cd taskj && dart test
	cd taskc && dart test -j 1
	cd taskw && dart test

built_value:
	cd taskc && dart run build_runner build
	cd taskj && dart run build_runner build
