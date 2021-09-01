import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import 'package:built_collection/built_collection.dart';
import 'package:uuid/uuid.dart';

import 'package:taskc/json.dart';

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

      expect(() => storage.home.pendingData(), returnsNormally);

      for (var description in ['foo', 'bar']) {
        storage.home.mergeTask(
          Task(
            (b) => b
              ..status = 'pending'
              ..uuid = const Uuid().v1()
              ..entry = DateTime.now().toUtc()
              ..description = description
              ..tags = ListBuilder(const [])
              ..annotations = ListBuilder(const [])
              ..udas = json.encode(const {}),
          ),
        );
      }

      var tasks = storage.home.pendingData();

      expect(tasks.length, 2);
      expect(tasks[0].description, 'foo');
      expect(tasks[1].description, 'bar');
    });
  });
}
