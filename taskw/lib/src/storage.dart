import 'dart:convert';
import 'dart:io';

import 'package:taskc/taskc.dart';

class Storage {
  Storage(this.profile);

  Directory profile;

  List<Task> listTasks() => [
        if (File('${profile.path}/.task/pending.data').existsSync())
          for (var line in File('${profile.path}/.task/pending.data')
              .readAsStringSync()
              .trim()
              .split('\n'))
            Task.fromJson(json.decode(line)),
      ];

  void addTask(Task task) {
    Directory('${profile.path}/.task').createSync(recursive: true);
    File('${profile.path}/.task/pending.data').writeAsStringSync(
      '${json.encode(task.toJson())}\n',
      mode: FileMode.append,
    );
  }
}
