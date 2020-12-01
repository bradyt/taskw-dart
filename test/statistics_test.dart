import 'dart:io';

import 'package:test/test.dart';

import 'package:taskc/taskc.dart';

void main() {
  var githubActions = Platform.environment['GITHUB_ACTIONS'] == 'true';
  var home = Platform.environment['HOME'];
  var pathTo = githubActions ? home : 'fixture';
  var config = Config.fromTaskrc('$pathTo/.taskrc');

  group('Test statistics', () {
    test('test', () async {
      var response = await statistics(config);
      expect(response.header['status'], 'Ok');
    });
  });
}
