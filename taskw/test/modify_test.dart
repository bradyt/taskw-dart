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
    Modify(
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
      ..setTags(ListBuilder(['baz']))
      ..changes
      ..save(modified: () => now);
  });
}
