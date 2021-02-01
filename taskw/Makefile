.PHONY: test

test: pubspec.lock
	find . -name '*.dart' -o -name '*.yaml' | entr -cs 'dart test'

analyze: pubspec.lock
	find . -name '*.dart' -o -name '*.yaml' | entr -cs 'dart analyze'

pubspec.lock:
	dart pub get
