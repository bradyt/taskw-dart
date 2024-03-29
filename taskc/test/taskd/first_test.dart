import 'dart:io';

import 'package:io/io.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import 'package:taskc/taskd.dart';

void main() {
  group('Checking result of passing TASKDDATA location.', () {
    var uuid = const Uuid().v1();
    var fixture = Directory('../fixture/var/taskd').absolute.path;
    var taskdData = Directory('test/taskc/tmp/$uuid/var/taskd').absolute.path;
    var home = Directory('test/taskd/tmp/$uuid').absolute.path;
    late String userKey;

    setUpAll(() async {
      await copyPath(fixture, taskdData);
    });

    test('Test addUser method.', () async {
      userKey = await Taskd(taskdData).addUser('First Last');
      expect(userKey.length, 36);
    });

    test('Test configureTaskwarrior method.', () async {
      await Taskd(taskdData).initializeClient(
        home: home,
        address: 'localhost',
        port: 1028,
        fullName: 'First Last',
        fileName: 'first_last',
        userKey: userKey,
      );
    });
  });
}
