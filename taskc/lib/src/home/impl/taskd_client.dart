// ignore_for_file: prefer_expression_function_bodies

import 'dart:io';

import 'package:taskc/storage.dart';
import 'package:taskc/taskc.dart' as taskc show statistics, synchronize;
import 'package:taskc/taskc.dart' hide statistics, synchronize;
import 'package:taskc/taskrc.dart';

class TaskdClient {
  TaskdClient(this.home);

  final Directory home;

  PemFilePaths get _pemFilePaths => PemFilePaths(
        ca: '${home.path}/.task/ca.cert.pem',
        certificate: '${home.path}/.task/first_last.cert.pem',
        key: '${home.path}/.task/first_last.key.pem',
        serverCert: '${home.path}/.task/server.cert.pem',
      );

  File fileByKey(String key) {
    Directory('${home.path}/.task').createSync(recursive: true);
    return File(_pemFilePaths.map[key]!);
  }

  String? pemName(String key) {
    if (File('${home.path}/$key').existsSync()) {
      return File('${home.path}/$key').readAsStringSync();
    }
  }

  void removeTaskdCa() {
    if (File(_pemFilePaths.ca!).existsSync()) {
      File(_pemFilePaths.ca!).deleteSync();
    }
    if (File('${home.path}/taskd.ca').existsSync()) {
      File('${home.path}/taskd.ca').deleteSync();
    }
  }

  void removeServerCert() {
    if (_pemFilePaths.serverCert != null) {
      if (File(_pemFilePaths.serverCert!).existsSync()) {
        File(_pemFilePaths.serverCert!).deleteSync();
      }
    }
  }

  bool serverCertExists() {
    return File(_pemFilePaths.serverCert!).existsSync();
  }

  void addFileName({required String key, required String name}) {
    File('${home.path}/$key').writeAsStringSync(name);
  }

  void addFileContents({required String key, required String contents}) {
    fileByKey(key).writeAsStringSync(contents);
  }

  bool _onBadCertificate(X509Certificate serverCert) {
    if (_pemFilePaths.onBadCertificate(serverCert)) {
      return true;
    } else {
      throw BadCertificateException(
        home: home,
        certificate: serverCert,
      );
    }
  }

  Future<Map> statistics(String client) async {
    var taskrc = Taskrc.fromHome(home.path);
    var response = await taskc.statistics(
      server: taskrc.server,
      context: _pemFilePaths.securityContext(),
      onBadCertificate: _onBadCertificate,
      credentials: taskrc.credentials,
      client: client,
    );
    return response.header;
  }

  Future<Response> synchronize({
    required String client,
    required String payload,
  }) async {
    var taskrc = Taskrc.fromHome(home.path);
    var response = await taskc.synchronize(
      server: taskrc.server,
      context: _pemFilePaths.securityContext(),
      onBadCertificate: _onBadCertificate,
      credentials: taskrc.credentials,
      client: client,
      payload: payload,
    );
    return response;
  }
}
