import 'dart:io';

import 'package:taskc/home_impl.dart';
import 'package:taskc/taskrc.dart';
import 'package:taskj/json.dart';

class Home {
  const Home(this.home);

  final Directory home;

  HomeImpl get _homeImpl => HomeImpl(home);
  TaskdClient get _taskdClient => TaskdClient(home);

  void addTask(Task task) {
    _homeImpl.mergeTask(task);
  }

  void mergeTask(Task task) {
    _homeImpl.mergeTask(task);
  }

  Task getTask(String uuid) {
    return _homeImpl.getTask(uuid);
  }

  List<Task> allData() {
    return _homeImpl.allData();
  }

  List<Task> pendingData() {
    return _homeImpl.pendingData();
  }

  String export() {
    return _homeImpl.export();
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

  Map getConfig() {
    return parseTaskrc(File('${home.path}/.taskrc').readAsStringSync());
  }

  Future<Map> statistics(String client) {
    return _taskdClient.statistics(client);
  }

  Future<Map> synchronize(String client) {
    return _homeImpl.synchronize(client);
  }
}
