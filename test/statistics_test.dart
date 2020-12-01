import 'dart:io';

import 'package:test/test.dart';

import 'package:taskc/taskc.dart';

void main() {
  var githubActions = Platform.environment['GITHUB_ACTIONS'] == 'true';
  var config = Config.fromTaskrc(
    githubActions ? '/root/.taskrc' : 'root/.taskrc',
    relative: !githubActions,
  );

  group('Test statistics', () {
    test('test', () async {
      var response = await statistics(config);
      expect(response.header['status'], 'Ok');
    });
  });
}
