import 'dart:async';
import 'dart:io';

import 'package:io/io.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import 'package:taskc/storage.dart';
import 'package:taskc/taskd.dart';

import 'package:taskw/taskw.dart';

void main() {
  group('Test statistics method;', () {
    var uuid = const Uuid().v1();
    var fixture = Directory('../fixture/var/taskd').absolute.path;
    var taskdData = Directory('test/taskc/tmp/$uuid/var/taskd').absolute.path;
    var taskd = Taskd(normalize(taskdData));
    var home = Directory('test/taskc/tmp/$uuid/home').absolute.path;

    late Storage storage;

    setUpAll(() async {
      await Directory(home).create(recursive: true);
      await copyPath(fixture, taskdData);
      await taskd.initialize();
      await taskd.setAddressAndPort(
        address: 'localhost',
        port: 1024,
      );
      unawaited(taskd.start());
      await Future.delayed(const Duration(seconds: 1));
      var userKey = await taskd.addUser('First Last');
      await taskd.initializeClient(
        home: home,
        address: 'localhost',
        port: 1024,
        fullName: 'First Last',
        fileName: 'first_last',
        userKey: userKey,
      );
    });

    tearDownAll(() async {
      await taskd.kill();
    });

    setUp(() {
      var base = Directory('test/profile-testing/statistics')
        ..createSync(recursive: true);
      var profiles = Profiles(base);
      profiles.listProfiles().forEach((profile) {
        profiles.deleteProfile(profile);
      });
      storage = profiles.getStorage(profiles.addProfile());
    });

    test('check for needed files', () async {
      storage.taskrc.addTaskrc(File('$home/.taskrc').readAsStringSync());
      for (var entry in {
        'taskd.ca': '.task/ca.cert.pem',
        'taskd.certificate': '.task/first_last.cert.pem',
        'taskd.key': '.task/first_last.key.pem',
      }.entries) {
        storage.guiPemFiles.addPemFile(
          key: entry.key,
          contents: File('$home/${entry.value}').readAsStringSync(),
        );
      }
      try {
        await storage.home.statistics('test');
      } on BadCertificateException catch (e) {
        storage.guiPemFiles.addPemFile(
          key: 'server.cert',
          contents: e.certificate.pem,
        );
      }
      var header = await storage.home.statistics('test');
      expect(header['code'], '200');
    });
  });
}
