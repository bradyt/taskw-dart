// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:built_collection/built_collection.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import 'package:taskc/taskd.dart';

import 'package:taskj/json.dart';

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
          ..depends = ListBuilder([Uuid().v1()])
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
    test('test dependency strings and arrays (with executable)', () async {
      var uuid = Uuid().v1();
      var home = Directory('test/taskd/tmp/$uuid').absolute.path;
      await Directory(home).create(recursive: true);
      var taskwarrior = Taskwarrior(home);

      await taskwarrior.add(['w']);
      await taskwarrior.add(['x']);
      await taskwarrior.add(['y']);
      await taskwarrior.add(['z']);

      // Assumes task executable before
      // <https://github.com/GothenburgBitFactory/taskwarrior/commit/20af583e21666d4825bfb81fcd1264c786bf4d01>.
      // Tests may be improved to detect task executable version. Such an
      // improvement may be postponed until either the commit is on stable, or
      // someone wants to run tests where bleeding edge Taskwarrior is
      // installed, either in CI or personal computer.
      await taskwarrior.modify(['1', 'dep:2,3,4']);
      var string = (json.decode(await taskwarrior.export()) as List)[0];
      expect((string as Map)['depends'], isA<String>());
      expect((string['depends'] as String).split(',').length, 3);
      expect(Task.fromJson(string).toJson(), string);

      // I expect the rest of the tests to work for stable and bleeding edge
      // Taskwarrior.

      await taskwarrior.modify(['1', 'dep:']);
      var empty = (json.decode(await taskwarrior.export()) as List)[0];

      // See https://github.com/GothenburgBitFactory/taskwarrior/issues/2655
      if (!ListEquality().equals(version, [2, 6, 1])) {
        expect((empty as Map).containsKey('depends'), false);
      }

      expect(Task.fromJson(empty).toJson(), empty);

      await taskwarrior.config(['json.depends.array', '1']);
      await taskwarrior.modify(['1', 'dep:2,3,4']);
      var array = (json.decode(await taskwarrior.export()) as List)[0];
      expect((array as Map)['depends'], isA<List>());
      expect((array['depends'] as List).length, 3);
      expect((array['depends'] as List).first, isA<String>());
      expect(Task.fromJson(array).toJson()['depends'], string['depends']);
    });
    test('test dependency strings and arrays (without executable)', () async {
      var nullDeps = {
        'status': 'p',
        'uuid': 'g',
        'entry': '20210901T000000Z',
        'description': 'x',
      };
      var stringDeps = {...nullDeps, 'depends': 'a,b,c'};
      var arrayDeps = {...nullDeps, 'depends': 'a,b,c'.split(',')};

      expect(Task.fromJson(nullDeps).toJson(), nullDeps);
      expect(Task.fromJson(stringDeps).toJson(), stringDeps);
      expect(Task.fromJson(arrayDeps).toJson(), stringDeps);
    });
  });
}
