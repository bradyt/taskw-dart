import 'dart:io';

import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import 'package:taskw/json.dart';

import 'package:taskw/taskw.dart';

void main() {
  test('test profiles', () {
    var uuid = const Uuid().v1();
    var storage = Storage(
      Directory(
        'test/profile-testing/modify/${const Uuid().v1()}',
      ),
    )..mergeTask(Task(
        uuid: uuid,
        status: 'pending',
        description: 'foo',
        entry: DateTime.now(),
      ));
    Modify(
      getTask: storage.getTask,
      mergeTask: storage.mergeTask,
      uuid: uuid,
    )
      ..draft
      ..id
      ..setDescription('bar')
      ..setStatus('pending')
      ..setStatus('completed')
      ..setDue(DateTime.now())
      ..setWait(DateTime.now())
      ..setUntil(DateTime.now())
      ..setPriority('H')
      ..setTags(['baz'])
      ..changes
      ..save(modified: () => DateTime.now());
  });
}
