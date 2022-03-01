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
    var now = DateTime.now().toUtc();
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
      ..setDescription('bar')
      ..setStatus('pending')
      ..setStatus('completed')
      ..setDue(now)
      ..setWait(now)
      ..setUntil(now)
      ..setPriority('H')
      ..setTags(ListBuilder(['baz']));
    var expected = 'description:\n'
        '  old: foo\n'
        '  new: bar\n'
        'status:\n'
        '  old: pending\n'
        '  new: waiting\n'
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
        'tags:\n'
        '  old: null\n'
        '  new: [baz]';
    expect(
      draft.changes.entries.map((entry) {
        var _old = entry.value['old'];
        var _new = entry.value['new'];
        if (_old is DateTime) {
          _old = _old.toLocal();
        }
        if (_new is DateTime) {
          _new = _new.toLocal();
        }
        return '${entry.key}:\n'
            '  old: $_old\n'
            '  new: $_new';
      }).join('\n'),
      expected,
    );

    draft.save(modified: () => DateTime.now().toUtc());
    expect(draft.changes.isEmpty, true);
  });
}
