.PHONY: test coverage

analyze: pubspec.lock
	find . -name '*.dart' -o -name '*.yaml' | entr -cs 'dart analyze'

test: pubspec.lock
	find . -name '*.dart' -o -name '*.yaml' | entr -cs 'dart test'

pubspec.lock:
	dart pub get

coverage:
	find . -name '*.dart' -o -name '*.yaml' | entr -cs 'dart run test_coverage --no-badge --min-coverage=99; genhtml -o coverage coverage/lcov.info'
