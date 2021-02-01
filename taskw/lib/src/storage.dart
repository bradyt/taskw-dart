import 'dart:io';

import 'package:uuid/uuid.dart';

import 'package:taskc/taskc.dart';

class Storage {
  Storage(this.profile);

  Directory profile;

  List<Task> listTasks() => [
        for (var description in [
          'foo',
          'bar',
          'baz',
          'qux',
          'quux',
          'quuz',
          'corge',
          'grault',
          'garply',
          'waldo',
          'fred',
          'plugh',
          'xyzzy',
          'thud'
        ])
          Task(
            status: 'pending',
            uuid: Uuid().v1(),
            entry: DateTime.now().toUtc(),
            description: description,
          ),
      ];

  void addTask(Task task) {
    stdout.writeln(task);
  }
}
