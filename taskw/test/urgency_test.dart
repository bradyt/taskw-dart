import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import 'package:built_collection/built_collection.dart';
import 'package:uuid/uuid.dart';

import 'package:taskc/json.dart';
import 'package:taskc/taskd.dart';

import 'package:taskw/taskw.dart';

void main() {
  test('test urgency', () {
    Task createTask({DateTime? due, String? priority, List<String>? tags}) {
      return Task(
        (b) => b
          ..description = 'foo'
          ..uuid = 'bar'
          ..status = 'baz'
          ..entry = DateTime.now()
          ..due = due
          ..priority = priority
          ..tags = (tags == null) ? null : ListBuilder(tags),
      );
    }

    expect(urgency(createTask(tags: ['next'])), 15.8);
    expect(urgency(createTask(priority: 'H')), 6);
    expect(urgency(createTask(priority: 'M')), 3.9);
    expect(urgency(createTask(priority: 'L')), 1.8);
    expect(urgency(createTask(tags: ['a', 'b', 'c'])), 1);
    expect(urgency(createTask(due: DateTime.now())), 8.796);
  });
  test('test urgency (with executable)', () async {
    Future<Map> createTask(List<String> mods) async {
      var uuid = const Uuid().v1();
      var home = Directory('test/urgency/tmp/$uuid').absolute.path;
      await Directory(home).create(recursive: true);
      var taskwarrior = Taskwarrior(home);

      await taskwarrior.add(mods);

      var map = (json.decode(await taskwarrior.export()) as List)[0];

      return map;
    }

    var modses = [
      '+next',
      'pri:H',
      'pri:M',
      'pri:L',
      '+a +b +c',
      'due:1980-01-01',
      'due:2037-01-01',
      'sch:1980-01-01',
      'sch:2037-01-01',
      'wait:1980-01-01',
      'wait:2037-01-01',
      'pro:home',
    ];

    for (var mods in modses) {
      var task = await createTask(['foo', ...mods.split(' ')]);

      expect(urgency(Task.fromJson(task)), task['urgency']);
    }

    var aSecondAgo =
        DateTime.now().add(const Duration(seconds: -1)).toIso8601String();
    var inASecond =
        DateTime.now().add(const Duration(seconds: 2)).toIso8601String();
    var todayModses = [
      'due:$aSecondAgo',
      'sch:$aSecondAgo',
      'wait: $aSecondAgo',
      'until: $aSecondAgo',
      'due:$inASecond',
      'sch:$inASecond',
      'wait: $inASecond',
      'until: $inASecond',
    ];

    for (var mods in todayModses) {
      var task = await createTask(['foo', ...mods.split(' ')]);
      var actualUrgency = urgency(Task.fromJson(task));
      var expectedUrgency = task['urgency'] as num;

      expect(actualUrgency.round(), expectedUrgency.round());
    }
  });
  test('test urgency with annotations (with executable)', () async {
    Future<Map> createTaskWithAnnotations({
      required String description,
      List<String>? annotations,
    }) async {
      var uuid = const Uuid().v1();
      var home = Directory('test/urgency/tmp/$uuid').absolute.path;
      await Directory(home).create(recursive: true);
      var taskwarrior = Taskwarrior(home);

      await taskwarrior.add([description]);
      for (var annotation in annotations ?? []) {
        await taskwarrior.annotate(index: 1, annotation: annotation);
      }

      var map = (json.decode(await taskwarrior.export()) as List)[0];

      return map;
    }

    var annotationses = [
      [],
      ['bar'],
      ['bar', 'baz'],
      ['bar', 'baz', 'quux'],
      ['bar', 'baz', 'quux', 'quuux'],
    ];

    for (var annotations in annotationses) {
      var task = await createTaskWithAnnotations(
        description: 'foo',
        annotations: annotations.cast<String>(),
      );

      expect(urgency(Task.fromJson(task)), task['urgency']);
    }
  });
}
