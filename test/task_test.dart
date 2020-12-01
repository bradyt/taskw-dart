import 'dart:convert';

import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import 'package:taskc/taskc.dart';

void main() {
  group('Test task objects', () {
    var task = Task(
      status: 'pending',
      uuid: Uuid().v1(),
      entry: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      description: 'test',
    );

    test('test parsing json task', () {
      expect(Task.fromJson(json.decode(json.encode(task.toJson()))), task);
    });
  });
}
