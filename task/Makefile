.PHONY: screenshots

watch:
	flutter analyze --watch

screenshots:
	flutter drive --target=test_driver/screenshots.dart

widget:
	find .. -name '*.dart' | entr -sc 'flutter test --coverage && genhtml -o coverage coverage/lcov.info'
