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
    await result.stdout.transform(utf8.decoder).forEach((element) {
      _log.info(element);
    });
  }

  Future<void> config(List<String> rest) async {
    await Process.start('task', ['rc.confirmation:no', 'config', ...rest],
        environment: {'HOME': _home});
  }

  Future<String> export() async {
    var result = await Process.start('task', ['rc.confirmation:no', 'export'],
        environment: {'HOME': _home});
    return result.stdout.transform(utf8.decoder).first;
  }

  Future<int> add(List<String> rest) async {
    var result = await Process.start(
        'task', ['rc.confirmation:no', 'add', ...rest],
        environment: {'HOME': _home});
    await result.stdout.transform(utf8.decoder).forEach((element) {
      _log.info(element);
    });
    await result.stderr.transform(utf8.decoder).forEach((element) {
      _log.info(element);
    });
    return result.exitCode;
  }

  Future<int> modify(List<String> rest) async {
    var result = await Process.start(
        'task', ['rc.confirmation:no', 'modify', ...rest],
        environment: {'HOME': _home});
    await result.stdout.transform(utf8.decoder).forEach((element) {
      _log.info(element);
    });
    await result.stderr.transform(utf8.decoder).forEach((element) {
      _log.info(element);
    });
    return result.exitCode;
  }

  Future<int> synchronize() async {
    var result = await Process.start('task', ['synchronize'],
        environment: {'HOME': _home});
    await result.stdout.transform(utf8.decoder).forEach((element) {
      _log.info(element);
    });
    await result.stderr.transform(utf8.decoder).forEach((element) {
      _log.info(element);
    });
    return result.exitCode;
  }
}
