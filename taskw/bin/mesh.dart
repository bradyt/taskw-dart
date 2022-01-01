import 'dart:io';
import 'dart:convert';

import 'package:args/command_runner.dart';

import 'package:taskc/home_impl.dart' as home_impl;
import 'package:taskc/taskrc.dart';

Future<int> main(List<String> args) async {
  var runner = CommandRunner(
    'mesh',
    'CLI utility to develop taskw-dart project.',
  )..addCommand(StatisticsCommand());
  await runner.run(args);

  return 0;
}

class StatisticsCommand extends Command {
  @override
  String name = 'statistics';

  @override
  String description = 'Send statistics request to your Taskserver';

  @override
  List<String> aliases = [
    for (var i = 1; i < 'statistics'.length; i++) 'statistics'.substring(0, i),
  ];

  @override
  String category = 'taskd client';

  @override
  Future<int> run() async {
    var homePath = Platform.environment['HOME']!;
    var taskrc = parseTaskrc(await File('$homePath/.taskrc').readAsString())
      ..updateAll((_, value) => value.replaceAll('~', homePath));
    var taskdClient = home_impl.TaskdClient(
      taskrc: Taskrc.fromMap(taskrc),
    );
    taskdClient.progress.listen((event) {
      stdout.writeln(event);
    });
    var response = await taskdClient.request(type: 'statistics');
    var stats = response.header;
    stdout
      ..write('Statistics: ')
      ..writeln(const JsonEncoder.withIndent('  ').convert(stats));
    return 0;
  }
}
