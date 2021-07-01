import 'dart:convert';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import 'package:taskc/taskd.dart';

void main() {
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    stdout.writeln('${record.level.name}: ${record.time}: ${record.message}');
  });

  group('try taskwarrior', () {
    var uuid = const Uuid().v1();
    var home = Directory('test/taskd/tmp/$uuid').absolute.path;

    setUpAll(() async {
      Logger('taskwarrior_test').info(home);
      await Directory(home).create(recursive: true);
    });

    test('test export', () async {
      var taskwarrior = Taskwarrior(home);
      var result = await taskwarrior.export();
      expect(result, '[\n]\n');
      await taskwarrior.config(['uda.estimate.type', 'numeric']);
      await taskwarrior.add(['foo', 'estimate:4', '+bar']);
      result = await taskwarrior.export();
      var task = (json.decode(result) as List).cast<Map>()[0];
      expect(task['estimate'], 4);
      expect(task['tags'], ['bar']);
      expect(task['id'], 1);
      expect(task['urgency'], 0.8);
    });
  });
}
