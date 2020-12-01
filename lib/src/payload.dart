import 'dart:convert';

import 'package:meta/meta.dart';

import 'package:taskc/src/task.dart';

class Payload {
  Payload({@required this.tasks, this.userKey});

  factory Payload.fromString(String string) {
    var lines = string.trim().split('\n');
    var userKey = lines.removeLast();
    var tasks = lines.map((line) => Task.fromJson(json.decode(line))).toList();
    return Payload(
      tasks: tasks,
      userKey: userKey,
    );
  }

  final List<Task> tasks;
  final String userKey;

  @override
  String toString() => tasks
      .map((task) => json.encode(task.toJson()))
      .followedBy([userKey ?? ''])
      .join('\n')
      .trim();
}
