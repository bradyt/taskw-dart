import 'package:test/test.dart';

import 'package:taskw/taskw.dart';

void main() {
  test('test task parser', () {
    var task = taskParser('foo +next pro:diy pri:H baz');
    expect(task.description, 'foo baz');
    expect(task.tags, ['next']);
    expect(task.priority, 'H');
    expect(task.project, 'diy');
  });
  test('test empty attribute', () {
    var task = taskParser('foo pri: baz');
    expect(task.description, 'foo baz');
    expect(task.priority, null);
  });
}
