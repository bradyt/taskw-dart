watch: get
	flutter analyze --watch

analyze: get
	dart analyze

get: taskc/pubspec.lock taskw/pubspec.lock task/.packages

taskc/pubspec.lock:
	cd taskc && dart pub get

taskw/pubspec.lock:
	cd taskw && dart pub get

task/.packages:
	cd task && dart pub get

format:
	dart format \
		$(shell find . \( -name '*.dart' ! -name '*.g.dart' \)) \
		--fix \
		--output none \
		--set-exit-if-changed \
		--summary none

install:
	dart pub global activate -spath taskc
