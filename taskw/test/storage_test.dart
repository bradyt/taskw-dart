import 'dart:io';

import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import 'package:taskc/taskc.dart';

import 'package:taskw/taskw.dart';

void main() {
  test('test profiles', () {
    var storage = Storage(
      Directory(
        'test/profile-testing/storage/${const Uuid().v1()}',
      ),
    );
    [
      Task(
        uuid: 'foo',
        status: 'pending',
        description: 'test',
        entry: DateTime.now(),
        tags: const ['baz'],
      ),
      Task(
        uuid: 'bar',
        status: 'waiting',
        description: 'test',
        entry: DateTime.now(),
        wait: DateTime.now(),
      ),
      Task(
        uuid: 'baz',
        status: 'pending',
        description: 'test',
        entry: DateTime.now(),
        until: DateTime.now(),
      ),
    ].forEach(storage.mergeTask);
    storage
      ..tags()
      ..allData()
      ..getTask('foo');
    for (var entry in {
      '.taskrc': '.taskrc',
      'taskd.ca': '.task/ca.cert.pem',
      'taskd.cert': '.task/first_last.cert.pem',
      'taskd.key': '.task/first_last.key.pem',
    }.entries) {
      expect(() => storage.synchronize(),
          throwsA(isA<TaskserverConfigurationException>()));
      storage.addFileContents(
        key: entry.key,
        contents: File('../fixture/${entry.value}').readAsStringSync(),
      );
    }
    storage.synchronize();
  });
}
