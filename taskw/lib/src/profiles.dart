import 'dart:io';

import 'package:uuid/uuid.dart';

class Profiles {
  Profiles(this.base);

  final Directory base;

  List<String> listProfiles() {
    var dir = Directory('${base.path}/profiles');
    dir.createSync();
    return dir.listSync().map((entity) => entity.path.split('/').last).toList();
  }

  void addProfile() =>
      Directory('${base.path}/profiles/${Uuid().v1()}').createSync();
}
