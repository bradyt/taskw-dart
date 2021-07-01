import 'dart:convert';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path/path.dart';
import 'package:pedantic/pedantic.dart';

import 'package:taskc/taskd.dart';

// toc: https://taskwarrior.org/docs/taskserver/setup.html

class Taskd {
  Taskd(this.taskdData)
      : assert(
          isAbsolute(taskdData),
          'Using absolute paths seems to ease maintenance.',
        );

  final String taskdData;
  late Process _process;
  final _log = Logger('TaskdProcess');

  Future<void> initialize() async {
    for (var arguments in [
      ['init'],
      for (var key in [
        'client.cert',
        'client.key',
        'server.cert',
        'server.key',
        'server.crl',
        'ca.cert',
      ])
        ['config', '--force', key, '$taskdData/$key.pem'],
      ['config', '--force', 'log', '$taskdData/taskd.log'],
      ['config', '--force', 'pid.file', '$taskdData/taskd.pid'],
      ['config', '--force', 'debug.tls', '2'],
      ['add', 'org', 'Public'],
    ]) {
      await Process.run('taskd', arguments,
          environment: {'TASKDDATA': taskdData});
    }
  }

  Future<String> addUser(String fullName) async {
    var result = await Process.run('taskd', ['add', 'user', 'Public', fullName],
        environment: {'TASKDDATA': taskdData});
    return (result.stdout as String).split('\n').first.split(': ').last.trim();
  }

  Future<void> setAddressAndPort({
    required String address,
    required int port,
  }) =>
      Process.run('taskd', ['config', 'server', '$address:$port'],
          environment: {'TASKDDATA': taskdData});

  Future<Taskwarrior> initializeClient({
    required String home,
    required String address,
    required int port,
    required String userKey,
    required String fullName,
    required String fileName,
  }) async {
    if (!isAbsolute(home)) {
      throw PathException(
          'Please use absolute path for HOME, instead of $home');
    }
    await Directory('$home/.task').create(recursive: true);
    for (var file in [
      '$fileName.cert.pem',
      '$fileName.key.pem',
      'ca.cert.pem',
    ]) {
      await File('$taskdData/pki/$file').copy('$home/.task/$file');
    }
    for (var rest in [
      ['taskd.certificate', '$home/.task/$fileName.cert.pem'],
      ['taskd.key', '$home/.task/$fileName.key.pem'],
      ['taskd.ca', '$home/.task/ca.cert.pem'],
      ['taskd.server', '$address:$port'],
      ['taskd.credentials', 'Public/$fullName/$userKey'],
    ]) {
      await Process.run('task', ['rc.confirmation:no', 'config', ...rest],
          environment: {'HOME': home});
    }
    return Taskwarrior(home);
  }

  Future<void> start() async {
    _process = await Process.start(
      'taskd',
      [
        'server',
        '--debug',
      ],
      environment: {'TASKDDATA': taskdData},
    );

    var serverReady = false;

    unawaited(_process.stdout.transform(utf8.decoder).forEach(
      (element) {
        if (element.contains('Server ready')) {
          serverReady = true;
        }
        _log.info(element);
      },
    ));

    while (serverReady == false) {
      await Future.delayed(const Duration(milliseconds: 10));
    }
  }

  Future<void> kill() async {
    _process.kill(ProcessSignal.sigkill);
  }
}
