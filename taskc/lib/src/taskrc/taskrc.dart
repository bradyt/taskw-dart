import 'dart:io';

import 'package:taskc/taskrc.dart';

class Taskrc {
  Taskrc({
    this.server,
    this.credentials,
  });

  factory Taskrc.fromHome(String home) {
    return Taskrc.fromString(
      File('$home/.taskrc').readAsStringSync(),
    );
  }

  factory Taskrc.fromString(String taskrc) {
    return Taskrc.fromMap(
      parseTaskrc(taskrc),
    );
  }

  factory Taskrc.fromMap(Map taskrc) {
    var server = taskrc['taskd.server'];
    var credentials = taskrc['taskd.credentials'];
    return Taskrc(
      server: (server == null) ? null : Server.fromString(server),
      credentials:
          (credentials == null) ? null : Credentials.fromString(credentials),
    );
  }

  final Server? server;
  final Credentials? credentials;
}
