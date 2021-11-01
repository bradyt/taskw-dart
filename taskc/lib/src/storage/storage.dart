import 'dart:io';

import 'package:taskw/taskw.dart';

import 'package:taskc/home.dart';
import 'package:taskc/home_impl.dart';
import 'package:taskc/storage.dart';

class Storage {
  const Storage(this.profile);

  final Directory profile;

  Data get data => Data(profile);
  GUIPemFiles get guiPemFiles => GUIPemFiles(profile);
  Home get home => Home(
        home: profile,
        pemFilePaths: guiPemFiles.pemFilePaths,
      );
  Query get query => Query(profile);
  Tabs get tabs => Tabs(profile);
}
