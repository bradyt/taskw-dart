import 'package:test/test.dart';

import 'package:built_collection/built_collection.dart';

import 'package:taskc/json.dart';

import 'package:taskw/taskw.dart';

void main() {
  Task createTask({DateTime? due, String? priority, List<String>? tags}) {
    return Task(
      (b) => b
        ..description = 'foo'
        ..uuid = 'bar'
        ..status = 'baz'
        ..entry = DateTime.now()
        ..due = due
        ..priority = priority
        ..tags = (tags == null) ? null : ListBuilder(tags),
    );
  }

  test('test urgency', () {
    expect(urgency(createTask(tags: ['next'])), 15.8);
    expect(urgency(createTask(priority: 'H')), 6);
    expect(urgency(createTask(priority: 'M')), 3.9);
    expect(urgency(createTask(priority: 'L')), 1.8);
    expect(urgency(createTask(tags: ['a', 'b', 'c'])), 1);
    expect(urgency(createTask(due: DateTime.now())), 8.796);
  });
}
