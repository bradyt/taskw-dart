import 'dart:io';

import 'package:built_collection/built_collection.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import 'package:taskc/storage.dart';
import 'package:taskj/json.dart';

import 'package:taskw/taskw.dart';

void main() {
  test('test profiles', () {
    var uuid = const Uuid().v1();
    var now = DateTime.parse(iso8601Basic.format(DateTime.now().toUtc()));

    var storage = Storage(
      Directory(
        'test/profile-testing/modify/${const Uuid().v1()}',
      ),
    )..data.mergeTask(Task(
        (b) => b
          ..uuid = uuid
          ..status = 'pending'
          ..description = 'foo'
          ..entry = now,
      ));
    var draft = Modify(
      getTask: storage.data.getTask,
      mergeTask: storage.data.mergeTask,
      uuid: uuid,
    )
      ..draft
      ..id
      ..set('description', 'bar')
      ..set('status', 'pending')
      ..set('status', 'completed')
      ..set('due', now)
      ..set('wait', now)
      ..set('until', now)
      ..set('priority', 'H')
      ..set('start', now)
      ..set('project', 'x.y.z')
      ..set('tags', ListBuilder(['baz']))
      ..set(
          'annotations',
          ListBuilder([
            Annotation(
              (b) => b
                ..entry = now
                ..description = 'baz',
            )
          ]));
    var expected = 'description:\n'
        '  old: foo\n'
        '  new: bar\n'
        'status:\n'
        '  old: pending\n'
        '  new: completed\n'
        'start:\n'
        '  old: null\n'
        '  new: ${now.toLocal()}\n'
        'end:\n'
        '  old: null\n'
        '  new: ${(draft.changes['end']!['new'] as DateTime).toLocal()}\n'
        'due:\n'
        '  old: null\n'
        '  new: ${now.toLocal()}\n'
        'wait:\n'
        '  old: null\n'
        '  new: ${now.toLocal()}\n'
        'until:\n'
        '  old: null\n'
        '  new: ${now.toLocal()}\n'
        'priority:\n'
        '  old: null\n'
        '  new: H\n'
        'project:\n'
        '  old: null\n'
        '  new: x.y.z\n'
        'tags:\n'
        '  old: null\n'
        '  new: [baz]\n'
        'annotations:\n'
        '  old: 0\n'
        '  new: 1';
    expect(
      draft.changes.entries
          .map((entry) => '${entry.key}:\n'
              '  old: ${entry.value['old']}\n'
              '  new: ${entry.value['new']}')
          .join('\n'),
      expected,
    );

    draft.save(modified: () => DateTime.now().toUtc());
    expect(draft.changes, {});
  });
}
