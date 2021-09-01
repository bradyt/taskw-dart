import 'dart:io';

import 'package:taskw/taskw.dart';

import 'package:taskc/home.dart';
import 'package:taskc/storage.dart';

class Storage {
  const Storage(this.profile);

  final Directory profile;

  Home get home => Home(profile);
  Query get query => Query(profile);
  Tabs get tabs => Tabs(profile);
}
