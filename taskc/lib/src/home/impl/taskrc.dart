import 'dart:io';

import 'package:taskc/taskrc.dart' as rc;

class Taskrc {
  const Taskrc(this.home);

  final Directory home;

  void addTaskrc(String taskrc) {
    File('${home.path}/.taskrc').writeAsStringSync(taskrc);
  }

  rc.Server? server() {
    return rc.Taskrc.fromHome(home.path).server;
  }

  rc.Credentials? credentials() {
    return rc.Taskrc.fromHome(home.path).credentials;
  }
}
