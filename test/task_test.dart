import 'dart:convert';
import 'dart:math';

import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import 'package:taskc/taskc.dart';

void main() {
  group('Test task objects', () {
    var unixEpoch = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

    test('test parsing simple json task', () {
      var simpleTask = Task(
        status: 'pending',
        uuid: Uuid().v1(),
        entry: unixEpoch,
        description: 'test',
      );

      expect(
        Task.fromJson(json.decode(json.encode(simpleTask.toJson()))),
        simpleTask,
      );
    });

    test('test parsing complex json task', () {
      var complexTask = Task(
        status: 'pending',
        uuid: Uuid().v1(),
        entry: unixEpoch,
        description: 'test',
        start: unixEpoch,
        end: unixEpoch,
        due: unixEpoch,
        until: unixEpoch,
        wait: unixEpoch,
        modified: unixEpoch,
        scheduled: unixEpoch,
        recur: 'yearly',
        mask: '--',
        imask: Random().nextInt(pow(2, 32)),
        parent: Uuid().v1(),
        project: 'some_project',
        priority: 'H',
        depends: Uuid().v1(),
        tags: '+some_tag',
        annotations: [
          Annotation(
            entry: unixEpoch,
            description: 'some annotation',
          ),
        ],
      );

      expect(
        Task.fromJson(json.decode(json.encode(complexTask.toJson()))),
        complexTask,
      );
    });
  });
}
