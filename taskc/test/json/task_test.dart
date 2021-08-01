// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:built_collection/built_collection.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import 'package:taskc/taskd.dart';

import 'package:taskc/json.dart';

void main() {
  group('Test task objects', () {
    var unixEpoch = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

    test('test parsing simple json task', () {
      var simpleTask = Task(
        (b) => b
          ..status = 'pending'
          ..uuid = Uuid().v1()
          ..entry = unixEpoch
          ..modified = unixEpoch
          ..description = 'test',
      );

      expect(
        Task.fromJson(json.decode(json.encode(simpleTask.toJson()))),
        simpleTask,
      );
    });

    test('test parsing complex json task', () {
      var complexTask = Task(
        (b) => b
          ..status = 'pending'
          ..uuid = Uuid().v1()
          ..entry = unixEpoch
          ..description = 'test'
          ..start = unixEpoch
          ..end = unixEpoch
          ..due = unixEpoch
          ..until = unixEpoch
          ..wait = unixEpoch
          ..modified = unixEpoch
          ..scheduled = unixEpoch
          ..recur = 'yearly'
          ..mask = '--'
          ..imask = Random().nextInt(pow(2, 32) as int)
          ..parent = Uuid().v1()
          ..project = 'some_project'
          ..priority = 'H'
          ..depends = Uuid().v1()
          ..tags = ListBuilder(const ['+some_tag'])
          ..annotations = ListBuilder(
            [
              Annotation(
                (b) => b
                  ..entry = unixEpoch
                  ..description = 'some annotation',
              ),
            ],
          ),
      );

      expect(
        Task.fromJson(json.decode(json.encode(complexTask.toJson()))),
        complexTask,
      );
    });

    test('test parsing task with uda', () {
      var udaTask = Task(
        (b) => b
          ..status = 'pending'
          ..uuid = Uuid().v1()
          ..entry = unixEpoch
          ..description = 'test'
          ..udas = json.encode(const {'estimate': 4}),
      );

      expect(
        Task.fromJson(json.decode(json.encode(udaTask.toJson()))),
        udaTask,
      );
    });
    test('test parsing json string task with tags', () {
      var uuid = Uuid().v1();
      var task = Task(
        (b) => b
          ..status = 'pending'
          ..uuid = uuid
          ..entry = unixEpoch
          ..description = 'test'
          ..modified = unixEpoch
          ..tags = ListBuilder(const ['+foo']),
      );
      var jsonTask = '{'
          '"status":"pending",'
          '"uuid":"$uuid",'
          '"entry":"19700101T000000Z",'
          '"description":"test",'
          '"modified":"19700101T000000Z",'
          '"tags":["+foo"]'
          '}';

      expect(
        Task.fromJson(json.decode(jsonTask)),
        task,
      );
      expect(
        json.encode(task.toJson()),
        jsonTask,
      );
    });
    test('test json round trip on cli taskwarrior export with UDAs', () async {
      var uuid = Uuid().v1();
      var home = Directory('test/taskd/tmp/$uuid').absolute.path;
      await Directory(home).create(recursive: true);
      var taskwarrior = Taskwarrior(home);
      await taskwarrior.config(['uda.w.type', 'string']);
      await taskwarrior.config(['uda.x.type', 'numeric']);
      await taskwarrior.config(['uda.y.type', 'date']);
      await taskwarrior.config(['uda.z.type', 'duration']);
      await taskwarrior.add([
        'foo',
        'x:42',
        'y:20210801T000000Z',
        'z:1s',
        '+bar',
      ]);
      var result = await taskwarrior.export();
      var task = (json.decode(result) as List).cast<Map>()[0];
      expect(task is Map, true);
      expect(
        Task.fromJson(task),
        Task(
          (b) => b
            ..id = 1
            ..status = 'pending'
            ..uuid = task['uuid']
            ..entry = DateTime.parse(task['entry'])
            ..description = 'foo'
            ..tags = ListBuilder(['bar'])
            ..modified = DateTime.parse(task['modified'])
            ..urgency = 0.8
            ..udas = json.encode({
              'x': 42,
              'y': '20210801T000000Z',
              'z': 'PT1S',
            }),
        ),
      );
      expect(
        Task.fromJson(task).toJson(),
        {
          'id': 1,
          'status': 'pending',
          'uuid': task['uuid'],
          'entry': task['entry'],
          'description': 'foo',
          'tags': ['bar'],
          'modified': task['modified'],
          'x': 42,
          'y': '20210801T000000Z',
          'z': 'PT1S',
          'urgency': 0.8,
        },
      );
      expect(
        Task.fromJson(task).toJson(),
        task,
      );
    });
  });
}
