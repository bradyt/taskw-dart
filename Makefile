watch: pub_get
	flutter analyze --watch

analyze: pub_get
	dart analyze

pub_get: taskw/pubspec.lock task/.packages

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
