import 'dart:io';

import 'package:taskc/home_impl.dart';
import 'package:taskc/taskrc.dart';
import 'package:taskj/json.dart';

class Home {
  const Home(this.home);

  final Directory home;

  Data get _data => Data(home);
  TaskdClient get _taskdClient => TaskdClient(home);

  void addTask(Task task) {
    _data.mergeTask(task);
  }

  void mergeTask(Task task) {
    _data.mergeTask(task);
  }

  Task getTask(String uuid) {
    return _data.getTask(uuid);
  }

  List<Task> allData() {
    return _data.allData();
  }

  List<Task> pendingData() {
    return _data.pendingData();
  }

  String export() {
    return _data.export();
  }

  void removeTaskdCa() {
    _taskdClient.removeTaskdCa();
  }

  void removeServerCert() {
    _taskdClient.removeServerCert();
  }

  bool serverCertExists() {
    return _taskdClient.serverCertExists();
  }

  void addPemFile({
    required String key,
    required String contents,
    String? name,
  }) {
    _taskdClient.addFileContents(key: key, contents: contents);
    if (name != null) {
      _taskdClient.addFileName(key: key, name: name);
    }
  }

  String? pemFilename(String key) {
    return _taskdClient.pemName(key);
  }

  String? pemContents(String key) {
    if (_taskdClient.fileByKey(key).existsSync()) {
      return _taskdClient.fileByKey(key).readAsStringSync();
    }
  }

  void addTaskrc(String taskrc) {
    File('${home.path}/.taskrc').writeAsStringSync(taskrc);
  }

  Server? server() {
    return Taskrc.fromHome(home.path).server;
  }

  Credentials? credentials() {
    return Taskrc.fromHome(home.path).credentials;
  }

  Future<Map> statistics(String client) {
    return _taskdClient.statistics(client);
  }

  Future<Map> synchronize(String client) {
    return _data.synchronize(client);
  }
}
