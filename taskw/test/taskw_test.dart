import 'dart:io';

import 'package:test/test.dart';

import 'package:uuid/uuid.dart';

import 'package:taskc/taskc.dart';

import 'package:taskw/taskw.dart';

void main() {
  group('Test profiles;', () {
    Directory base;
    late Profiles profiles;

    setUp(() {
      base = Directory(
        'test/profile-testing/taskw',
      )..createSync(recursive: true);
      profiles = Profiles(base);
    });

    test('add two tasks to a profile\'s storage', () {
      profiles.listProfiles().forEach((profile) {
        profiles.deleteProfile(profile);
      });

      profiles
        ..addProfile()
        ..setCurrentProfile(profiles.listProfiles().first);

      var storage = profiles.getCurrentStorage()!;

      expect(() => storage.pendingData(), returnsNormally);

      for (var description in ['foo', 'bar']) {
        storage.mergeTask(
          Task(
            status: 'pending',
            uuid: const Uuid().v1(),
            entry: DateTime.now().toUtc(),
            description: description,
            tags: const [],
            annotations: const [],
            udas: const {},
          ),
        );
      }

      var tasks = storage.pendingData();

      expect(tasks.length, 2);
      expect(tasks[0].description, 'foo');
      expect(tasks[1].description, 'bar');
    });
  });
}
