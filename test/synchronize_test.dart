import 'dart:io';

import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import 'package:taskc/taskc.dart';

void main() {
  var githubActions = Platform.environment['GITHUB_ACTIONS'] == 'true';
  var home = Platform.environment['HOME'];
  var pathTo = githubActions ? home : 'fixture';
  var config = Config.fromTaskrc('$pathTo/.taskrc');

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
    });
    test('test', () async {
      var response =
          await synchronize(config, Payload(tasks: [], userKey: userKey));

      expect(response.header['client'], 'taskd 1.1.0');
      expect(response.header['code'], '201');
      expect(response.header['status'], 'No change');
    });
  });
}
