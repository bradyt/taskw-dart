import 'package:test/test.dart';

import 'package:taskw/taskw.dart';

void main() {
  test('test validation of task description', () {
    expect(
      () => validateTaskDescription('foo'),
      returnsNormally,
    );
    expect(
      () => validateTaskDescription(r'foo\'),
      throwsException,
    );
    expect(
      () => validateTaskDescription(r'\'),
      throwsException,
    );
  });
}
