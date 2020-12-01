import 'dart:convert';

import 'package:taskc/src/task.dart';

class Payload {
  Payload({this.tasks, this.userKey});

  final List<Task> tasks;
  final String userKey;

  factory Payload.fromString(String string) {
    var lines = string.trim().split('\n');
    var userKey = lines.removeLast();
    List tasks = lines.map((line) => Task.fromJson(json.decode(line))).toList();
    return Payload(
      tasks: tasks,
      userKey: userKey,
    );
  }

  @override
  String toString() =>
      tasks.map((task) => json.encode(task.toJson())).join('\n');
}
