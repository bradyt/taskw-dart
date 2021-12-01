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
  test('Test quoted attribute values', () {
    var task = taskParser('foo project:\'Home & Garden\' bar');
    expect(task.description, 'foo bar');
    expect(task.project, 'Home & Garden');
  });
  test('Test quoted description parts', () {
    var task = taskParser('\'foo +bar\' +baz pri:H quux');
    expect(task.description, 'foo +bar quux');
    expect(task.tags, ['baz']);
    expect(task.priority, 'H');
  });
  test('Test parser silently dropping attribute-like use of colon', () {
    var task = taskParser('Blog: Test');
    expect(task.description, 'Blog: Test');
  });
}
