import 'dart:io';

import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import 'package:taskw/taskw.dart';

void main() {
  test('test profiles', () {
    var baseDirectory = 'test/profile-testing/profiles/${const Uuid().v1()}';
    var profiles = Profiles(Directory(baseDirectory));
    Directory(
      '$baseDirectory/profiles/foo',
    ).createSync(recursive: true);
    var profile = profiles.addProfile();
    profiles
      ..profilesMap()
      ..setAlias(profile: profile, alias: 'bar');
  });
}
