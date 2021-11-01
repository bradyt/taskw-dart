// ignore_for_file: prefer_expression_function_bodies

import 'dart:io';

import 'package:taskc/storage.dart';
import 'package:taskc/taskc.dart' as taskc show statistics, synchronize;
import 'package:taskc/taskc.dart' hide statistics, synchronize;
import 'package:taskc/taskrc.dart';

class TaskdClient {
  TaskdClient(this.home);

  final Directory home;

  String get _ca => '${home.path}/.task/ca.cert.pem';
  String get _cert => '${home.path}/.task/first_last.cert.pem';
  String get _key => '${home.path}/.task/first_last.key.pem';
  String get _serverCert => '${home.path}/.task/server.cert.pem';

  PemFilePaths get _pemFilePaths => PemFilePaths.fromTaskrc(
        {
          for (var pemFileLabel in [
            'taskd.ca',
            'taskd.certificate',
            'taskd.key',
          ])
            pemFileLabel: _keyPemLookup[pemFileLabel],
        },
      );

  Map<String, String> get _keyPemLookup => {
        'taskd.ca': _ca,
        'taskd.cert': _cert,
        'taskd.key': _key,
        'server.cert': _serverCert,
      };

  File fileByKey(String key) {
    Directory('${home.path}/.task').createSync(recursive: true);
    return File(_keyPemLookup[key]!);
  }

  String? pemName(String key) {
    if (File('${home.path}/$key').existsSync()) {
      return File('${home.path}/$key').readAsStringSync();
    }
  }

  void removeTaskdCa() {
    File('${home.path}/.task/ca.cert.pem').deleteSync();
    File('${home.path}/taskd.ca').deleteSync();
  }

  void removeServerCert() {
    File('${home.path}/.task/server.cert.pem').deleteSync();
  }

  bool serverCertExists() {
    return File('${home.path}/.task/server.cert.pem').existsSync();
  }

  void addFileName({required String key, required String name}) {
    if (key != '.taskrc') {
      File('${home.path}/$key').writeAsStringSync(name);
    }
  }

  void addFileContents({required String key, required String contents}) {
    fileByKey(key).writeAsStringSync(contents);
  }

  bool _onBadCertificate(X509Certificate serverCert) {
    var file = File(_serverCert);
    if (file.existsSync() && serverCert.pem == file.readAsStringSync()) {
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
      server: taskrc.server!,
      context: _pemFilePaths.securityContext(),
      onBadCertificate: _onBadCertificate,
      credentials: taskrc.credentials!,
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
      server: taskrc.server!,
      context: _pemFilePaths.securityContext(),
      onBadCertificate: _onBadCertificate,
      credentials: taskrc.credentials!,
      client: client,
      payload: payload,
    );
    return response;
  }
}
