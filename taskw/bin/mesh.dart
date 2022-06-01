import 'dart:io';
import 'dart:convert';

import 'package:args/command_runner.dart';

import 'package:taskc/home_impl.dart' as home_impl;
import 'package:taskc/taskd.dart';
import 'package:taskc/taskrc.dart';
import 'package:taskj/json.dart';
import 'package:taskw/taskw.dart';

Future<int> main(List<String> args) async {
  var runner = CommandRunner(
    'mesh',
    'CLI utility to develop taskw-dart project.',
  )
    ..addCommand(NextCommand())
    ..addCommand(StatisticsCommand());
  await runner.run(args);

  return 0;
}

class NextCommand extends Command {
  @override
  String name = 'next';

  @override
  String description = 'Report next';

  @override
  List<String> aliases = [
    for (var i = 1; i < 'next'.length; i++) 'next'.substring(0, i),
  ];

  @override
  String category = 'Report next';

  @override
  Future<int> run() async {
    var width = stdout.terminalColumns;
    var height = stdout.terminalLines;
    var homePath = Platform.environment['HOME']!;
    var taskwarrior = Taskwarrior(homePath);
    var tasks = (json.decode(await taskwarrior.export()) as Iterable)
        .cast<Map>()
        .map(Task.fromJson)
        .where((task) => task.id != 0)
        .toList()
      ..sort((a, b) => -a.urgency!.compareTo(b.urgency!));
    var result = StringBuffer();
    var edge = '─' * (width - 4);
    for (var task in tasks) {
      var description = task.description;
      if (description.length > width - 4) {
        description = '${description.substring(0, width - 7)}...';
      }
      // var annotations = task.annotations?.length ?? 0;
      var firstLine = description.padRight(width - 4);
      var urgency = formatUrgency(task.urgency!);
      var left = '${task.id} ${age(task.entry)}'
              '${(task.due != null) ? ' d:${when(task.due!)}' : ''}'
              '${task.priority != null ? ' ${task.priority}' : ''}'
              '${(task.tags != null) ? ' ${task.tags}' : ''}'
          .trim();
      if (left.length > width - urgency.length - 4) {
        left = '${left.substring(0, width - urgency.length - 8).trim()}...';
      }
      var secondLine = '$left '.padRight(width - urgency.length - 4) + urgency;

      result.write(
        '''
╭─$edge─╮
│ $firstLine │
│ $secondLine │
╰─$edge─╯
''',
      );
    }
    result
        .toString()
        .trim()
        .split('\n')
        .take(height - 2)
        .forEach((line) => stdout.writeln(line));
    return 0;
  }
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
