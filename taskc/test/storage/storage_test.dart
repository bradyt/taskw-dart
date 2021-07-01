import 'dart:convert';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path/path.dart';
import 'package:pedantic/pedantic.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import 'package:taskc/json.dart';
import 'package:taskc/storage.dart';
import 'package:taskc/taskc.dart';
import 'package:taskc/taskd.dart';
import 'package:taskc/taskrc.dart';

void main() {
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    stdout.writeln('${record.level.name}: ${record.time}: ${record.message}');
  });

  var taskd = Taskd(normalize(absolute('../fixture/var/taskd')));

  var uuid = const Uuid().v1();
  var home = Directory('test/taskd/tmp/$uuid').absolute.path;

  late String credentialsKey;
  late File txData;

  setUpAll(() async {
    await Directory(home).create(recursive: true);
    await taskd.initialize();
    await taskd.setAddressAndPort(
      address: 'localhost',
      port: 53589,
    );
    unawaited(taskd.start());
    await Future.delayed(const Duration(seconds: 1));

    var userKey = await taskd.addUser('First Last');
    await taskd.initializeClient(
      home: home,
      address: 'localhost',
      port: 53589,
      fullName: 'First Last',
      fileName: 'first_last',
      userKey: userKey,
    );
    credentialsKey = Credentials.fromString(
      parseTaskrc(
        File(
          '$home/.taskrc',
        ).readAsStringSync(),
      )['taskd.credentials']!,
    ).key;
    txData = File(
      '../fixture/var/taskd/orgs/Public/users/$credentialsKey/tx.data',
    );
  });

  tearDownAll(() async {
    await taskd.kill();
  });

  test('test profiles', () async {
    if (txData.existsSync()) {
      txData.deleteSync();
    }
    var uuid = const Uuid().v1();

    var storage = Storage(
      Directory(
        'test/profile-testing/storage/$uuid',
      ),
    );
    [
      Task(
        uuid: const Uuid().v1(),
        status: 'pending',
        description: 'foo',
        entry: DateTime.now(),
        modified: DateTime.now(),
        tags: const ['qux'],
      ),
      Task(
        uuid: const Uuid().v1(),
        status: 'waiting',
        description: 'bar',
        entry: DateTime.now(),
        modified: DateTime.now(),
        wait: DateTime.now(),
      ),
      Task(
        uuid: const Uuid().v1(),
        status: 'pending',
        description: 'baz',
        entry: DateTime.now(),
        modified: DateTime.now(),
        until: DateTime.now(),
      ),
    ].forEach(storage.mergeTask);
    storage
      ..tags()
      ..allData();
    for (var entry in {
      '.taskrc': '.taskrc',
      'taskd.ca': '.task/ca.cert.pem',
      'taskd.cert': '.task/first_last.cert.pem',
      'taskd.key': '.task/first_last.key.pem',
    }.entries) {
      expect(() => storage.synchronize(),
          throwsA(isA<TaskserverConfigurationException>()));
      storage.addFileContents(
        key: entry.key,
        contents: File('$home/${entry.value}').readAsStringSync(),
      );
    }

    var taskwarrior =
        Taskwarrior(absolute('test/profile-testing/storage/$uuid'));

    var result = await Process.run('taskd', ['server', '--debug'],
        environment: {'TASKDDATA': '../fixture/var/taskd'});
    stdout.writeln(result.stdout);
    stderr.writeln(result.stderr);

    try {
      await taskwarrior.diagnostics();
      var exitCode = await taskwarrior.synchronize();
      stdout.writeln(exitCode);
      await storage.statistics();
      await storage.synchronize();
    } on BadCertificateException catch (e) {
      await null;
      storage.addFileContents(
        key: 'server.cert',
        contents: e.certificate.pem,
      );
      await null;
    }

    await storage.synchronize();

    for (var data in ['backlog', 'pending', 'completed']) {
      var dataFile = File('$home/.task/$data.data');
      if (dataFile.existsSync()) {
        dataFile.deleteSync();
      }
    }

    await Future.delayed(const Duration(milliseconds: 333));
    Process.runSync('task', ['sync'], environment: {'HOME': home});
    await Future.delayed(const Duration(milliseconds: 333));
    Process.runSync('task', [], environment: {'HOME': home});
    await Future.delayed(const Duration(milliseconds: 333));
    var cliExport =
        Process.runSync('task', ['export'], environment: {'HOME': home}).stdout;
    Process.runSync('task', ['sync'], environment: {'HOME': home});

    await storage.synchronize();

    var libExport = storage.export();

    expect(json.decode(libExport), json.decode(cliExport));
    expect(libExport, cliExport);
  });
}
