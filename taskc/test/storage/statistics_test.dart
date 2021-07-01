import 'dart:io';

import 'package:path/path.dart';
import 'package:pedantic/pedantic.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import 'package:taskc/storage.dart';
import 'package:taskc/taskd.dart';

import 'package:taskw/taskw.dart';

void main() {
  group('Test statistics method;', () {
    var taskd = Taskd(normalize(absolute('../fixture/var/taskd')));
    var uuid = const Uuid().v1();
    var home = Directory('test/taskd/tmp/$uuid').absolute.path;

    late Storage storage;

    setUpAll(() async {
      unawaited(taskd.start());
      await Future.delayed(const Duration(seconds: 1));
      var userKey = await taskd.addUser('First Last');
      await taskd.initializeClient(
        home: home,
        address: 'localhost',
        port: 53589,
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
      for (var entry in {
        '.taskrc': '.taskrc',
        'taskd.ca': '.task/ca.cert.pem',
        'taskd.cert': '.task/first_last.cert.pem',
        'taskd.key': '.task/first_last.key.pem',
      }.entries) {
        storage.addFileContents(
          key: entry.key,
          contents: File('$home/${entry.value}').readAsStringSync(),
        );
      }
      try {
        await storage.statistics();
      } on BadCertificateException catch (e) {
        storage.addFileContents(
          key: 'server.cert',
          contents: e.certificate.pem,
        );
      }
      var header = await storage.statistics();
      expect(header['code'], '200');
    });
  });
}
