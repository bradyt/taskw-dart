import 'dart:io';

import 'package:uuid/uuid.dart';

class Profiles {
  Profiles(this.base);

  final Directory base;

  List<String> listProfiles() =>
      base.listSync().map((entity) => entity.path.split('/').last).toList();

  void addProfile() => Directory('${base.path}/${Uuid().v1()}').createSync();
}
