analyze:
	find . -name '*.dart' -o -name '*.yaml' | entr -cs 'dart analyze'
