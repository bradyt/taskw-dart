import 'dart:io';

import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:file_selector/file_selector.dart';

import 'package:taskc/storage.dart';

Future<void> setConfig({required Storage storage, required String key}) async {
  if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
    var typeGroup = XTypeGroup(label: key, extensions: []);
    var file = await openFile(acceptedTypeGroups: [typeGroup]);
    if (file != null) {
      var contents = await file.readAsString();
      storage.addFileContents(key: key, contents: contents);
    }
  } else {
    await FilePickerWritable().openFile((_, file) async {
      var contents = file.readAsStringSync();
      storage.addFileContents(key: key, contents: contents);
    });
  }
}
