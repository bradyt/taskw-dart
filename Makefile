.PHONY: test

default: test

format:
	find . -name '*.dart' | entr -cs 'dart format --output=none --set-exit-if-changed .'

analyze:
	find . -name '*.dart' | entr -cs 'dart analyze .'

test: pubspec.lock
	find . -name '*.dart' | entr -cs 'dart pub run test'

coverage:
	dart pub run test_coverage --no-badge --min-coverage 98

pubspec.lock:
	dart pub get
