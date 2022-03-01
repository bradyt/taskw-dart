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
	find . -name '*.dart' -o -name '*.yaml' | entr -cs 'dart run test_cov; dart run remove_from_coverage -f coverage/lcov.info -r \.g\.dart; genhtml -o coverage coverage/lcov.info'

install:
	dart pub global activate -spath .

docs: pubspec.lock
	find . -name '*.dart' | entr -cs 'dartdoc'
