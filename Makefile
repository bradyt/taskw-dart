watch: get
	flutter analyze --watch

analyze: get
	dart analyze

get: taskw/pubspec.lock task/.packages

taskw/pubspec.lock:
	cd taskw && dart pub get

task/.packages:
	cd task && dart pub get

format:
	dart format . \
		--fix \
		--output none \
		--set-exit-if-changed \
		--summary none

install:
	dart pub global activate -spath taskw
