import 'dart:async';
import 'dart:io';

import 'package:io/io.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import 'package:taskc/taskd.dart';

void main() {
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    stdout.writeln('${record.level.name}: ${record.time}: ${record.message}');
  });

  group('Checking result of passing TASKDDATA location.', () {
    var uuid = const Uuid().v1();
    var fixture = Directory('../fixture/var/taskd').absolute.path;
    var taskdData = Directory('test/taskd/tmp/$uuid/var/taskd').absolute.path;
    var home = Directory('test/taskd/tmp/$uuid/home').absolute.path;
    var port = 1029;

    setUpAll(() async {
      await Directory(home).create(recursive: true);
      await copyPath(fixture, taskdData);
    });

    test('Test taskdSetup method.', () async {
      var taskd = Taskd(taskdData);
      await taskd.initialize();
      await taskd.setAddressAndPort(
        address: 'localhost',
        port: port,
      );
      var userKey = await taskd.addUser('First Last');
      var taskwarrior = await taskd.initializeClient(
        home: home,
        address: 'localhost',
        port: port,
        fileName: 'first_last',
        fullName: 'First Last',
        userKey: userKey,
      );

      expect(Directory(taskdData).existsSync(), true);

      unawaited(taskd.start());
      await Future.delayed(const Duration(seconds: 1));

      var exitCode = await taskwarrior.synchronize();
      expect(exitCode, 0);

      await taskd.kill();
    });
  });
}
