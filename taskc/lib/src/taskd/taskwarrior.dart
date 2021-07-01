// ignore_for_file: unnecessary_lambdas

import 'dart:convert';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path/path.dart';

class Taskwarrior {
  Taskwarrior(String home)
      : _home = home,
        assert(
          isAbsolute(home),
          'Using absolute paths seems to ease maintenance.',
        );

  final String _home;
  final _log = Logger('Taskwarrior');

  Future<void> diagnostics() async {
    var result = await Process.start('task', ['diagnostics'],
        environment: {'HOME': _home});
    // stdout.write(result.stdout);
    // stderr.write(result.stderr);
    await result.stdout.transform(utf8.decoder).forEach((element) {
      _log.info(element);
    });
    // await Future.delayed(const Duration(milliseconds: 10));
  }

  Future<int> synchronize() async {
    var result = await Process.start('task', ['synchronize'],
        environment: {'HOME': _home});
    // stdout.write(result.stdout);
    // stderr.write(result.stderr);
    await result.stdout.transform(utf8.decoder).forEach((element) {
      _log.info(element);
    });
    await result.stderr.transform(utf8.decoder).forEach((element) {
      _log.info(element);
    });
    return result.exitCode;
    // await Future.delayed(const Duration(milliseconds: 10));
  }
  // Future<void> start() async {
  //   _process = await Process.start(
  //     'task',
  //     [
  //       'server',
  //       '--debug',
  //     ],
  //     environment: {'TASKDDATA': _taskddata},
  //   );

  //   var serverReady = false;

  //   unawaited(_process.stdout.transform(utf8.decoder).forEach(
  //     (element) {
  //       if (element.contains('Server ready')) {
  //         serverReady = true;
  //       }
  //       _log.info(element);
  //     },
  //   ));

  //   while (serverReady == false) {
  //     await Future.delayed(const Duration(milliseconds: 10));
  //   }
  // }

  // Future<void> kill() async {
  //   _process.kill(ProcessSignal.sigkill);
  // }
}
