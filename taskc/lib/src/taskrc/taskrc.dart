import 'dart:io';

import 'package:taskc/taskrc.dart';

class Taskrc {
  Taskrc({
    required this.server,
    required this.credentials,
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
    return Taskrc(
      server: Server.fromString(taskrc['taskd.server']),
      credentials: Credentials.fromString(taskrc['taskd.credentials']),
    );
  }

  final Server server;
  final Credentials credentials;
}
