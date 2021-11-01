import 'dart:io';

import 'package:taskc/home_impl.dart';
import 'package:taskc/storage.dart';
import 'package:taskc/taskrc.dart';
import 'package:taskj/json.dart';

class Home {
  const Home({
    required this.home,
    this.pemFilePaths,
    this.onBadCertificate,
  });

  final Directory home;
  final PemFilePaths? pemFilePaths;
  final bool Function(X509Certificate)? onBadCertificate;

  Data get _data => Data(home);

  TaskdClient _taskdClient(client) => TaskdClient(
        taskrc: Taskrc.fromHome(home.path),
        client: client,
        pemFilePaths: pemFilePaths,
        throwOnBadCertificate: (badCertificate) =>
            throw BadCertificateException(
          home: home,
          certificate: badCertificate,
        ),
      );

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
    return _taskdClient(client).statistics();
  }

  Future<Map> synchronize(String client) async {
    var _payload = _data.payload();
    var response = await _taskdClient(client).synchronize(
      _payload,
    );
    _data.mergeSynchronizeResponse(response.payload);
    return response.header;
  }
}
