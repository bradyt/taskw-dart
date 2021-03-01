// ignore_for_file: prefer_expression_function_bodies

import 'dart:io';

import 'package:uuid/uuid.dart';

import 'package:taskw/taskw.dart';

class Profiles {
  Profiles(this.base);

  final Directory base;

  String addProfile() {
    // ignore: prefer_const_constructors
    var uuid = Uuid().v1();

    Directory('${base.path}/profiles/$uuid').createSync(recursive: true);
    File('${base.path}/profiles/$uuid/created')
        .writeAsStringSync('${DateTime.now().toUtc()}');
    File('${base.path}/profiles/$uuid/alias').createSync();

    return uuid;
  }

  List<String> listProfiles() {
    var dir = Directory('${base.path}/profiles')..createSync();
    var dirs = dir.listSync().map((entity) => entity.path).toList()
      ..sort((a, b) {
        var aCreated = DateTime.parse(File('$a/created').readAsStringSync());
        var bCreated = DateTime.parse(File('$b/created').readAsStringSync());
        if (aCreated.isBefore(bCreated)) {
          return -1;
        } else if (aCreated.isAfter(bCreated)) {
          return 1;
        } else {
          return 0;
        }
      });
    return dirs.map((path) => path.split('/').last).toList();
  }

  void deleteProfile(String profile) {
    Directory('${base.path}/profiles/$profile').deleteSync(recursive: true);
    if (File('${base.path}/current-profile').existsSync()) {
      if (profile == File('${base.path}/current-profile').readAsStringSync()) {
        File('${base.path}/current-profile').deleteSync();
      }
    }
  }

  void setAlias({required String profile, required String alias}) {
    File('${base.path}/profiles/$profile/alias').writeAsStringSync(alias);
  }

  String? getAlias(String profile) {
    var contents =
        File('${base.path}/profiles/$profile/alias').readAsStringSync();
    return (contents.isEmpty) ? null : contents;
  }

  void setCurrentProfile(String profile) {
    File('${base.path}/current-profile').writeAsStringSync(profile);
  }

  String? getCurrentProfile() {
    if (File('${base.path}/current-profile').existsSync()) {
      return File('${base.path}/current-profile').readAsStringSync();
    }
    return null;
  }

  Storage? getCurrentStorage() {
    var currentProfile = getCurrentProfile();
    if (currentProfile != null) {
      return getStorage(currentProfile);
    }
    return null;
  }

  Storage getStorage(String profile) {
    return Storage(Directory('${base.path}/profiles/$profile'));
  }
}
