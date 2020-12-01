import 'dart:io';

import 'package:test/test.dart';

import 'package:taskc/taskc.dart';

void main() {
  var config;
  var githubActions = Platform.environment['GITHUB_ACTIONS'] == 'true';

  if (!githubActions) {
    config = Config.fromTaskrc('docker/home/.taskrc', relative: true);
  }

  group('Test synchronize', () {
    test('test', () async {
      var response = await synchronize(
          config,
          Payload(
            tasks: [Task(description: 'test')],
          ));
      expect(response.header['client'], 'taskd 1.1.0');
      expect(response.header['code'] == '500', false);
    }, skip: githubActions);
  });
}
