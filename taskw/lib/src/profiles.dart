import 'dart:io';

import 'package:uuid/uuid.dart';

class Profiles {
  Profiles(this.base);

  final Directory base;

  void setCurrentProfile(String profile) =>
      File('${base.path}/current-profile').writeAsStringSync(profile);

  List<String> listProfiles() {
    var dir = Directory('${base.path}/profiles');
    dir.createSync();
    return dir.listSync().map((entity) => entity.path.split('/').last).toList();
  }

  void addProfile() =>
      Directory('${base.path}/profiles/${Uuid().v1()}').createSync();

  void deleteProfile(profile) {
    Directory('${base.path}/profiles/$profile').deleteSync(recursive: true);
    if (profile == File('${base.path}/current-profile').readAsStringSync()) {
      File('${base.path}/current-profile').deleteSync();
    }
  }
}
