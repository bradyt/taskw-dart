import 'dart:io';

import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import 'package:taskc/taskc.dart';

void main() {
  Config config;
  var githubActions = Platform.environment['GITHUB_ACTIONS'] == 'true';

  if (!githubActions) {
    config = Config.fromTaskrc('docker/home/.taskrc', relative: true);
  }

  Task newTask() => Task(
        status: 'pending',
        uuid: Uuid().v1(),
        entry: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
        description: 'test',
      );

  group('Test synchronize', () {
    String userKey;

    test('test', () async {
      var response = await synchronize(config, Payload(tasks: [newTask()]));

      userKey = response.payload.userKey;

      expect(response.header['client'], 'taskd 1.1.0');
      expect(response.header['code'], '200');
      expect(response.header['status'], 'Ok');
    }, skip: githubActions);
    test('test', () async {
      var response = await synchronize(config, Payload(userKey: userKey));

      expect(response.header['client'], 'taskd 1.1.0');
      expect(response.header['code'], '201');
      expect(response.header['status'], 'No change');
    }, skip: githubActions);
  });
}
