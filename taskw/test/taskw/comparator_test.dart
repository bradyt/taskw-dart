import 'package:test/test.dart';

import 'package:taskw/json.dart';

import 'package:taskw/taskw.dart';

void main() {
  Task createTask({DateTime? due, List<String>? tags}) {
    return Task(
      description: 'foo',
      uuid: 'bar',
      status: 'baz',
      entry: DateTime.now(),
      due: due,
      tags: tags,
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
}
