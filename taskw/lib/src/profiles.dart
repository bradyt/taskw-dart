// ignore_for_file: prefer_expression_function_bodies

import 'dart:io';

import 'package:uuid/uuid.dart';

import 'package:taskw/taskw.dart';

class Profiles {
  Profiles(this.base);

  final Directory base;

  void setCurrentProfile(String profile) {
    File('${base.path}/current-profile').writeAsStringSync(profile);
  }

  String getCurrentProfile() {
    return File('${base.path}/current-profile').readAsStringSync();
  }

  Storage getCurrentStorage() {
    return Storage(Directory('${base.path}/profiles/${getCurrentProfile()}'));
  }

  List<String> listProfiles() {
    var dir = Directory('${base.path}/profiles')..createSync();
    return dir.listSync().map((entity) => entity.path.split('/').last).toList();
  }

  void addProfile() {
    Directory('${base.path}/profiles/${Uuid().v1()}')
        .createSync(recursive: true);
  }

  void deleteProfile(String profile) {
    Directory('${base.path}/profiles/$profile').deleteSync(recursive: true);
    if (File('${base.path}/current-profile').existsSync()) {
      if (profile == File('${base.path}/current-profile').readAsStringSync()) {
        File('${base.path}/current-profile').deleteSync();
      }
    }
  }
}
