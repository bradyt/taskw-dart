import 'dart:io';

import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:file_selector/file_selector.dart';
import 'package:path_provider/path_provider.dart';

import 'package:taskw/taskw.dart';

Future<void> setConfig({required String profile, required String key}) async {
  if (Platform.isMacOS) {
    var typeGroup = XTypeGroup(label: 'config', extensions: []);
    var file = await openFile(acceptedTypeGroups: [typeGroup]);
    if (file != null) {
      var contents = await file.readAsString();
      var dir = await getApplicationDocumentsDirectory();
      Profiles(dir)
          .getStorage(profile)
          .addFileContents(key: key, contents: contents);
    }
  } else {
    await FilePickerWritable().openFile((_, file) async {
      var contents = file.readAsStringSync();
      var dir = await getApplicationDocumentsDirectory();
      Profiles(dir)
          .getStorage(profile)
          .addFileContents(key: key, contents: contents);
    });
  }
}
