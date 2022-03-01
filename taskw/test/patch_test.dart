import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import 'package:taskj/json.dart';

import 'package:taskw/taskw.dart';

void main() {
  test('test patches', () {
    var uuid = const Uuid().v1();
    var now = DateTime.now().toUtc();

    var task = Task(
      (b) => b
        ..uuid = uuid
        ..status = 'pending'
        ..description = 'foo'
        ..entry = now,
    );

    expect(patch(task, {'status': 'completed'}).status, 'completed');
  });
}
