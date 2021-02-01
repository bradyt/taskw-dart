import 'dart:io';

import 'package:taskc/taskc.dart';

class Storage {
  Storage(this.profile);

  Directory profile;

  List<Task> listTasks() {
    return [
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
          description: description,
        ),
    ];
  }

  void addTask(Task task) {}
}
