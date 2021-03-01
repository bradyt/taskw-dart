.PHONY: test coverage

default: test

format:
	find . -name '*.dart' | entr -cs 'dart format --output=none --set-exit-if-changed .'

analyze:
	find . -name '*.dart' | entr -cs 'dart analyze .'

test: pubspec.lock
	find . -name '*.dart' | entr -cs 'dart run test'

pubspec.lock:
	dart pub get
