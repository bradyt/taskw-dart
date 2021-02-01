analyze: taskw/pubspec.lock
	find . -name '*.dart' -o -name '*.yaml' | entr -cs 'dart analyze'

taskw/pubspec.lock:
	cd taskw && dart pub get
