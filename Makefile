.PHONY: test

default: test

format:
	find . -name '*.dart' | entr -cs 'dart format --output=none --set-exit-if-changed .'

analyze:
	find . -name '*.dart' | entr -cs 'dart analyze .'

test:
	find . -name '*.dart' | entr -cs 'dart pub run test'
