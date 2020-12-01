import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:test/test.dart';

import 'package:taskc/taskc.dart';

void main() {
  var githubActions = Platform.environment['GITHUB_ACTIONS'] == 'true';

  group('Test connection', () {
    var connection;
    setUp(() {
      connection = Connection(
        address: 'localhost',
        port: 53589,
        certificate: 'docker/home/.task/brady_trainor.cert.pem',
        key: 'docker/home/.task/brady_trainor.key.pem',
        ca: 'docker/home/.task/ca.cert.pem',
      );
    });

    test('test message \'A\'', () async {
      var response =
          await connection.send(Uint8List.fromList([0, 0, 0, 5, 65]));
      var expectedResponse =
          File('test/examples/malformed_message.msg').readAsStringSync();

      expect(utf8.decode(response.sublist(4)), expectedResponse);
    }, skip: githubActions);
  });
}
