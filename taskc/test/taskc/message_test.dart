import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:pedantic/pedantic.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import 'package:taskc/json.dart';
import 'package:taskc/taskc.dart';
import 'package:taskc/taskc_impl.dart';
import 'package:taskc/taskd.dart';
import 'package:taskc/taskrc.dart';

void main() {
  var uuid = const Uuid().v1();
  var taskdData = Directory('../fixture/var/taskd').absolute.path;
  var taskd = Taskd(taskdData);
  var home = Directory('test/taskd/tmp/$uuid').absolute.path;
  late Map<String, String> config;
  late List<String> server;
  late Connection connection;
  late Credentials credentials;

  setUpAll(() async {
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

    config = parseTaskrc(
      File('$home/.taskrc').readAsStringSync(),
    );
    server = (config['taskd.server']!).split(':');
    connection = Connection(
      address: server[0],
      port: int.parse(server[1]),
      context: SecurityContext()
        ..useCertificateChain(config['taskd.certificate']!)
        ..usePrivateKey(config['taskd.key']!),
      onBadCertificate: (_) => true,
    );
    credentials = Credentials.fromString(config['taskd.credentials']!);
  });

  tearDownAll(() async {
    await taskd.kill();
  });

  group('Test statistics', () {
    test('test', () async {
      var response = await statistics(
        connection: connection,
        credentials: credentials,
      );
      expect(response.header['status'], 'Ok');
    });
  });

  String newTask() => json.encode(
        Task(
          status: 'pending',
          uuid: const Uuid().v1(),
          entry: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
          description: 'test',
        ).toJson(),
      );

  group('Test synchronize', () {
    String? userKey;

    test('test first sync with one task', () async {
      var response = await synchronize(
        connection: connection,
        credentials: credentials,
        payload: '${Payload(tasks: [newTask()])}',
      );

      userKey = response.payload.userKey;

      expect(response.header['client'], 'taskd 1.1.0');
      expect(response.header['code'], '200');
      expect(response.header['status'], 'Ok');
    });

    test('test second sync with userKey and no tasks', () async {
      var response = await synchronize(
        connection: connection,
        credentials: credentials,
        payload: '${Payload(tasks: [], userKey: userKey)}',
      );

      expect(response.header['client'], 'taskd 1.1.0');
      expect(response.header['code'], '201');
      expect(response.header['status'], 'No change');
    });
    test('test response with more than 2^13th bytes', () async {
      var payload = Payload(
        tasks: List.generate(100, (_) => newTask()).toList(),
      ).toString();

      expect(Codec.encode(payload).length > pow(2, 13), true);

      await synchronize(
        connection: connection,
        credentials: credentials,
        payload: payload,
      );

      var response = await synchronize(
        connection: connection,
        credentials: credentials,
        payload: '',
      );

      expect(Codec.encode('${response.payload}').length > pow(2, 13), true);
      expect(response.header['status'], 'Ok');
    });
    test('count tasks', () async {
      await File(
              '../fixture/var/taskd/orgs/Public/users/${credentials.key}/tx.data')
          .delete();

      await synchronize(
        connection: connection,
        credentials: credentials,
        payload: '${newTask()}\n${newTask()}',
      );

      var response = await synchronize(
        connection: connection,
        credentials: credentials,
        payload: '',
      );

      expect(response.payload.tasks.length, 2);
    });
    test('too many tasks', () async {
      var payload = '{"description":"foo"}\n' * (pow(2, 16) as int);

      var response = await synchronize(
        connection: connection,
        credentials: credentials,
        payload: payload,
      );

      expect(response.header['code'], '504');
      expect(response.header['status'], 'Request too big');

      payload = '{"description":"foo"}\n' * (pow(2, 15) as int);

      response = await synchronize(
        connection: connection,
        credentials: credentials,
        payload: payload,
      );

      expect(response.header['code'], '200');
      expect(response.header['status'], 'Ok');
    });
  });
}
