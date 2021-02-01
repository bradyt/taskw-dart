// ignore_for_file: prefer_expression_function_bodies

import 'dart:convert';
import 'dart:io';

import 'package:taskc/taskc.dart' as taskc show statistics, synchronize;
import 'package:taskc/taskc.dart' hide statistics, synchronize;

import 'package:taskw/taskw.dart';

class Storage {
  const Storage(this.profile);

  final Directory profile;

  File get _taskrc => File('${profile.path}/.taskrc');
  File get _ca => File('${profile.path}/.task/ca.cert.pem');
  File get _cert => File('${profile.path}/.task/first_last.cert.pem');
  File get _key => File('${profile.path}/.task/first_last.key.pem');

  List<Task> next() {
    return listTasks().where((task) => task.status == 'pending').toList()
      ..sort((a, b) {
        if (urgency(a) < urgency(b)) {
          return 1;
        } else if (urgency(a) > urgency(b)) {
          return -1;
        } else {
          return 0;
        }
      });
  }

  List<Task> listTasks() => [
        if (File('${profile.path}/.task/all.data').existsSync())
          for (var line in File('${profile.path}/.task/all.data')
              .readAsStringSync()
              .trim()
              .split('\n'))
            if (line.isNotEmpty) Task.fromJson(json.decode(line)),
      ];

  void addTask(Task task) {
    mergeTasks([task]);
    File('${profile.path}/.task/backlog.data').writeAsStringSync(
      '${json.encode(task.toJson())}\n',
      mode: FileMode.append,
    );
  }

  void mergeTasks(List<Task> tasks) {
    File('${profile.path}/.task/all.data').createSync(recursive: true);
    var lines = File('${profile.path}/.task/all.data')
        .readAsStringSync()
        .trim()
        .split('\n');
    var taskMap = {
      for (var taskLine in lines)
        if (taskLine.isNotEmpty) json.decode(taskLine)['uuid']: taskLine,
    };
    for (var task in tasks) {
      taskMap[task.uuid] = json.encode(task);
    }
    File('${profile.path}/.task/all.data').writeAsStringSync('');
    for (var task in taskMap.values) {
      File('${profile.path}/.task/all.data').writeAsStringSync(
        '$task\n',
        mode: FileMode.append,
      );
    }
  }

  File fileByKey(String key) {
    Directory('${profile.path}/.task').createSync(recursive: true);
    File file;
    switch (key) {
      case '.taskrc':
        file = _taskrc;
        break;
      case 'taskd.ca':
        file = _ca;
        break;
      case 'taskd.cert':
        file = _cert;
        break;
      case 'taskd.key':
        file = _key;
        break;
      default:
    }
    return file;
  }

  void addFileContents({String key, String contents}) {
    fileByKey(key).writeAsStringSync(contents);
  }

  void readFileContents(String key) {
    fileByKey(key).readAsStringSync();
  }

  Connection _getConnection(Map config) {
    var ca = '${profile.path}/.task/ca.cert.pem';
    var cert = '${profile.path}/.task/first_last.cert.pem';
    var key = '${profile.path}/.task/first_last.key.pem';
    var server = config['taskd.server'].split(':');
    return Connection(
      address: server[0],
      port: int.parse(server[1]),
      context: SecurityContext()
        ..setTrustedCertificates(ca)
        ..useCertificateChain(cert)
        ..usePrivateKey(key),
      onBadCertificate: (_) => true,
    );
  }

  Credentials _getCredentials(Map config) =>
      Credentials.fromString(config['taskd.credentials']);

  Map getConfig() =>
      parseTaskrc(File('${profile.path}/.taskrc').readAsStringSync());

  Future<Map> statistics() async {
    var config = getConfig();
    var response = await taskc.statistics(
      connection: _getConnection(config),
      credentials: _getCredentials(config),
    );
    return response.header;
  }

  Future<Map> synchronize() async {
    var config = getConfig();
    var payload = '';
    if (File('${profile.path}/.task/backlog.data').existsSync()) {
      payload = File('${profile.path}/.task/backlog.data').readAsStringSync();
    }
    var response = await taskc.synchronize(
      connection: _getConnection(config),
      credentials: _getCredentials(config),
      payload: payload,
    );
    File('${profile.path}/.task/backlog.data')
        .writeAsStringSync('${response.payload.userKey}\n');
    var tasks = [
      for (var task in response.payload.tasks) Task.fromJson(json.decode(task)),
    ];
    mergeTasks(tasks);
    return response.header;
  }
}
