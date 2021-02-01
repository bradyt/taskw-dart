import 'package:uuid/uuid.dart';

class Profiles {
  final List<String> profiles = [];

  void addProfile() {
    profiles.add(Uuid().v1());
  }
}
