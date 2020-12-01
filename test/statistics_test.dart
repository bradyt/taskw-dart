import 'dart:io';

import 'package:test/test.dart';

import 'package:taskc/taskc.dart';

void main() {
  Config config;
  var githubActions = Platform.environment['GITHUB_ACTIONS'] == 'true';

  if (!githubActions) {
    config = Config.fromTaskrc('docker/home/.taskrc', relative: true);
  }

  group('Test statistics', () {
    test('test', () async {
      var response = await statistics(config);
      expect(response.header['status'], 'Ok');
    }, skip: githubActions);
  });
}
