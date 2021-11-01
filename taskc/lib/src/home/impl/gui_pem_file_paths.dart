import 'dart:io';

import 'package:taskc/taskrc.dart';

class GUIPemFiles {
  GUIPemFiles(this.home);

  final Directory home;

  PemFilePaths get pemFilePaths => PemFilePaths(
        ca: '${home.path}/.task/ca.cert.pem',
        certificate: '${home.path}/.task/first_last.cert.pem',
        key: '${home.path}/.task/first_last.key.pem',
        serverCert: '${home.path}/.task/server.cert.pem',
      );

  File fileByKey(String key) {
    Directory('${home.path}/.task').createSync(recursive: true);
    return File(pemFilePaths.map[key]!);
  }

  String? pemName(String key) {
    if (File('${home.path}/$key').existsSync()) {
      return File('${home.path}/$key').readAsStringSync();
    }
  }

  void removeTaskdCa() {
    if (File(pemFilePaths.ca!).existsSync()) {
      File(pemFilePaths.ca!).deleteSync();
    }
    if (File('${home.path}/taskd.ca').existsSync()) {
      File('${home.path}/taskd.ca').deleteSync();
    }
  }

  void removeServerCert() {
    if (pemFilePaths.serverCert != null) {
      if (File(pemFilePaths.serverCert!).existsSync()) {
        File(pemFilePaths.serverCert!).deleteSync();
      }
    }
  }

  bool serverCertExists() {
    return File(pemFilePaths.serverCert!).existsSync();
  }

  void addFileName({required String key, required String name}) {
    File('${home.path}/$key').writeAsStringSync(name);
  }

  void addFileContents({required String key, required String contents}) {
    fileByKey(key).writeAsStringSync(contents);
  }
}
