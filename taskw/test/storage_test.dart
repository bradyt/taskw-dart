import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import 'package:taskc/taskc.dart';

import 'package:taskw/taskw.dart';

void main() {
  var credentialsKey = Credentials.fromString(
    parseTaskrc(
      File(
        '../fixture/.taskrc',
      ).readAsStringSync(),
    )['taskd.credentials'],
  ).key;

  var txData = File(
    '../fixture/var/taskd/orgs/Public/users/$credentialsKey/tx.data',
  );

  test('test profiles', () async {
    if (txData.existsSync()) {
      txData.deleteSync();
    }

    var storage = Storage(
      Directory(
        'test/profile-testing/storage/${const Uuid().v1()}',
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
        contents: File('../fixture/${entry.value}').readAsStringSync(),
      );
    }

    try {
      await storage.synchronize();
    } on BadCertificateException catch (e) {
      storage.addFileContents(
        key: 'server.cert',
        contents: e.certificate.pem,
      );
    }

    await storage.synchronize();

    for (var data in ['backlog', 'pending', 'completed']) {
      var dataFile = File('../fixture/.task/$data.data');
      if (dataFile.existsSync()) {
        dataFile.deleteSync();
      }
    }

    Process.runSync('task', ['sync'],
        workingDirectory: '..', environment: {'HOME': 'fixture'});
    Process.runSync('task', [],
        workingDirectory: '..', environment: {'HOME': 'fixture'});
    var cliExport = Process.runSync('task', ['export'],
        workingDirectory: '..', environment: {'HOME': 'fixture'}).stdout;
    Process.runSync('task', ['sync'],
        workingDirectory: '..', environment: {'HOME': 'fixture'});

    await storage.synchronize();

    var libExport = storage.export();

    expect(json.decode(libExport), json.decode(cliExport));
    expect(libExport, cliExport);
  });
}
