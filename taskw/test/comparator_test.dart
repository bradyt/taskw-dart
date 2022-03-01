import 'package:test/test.dart';

import 'package:built_collection/built_collection.dart';

import 'package:taskj/json.dart';

import 'package:taskw/taskw.dart';

void main() {
  var task = Task(
    (b) => b
      ..description = 'foo'
      ..uuid = 'bar'
      ..status = 'baz'
      ..entry = DateTime.now(),
  );

  Task createTask({DateTime? due, List<String>? tags}) {
    return Task(
      (b) => b
        ..description = 'foo'
        ..uuid = 'bar'
        ..status = 'baz'
        ..entry = DateTime.now()
        ..due = due
        ..tags = (tags == null) ? null : ListBuilder(tags),
    );
  }

  var a = createTask();
  var b = createTask();
  var c = createTask(due: DateTime.now(), tags: ['a', 'b']);
  var d = createTask(due: DateTime.now(), tags: ['a', 'b']);
  test('test comparator', () {
    expect(compareTasks('entry')(a, b), -1);
    expect(compareTasks('due')(a, b), 0);
    expect(compareTasks('due')(a, c), 1);
    expect(compareTasks('due')(c, a), -1);
    expect(compareTasks('due')(c, d), -1);
    expect(compareTasks('priority')(a, b), 0);
    expect(compareTasks('tags')(a, b), 0);
    expect(compareTasks('tags')(c, d), 0);
    expect(compareTasks('urgency')(a, b), 0);
  });
  test('test comparator using patch', () {
    var modifiedTask = patch(task, {'modified': DateTime.now()});
    expect(compareTasks('modified')(task, task), 0);
    expect(compareTasks('modified')(modifiedTask, task), -1);
    expect(compareTasks('modified')(modifiedTask, modifiedTask), 0);
  });
  test('test start', () {
    var startTask = patch(task, {'start': DateTime.now()});
    expect(compareTasks('start')(task, task), 0);
    expect(compareTasks('start')(startTask, task), -1);
    expect(compareTasks('start')(startTask, startTask), 0);
  });
  test('test project', () {
    expect(compareTasks('project')(task, task), 0);
  });
}
