import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import 'package:taskj/json.dart';

import 'package:taskw/taskw.dart';

void main() {
  test('test profiles', () {
    var uuid = const Uuid().v1();
    var now = DateTime.parse(iso8601Basic.format(DateTime.now().toUtc()));

    var original = Task(
      (b) => b
        ..uuid = uuid
        ..status = 'pending'
        ..description = 'foo'
        ..entry = now,
    );

    var draft = Draft(original)..set('project', 'x.y.z');
    expect(draft.draft.project, 'x.y.z');
    draft.set('status', 'completed');
    expect(draft.draft.status, 'completed');
  });
}
