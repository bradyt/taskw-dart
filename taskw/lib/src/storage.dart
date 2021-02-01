// ignore_for_file: prefer_expression_function_bodies

import 'dart:collection';
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

  Map<String, int> tags() {
    var listOfLists = pendingData().values.map((task) => task.tags);
    var listOfTags = listOfLists.expand((tags) => tags ?? []);
    var setOfTags = listOfTags.toSet() ?? {};
    return SplayTreeMap.of({
      if (setOfTags.isNotEmpty)
        for (var tag in setOfTags) tag: 0,
    });
  }

  void updateWaitOrUntil(Iterable<Task> pendingData) {
    var now = DateTime.now();
    for (var task in pendingData) {
      if (task.until != null && task.until.isBefore(now)) {
        mergeTask(
          task.copyWith(
            status: () => 'deleted',
            end: () => now,
          ),
        );
      } else if (task.status == 'waiting' &&
          (task.wait == null || task.wait.isBefore(now))) {
        _mergeTasks(
          [
            task.copyWith(
              status: () => 'pending',
              wait: () => null,
            ),
          ],
        );
      }
    }
  }

  Map<int, Task> pendingData() {
    var data = allData().where(
        (task) => task.status != 'completed' && task.status != 'deleted');
    var now = DateTime.now();
    if (data.any((task) =>
        (task.until != null && task.until.isBefore(now)) ||
        (task.status == 'waiting' &&
            (task.wait == null || task.wait.isBefore(now))))) {
      updateWaitOrUntil(data);
      data = allData().where(
          (task) => task.status != 'completed' && task.status != 'deleted');
    }
    return SplayTreeMap.of(Map.fromEntries(data
        .toList()
        .asMap()
        .entries
        .map((entry) => MapEntry(entry.key + 1, entry.value))));
  }

  List<Task> allData() => [
        if (File('${profile.path}/.task/all.data').existsSync())
          for (var line in File('${profile.path}/.task/all.data')
              .readAsStringSync()
              .trim()
              .split('\n'))
            if (line.isNotEmpty) Task.fromJson(json.decode(line)),
      ];

  void mergeTask(Task task) {
    _mergeTasks([task]);
    File('${profile.path}/.task/backlog.data').writeAsStringSync(
      '${json.encode(task.toJson())}\n',
      mode: FileMode.append,
    );
  }

  Task getTask(String uuid) {
    if (File('${profile.path}/.task/all.data').existsSync()) {
      return File('${profile.path}/.task/all.data')
          .readAsStringSync()
          .trim()
          .split('\n')
          .where((line) => line.isNotEmpty)
          .map((line) => Task.fromJson(json.decode(line)))
          .firstWhere((task) => task.uuid == uuid);
    }
    return null;
  }

  void _mergeTasks(List<Task> tasks) {
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
    if (server[0] == 'localhost') {
      if (Platform.isAndroid) {
        server[0] = '10.0.2.2';
      }
    }
    return Connection(
      address: server[0],
      port: int.parse(server[1]),
      context: SecurityContext()
        ..setTrustedCertificates(ca)
        ..useCertificateChain(cert)
        ..usePrivateKey(key),
      onBadCertificate:
          (Platform.isIOS || Platform.isMacOS) ? (_) => true : null,
    );
  }

  Credentials _getCredentials(Map config) =>
      Credentials.fromString(config['taskd.credentials']);

  Map getConfig() {
    return parseTaskrc(_taskrc.readAsStringSync());
  }

  void checkFilesExist() {
    if (!_taskrc.existsSync()) {
      throw TaskserverConfigurationException(
        'Missing: .taskrc\n\n'
        'If you want to configure your Taskserver, '
        'please add your .taskrc or taskrc.txt configuration to this profile.',
      );
    }
    if (!_ca.existsSync()) {
      throw TaskserverConfigurationException(
        'Missing: taskd.ca\n\n'
        'If you want to configure your Taskserver, '
        'please add your taskd.ca file to this profile.',
      );
    }
    if (!_cert.existsSync()) {
      throw TaskserverConfigurationException(
        'Missing: taskd.cert\n\n'
        'If you want to configure your Taskserver, '
        'please add your taskd.ca file to this profile.',
      );
    }
    if (!_key.existsSync()) {
      throw TaskserverConfigurationException(
        'Missing: taskd.key\n\n'
        'If you want to configure your Taskserver, '
        'please add your taskd.ca file to this profile.',
      );
    }
  }

  Future<Map> statistics() async {
    checkFilesExist();
    var config = getConfig();
    var response = await taskc.statistics(
      connection: _getConnection(config),
      credentials: _getCredentials(config),
    );
    return response.header;
  }

  Future<Map> synchronize() async {
    checkFilesExist();
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
    var tasks = [
      for (var task in response.payload.tasks) Task.fromJson(json.decode(task)),
    ];
    _mergeTasks(tasks);
    File('${profile.path}/.task/backlog.data')
        .writeAsStringSync('${response.payload.userKey}\n');
    return response.header;
  }
}
