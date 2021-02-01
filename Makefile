analyze: taskw/pubspec.lock task/.packages
	find . -name '*.dart' -o -name '*.yaml' | entr -cs 'dart analyze'

taskw/pubspec.lock:
	cd taskw && dart pub get

task/.packages:
	cd task && dart pub get
