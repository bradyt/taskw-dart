import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:test/test.dart';

import 'package:taskc/taskc.dart';

void main() {
  group('Test rc parse', () {
    var tc;

    setUp(() {
      tc = TaskdConnection.fromTaskrc('fixture/taskrc');
    });

    test('First Test', () {
      expect(tc.clientCert, '/Users/alice/.task/brady_trainor.cert.pem');
      expect(tc.clientKey, '/Users/alice/.task/brady_trainor.key.pem');
      expect(tc.cacertFile, '/Users/alice/.task/ca.cert.pem');
      expect(tc.server, 'localhost');
      expect(tc.port, 53589);
      expect(tc.group, 'Public');
      expect(tc.username, 'Brady Trainor');
      expect(tc.uuid, '69eeece5-bcda-4ba2-a34c-70fdbbbe6187');
    });
  });
  group('Test socket', () {
    var tc;
    setUp(() {
      var home = Platform.environment['HOME'];
      tc = TaskdConnection(
        clientCert: '$home/.task/brady_trainor.cert.pem',
        clientKey: '$home/.task/brady_trainor.key.pem',
        cacertFile: '$home/.task/ca.cert.pem',
        server: 'localhost',
        port: 53589,
        group: 'Public',
        username: 'Brady Trainor',
        uuid: '69eeece5-bcda-4ba2-a34c-70fdbbbe6187',
      );
    });

    test('test socket', () async {
      var response =
          await tc.sendMessageAsBytes(Uint8List.fromList([0, 0, 0, 5, 65]));

      expect(response.length, 69);
    }, skip: true);
  });
  group('Test message encoding/decoding', () {
    var messageBytes;
    var messageString;
    setUp(() {
      messageBytes = Uint8List.fromList(List.from(json.decode(
          '[0, 0, 0, 69, 99, 108, 105, 101, 110, 116, 58, 32, 116, 97, 115, 107, 100, 32, 49, 46, 49, 46, 48, 10, 99, 111, 100, 101, 58, 32, 53, 48, 48, 10, 115, 116, 97, 116, 117, 115, 58, 32, 69, 82, 82, 79, 82, 58, 32, 77, 97, 108, 102, 111, 114, 109, 101, 100, 32, 109, 101, 115, 115, 97, 103, 101, 10, 10, 10]')));
      messageString = '''
client: taskd 1.1.0
code: 500
status: ERROR: Malformed message


''';
    });

    test('test decode', () async {
      expect(utf8.decode(messageBytes.skip(4).toList()), messageString);
    });
  });
}
