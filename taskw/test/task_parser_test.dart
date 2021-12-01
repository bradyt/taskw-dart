import 'package:test/test.dart';

import 'package:taskw/taskw.dart';

void main() {
  test('Test empty string', () {
    expect(
      () => taskParser(''),
      throwsA(isA<FormatException>()),
    );
  });
  test('Test empty description', () {
    expect(
      () => taskParser('+foo'),
      throwsA(isA<FormatException>()),
    );
  });
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
    expect(task.description, 'foo & Garden\' bar');
    expect(task.project, '\'Home');
  });
  test('Test quoted description parts', () {
    var task = taskParser('\'foo +bar\' +baz pri:H quux');
    expect(task.description, '\'foo quux');
    expect(task.tags, ['bar\'', 'baz']);
    expect(task.priority, 'H');
  });
  test('Test parser silently dropping attribute-like use of colon', () {
    var task = taskParser('Blog: Test');
    expect(task.description, 'Blog: Test');
  });
  test('Test parser for single quote wrapped in double quotes', () {
    var task = taskParser('"don\'t break on quotes"');
    expect(task.description, '"don\'t break on quotes"');
  });
  test('Test failing on single quote', () {
    var task = taskParser('don\'t silently drop apostrophe');
    expect(task.description, 'don\'t silently drop apostrophe');
  });
}
