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
  File get _serverCert => File('${profile.path}/.task/server.cert.pem');

  Map<String, int> tags() {
    var listOfLists = pendingData().map((task) => task.tags);
    var listOfTags = listOfLists.expand((tags) => tags ?? []);
    var setOfTags = listOfTags.toSet();
    return SplayTreeMap.of({
      if (setOfTags.isNotEmpty)
        for (var tag in setOfTags) tag: 0,
    });
  }

  void updateWaitOrUntil(Iterable<Task> pendingData) {
    var now = DateTime.now();
    for (var task in pendingData) {
      if (task.until != null && task.until!.isBefore(now)) {
        mergeTask(
          task.copyWith(
            status: () => 'deleted',
            end: () => now,
          ),
        );
      } else if (task.status == 'waiting' &&
          (task.wait == null || task.wait!.isBefore(now))) {
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

  List<Task> pendingData() {
    var data = _allData().where(
        (task) => task.status != 'completed' && task.status != 'deleted');
    var now = DateTime.now();
    if (data.any((task) =>
        (task.until != null && task.until!.isBefore(now)) ||
        (task.status == 'waiting' &&
            (task.wait == null || task.wait!.isBefore(now))))) {
      updateWaitOrUntil(data);
      data = _allData().where(
          (task) => task.status != 'completed' && task.status != 'deleted');
    }
    return data
        .toList()
        .asMap()
        .entries
        .map((entry) => entry.value.copyWith(id: () => entry.key + 1))
        .toList();
  }

  List<Task> _completedData() {
    var data = _allData().where(
        (task) => task.status == 'completed' || task.status == 'deleted');
    return [
      for (var task in data) task.copyWith(id: () => 0),
    ];
  }

  List<Task> allData() {
    var data = pendingData()..addAll(_completedData());
    return data;
  }

  List<Task> _allData() => [
        if (File('${profile.path}/.task/all.data').existsSync())
          for (var line in File('${profile.path}/.task/all.data')
              .readAsStringSync()
              .trim()
              .split('\n'))
            if (line.isNotEmpty) Task.fromJson(json.decode(line)),
      ];

  String export() {
    var string = allData()
        .map((task) {
          var _task = task.toJson();

          _task['urgency'] = num.parse(urgency(task)
              .toStringAsFixed(1)
              .replaceFirst(RegExp(r'.0$'), ''));

          var keyOrder = [
            'id',
            'description',
            'end',
            'entry',
            'modified',
            'status',
            'until',
            'tags',
          ].asMap().map((key, value) => MapEntry(value, key));

          var fallbackOrder = _task.keys
              .toList()
              .asMap()
              .map((key, value) => MapEntry(value, key));

          for (var entry in fallbackOrder.entries) {
            keyOrder.putIfAbsent(
              entry.key,
              () => entry.value + keyOrder.length,
            );
          }

          return json.encode(SplayTreeMap.of(_task, (key1, key2) {
            return keyOrder[key1]!.compareTo(keyOrder[key2]!);
          }));
        })
        .toList()
        .join(',\n');
    return '[\n$string\n]\n';
  }

  void mergeTask(Task task) {
    _mergeTasks([task]);
    File('${profile.path}/.task/backlog.data').writeAsStringSync(
      '${json.encode(task.copyWith(id: () => null).toJson())}\n',
      mode: FileMode.append,
    );
  }

  Task getTask(String uuid) {
    return allData().firstWhere((task) => task.uuid == uuid);
  }

  void _mergeTasks(List<Task> tasks) {
    File('${profile.path}/.task/all.data').createSync(recursive: true);
    var lines = File('${profile.path}/.task/all.data')
        .readAsStringSync()
        .trim()
        .split('\n');
    var taskMap = {
      for (var taskLine in lines)
        if (taskLine.isNotEmpty)
          (json.decode(taskLine) as Map)['uuid']: taskLine,
    };
    for (var task in tasks) {
      taskMap[task.uuid] = json.encode(task.copyWith(id: () => null));
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
    late File file;
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
      case 'server.cert':
        file = _serverCert;
        break;
      default:
    }
    return file;
  }

  void addFileContents({required String key, required String contents}) {
    fileByKey(key).writeAsStringSync(contents);
  }

  Connection _getConnection(Map config) {
    var ca = '${profile.path}/.task/ca.cert.pem';
    var cert = '${profile.path}/.task/first_last.cert.pem';
    var key = '${profile.path}/.task/first_last.key.pem';
    var server = (config['taskd.server'] as String).split(':');
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
      onBadCertificate: (serverCert) {
        var file = File('${profile.path}/.task/server.cert.pem');
        if (file.existsSync() && serverCert.pem == file.readAsStringSync()) {
          return true;
        } else {
          throw BadCertificateException(
            profile: profile,
            certificate: serverCert,
          );
        }
      },
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
      for (var task in response.payload.tasks)
        Task.fromJson((json.decode(task) as Map)..remove('id')),
    ];
    _mergeTasks(tasks);
    File('${profile.path}/.task/backlog.data')
        .writeAsStringSync('${response.payload.userKey}\n');
    return response.header;
  }
}
