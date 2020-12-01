import 'dart:io';

import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import 'package:taskc/taskc.dart';

void main() {
  var githubActions = Platform.environment['GITHUB_ACTIONS'] == 'true';
  var home = Platform.environment['HOME'];
  var pathTo = githubActions ? home : 'fixture';
  var config = {
    for (var pair in File('$pathTo/.taskrc')
        .readAsStringSync()
        .split('\n')
        .where((line) => line.contains('=') && line[0] != '#')
        .map((line) => line.replaceAll('\\/', '/'))
        .map((line) => line.split('=')))
      pair[0]: pair[1],
  };
  var server = config['taskd.server'].split(':');
  var connection = Connection(
    address: server[0],
    port: int.parse(server[1]),
    context: SecurityContext()
      ..useCertificateChain(config['taskd.certificate'])
      ..usePrivateKey(config['taskd.key']),
    onBadCertificate: (_) => true,
  );
  var credentials = Credentials.fromString(config['taskd.credentials']);

  group('Test statistics', () {
    test('test', () async {
      var response = await statistics(
        connection: connection,
        credentials: credentials,
      );
      expect(response.header['status'], 'Ok');
    });
  });

  Task newTask() => Task(
        status: 'pending',
        uuid: Uuid().v1(),
        entry: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
        description: 'test',
      );

  group('Test synchronize', () {
    String userKey;

    test('test', () async {
      var response = await synchronize(
        connection: connection,
        credentials: credentials,
        payload: Payload(tasks: [newTask()]),
      );

      userKey = response.payload.userKey;

      expect(response.header['client'], 'taskd 1.1.0');
      expect(response.header['code'], '200');
      expect(response.header['status'], 'Ok');
    });
    test('test', () async {
      var response = await synchronize(
        connection: connection,
        credentials: credentials,
        payload: Payload(tasks: [], userKey: userKey),
      );

      expect(response.header['client'], 'taskd 1.1.0');
      expect(response.header['code'], '201');
      expect(response.header['status'], 'No change');
    });
  });
}
