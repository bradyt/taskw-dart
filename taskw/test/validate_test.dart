import 'package:test/test.dart';

import 'package:taskw/taskw.dart';

void main() {
  test('test validation', () {
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
    expect(
      () => validateTaskDescription('hello\nworld'),
      returnsNormally,
    );
    expect(
      () => validateTaskProject(r'foo\'),
      throwsException,
    );
    expect(
      () => validateTaskTags('do not'),
      throwsException,
    );
  });
}
