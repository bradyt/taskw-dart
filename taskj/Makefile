.PHONY: test coverage

analyze: pubspec.lock
	find . -name '*.dart' -o -name '*.yaml' | entr -cs 'dart analyze'

test: pubspec.lock
	find . -name '*.dart' -o -name '*.yaml' | entr -cs 'dart test'

pubspec.lock:
	dart pub get

watch:
	dart run build_runner watch

coverage:
	find . -name '*.dart' -o -name '*.yaml' | entr -cs 'dart run test_coverage --no-badge --min-coverage=99; genhtml -o coverage coverage/lcov.info'

install:
	dart pub global activate -spath .

docs: pubspec.lock
	find . -name '*.dart' | entr -cs 'dartdoc'
