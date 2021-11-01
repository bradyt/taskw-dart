import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:built_collection/built_collection.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import 'package:taskc/storage.dart';
import 'package:taskc/taskd.dart';
import 'package:taskc/taskrc.dart';
import 'package:taskj/json.dart';

void main() {
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    stdout.writeln('${record.level.name}: ${record.time}: ${record.message}');
  });

  var taskd = Taskd(normalize(absolute('../fixture/var/taskd')));

  var uuid = const Uuid().v1();
  var home = Directory('test/taskc/tmp/$uuid').absolute.path;

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
    credentialsKey = Taskrc.fromString(File('$home/.taskrc').readAsStringSync())
        .credentials!
        .key;
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
    var now = DateTime.now().toUtc();
    expect(now.isUtc, true);
    [
      Task(
        (b) => b
          ..uuid = const Uuid().v1()
          ..status = 'pending'
          ..description = 'foo'
          ..entry = now
          ..modified = now
          ..tags = ListBuilder(const ['qux']),
      ),
      Task(
        (b) => b
          ..uuid = const Uuid().v1()
          ..status = 'waiting'
          ..description = 'bar'
          ..entry = now
          ..modified = now
          ..wait = now,
      ),
      Task(
        (b) => b
          ..uuid = const Uuid().v1()
          ..status = 'pending'
          ..description = 'baz'
          ..entry = now
          ..modified = now
          ..until = now,
      ),
    ].forEach(storage.data.mergeTask);
    storage.data.allData();
    for (var entry in {
      '.taskrc': '.taskrc',
      'taskd.ca': '.task/ca.cert.pem',
      'taskd.certificate': '.task/first_last.cert.pem',
      'taskd.key': '.task/first_last.key.pem',
    }.entries) {
      expect(() => storage.home.synchronize('test'),
          throwsA(isA<TaskserverConfigurationException>()));
      storage.guiPemFiles.addPemFile(
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
      await storage.home.statistics('test');
      await storage.home.synchronize('test');
    } on BadCertificateException catch (e) {
      await null;
      storage.guiPemFiles.addPemFile(
        key: 'server.cert',
        contents: e.certificate.pem,
      );
      await null;
    }

    await storage.home.synchronize('test');

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

    await storage.home.synchronize('test');

    var libExport = storage.data.export();

    expect(json.decode(libExport), json.decode(cliExport));
    expect(libExport, cliExport);
  });
}
