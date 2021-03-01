import 'dart:io';

import 'package:test/test.dart';

import 'package:taskw/taskw.dart';

void main() {
  group('Test statistics method;', () {
    late Storage storage;

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
          contents: File('../fixture/${entry.value}').readAsStringSync(),
        );
      }
      var header = await storage.statistics();
      expect(header['code'], '200');
    });
  });
}
