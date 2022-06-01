// ignore_for_file: lines_longer_than_80_chars

import 'dart:io';

import 'package:path/path.dart';
import 'package:test/test.dart';

import 'package:taskc/fingerprint.dart';

void main() {
  var certtool = (Platform.isMacOS) ? 'gnutls-certtool' : 'certtool';

  test(r'test $TASKDDATA/pki certs', () async {
    var taskddata = normalize(absolute('../fixture/var/taskd'));

    var certs = {
      'api.cert.pem': 'd429c4f9a62fd48caa84a35fc41838241460ec26',
      'ca.cert.pem': 'dc7098b831589a958167f433fa30dc2c83e0ca81',
      'pki/first_last.cert.pem': 'f9767156871e46e4a0f9edab09ef02cfc142ea98',
      'server.cert.pem': '97d2a2acb7dbfd8f0b71115612a5e93e7eabb8d2',
    };

    for (var cert in certs.entries) {
      var fp = fingerprint(
        File('$taskddata/${cert.key}').readAsStringSync(),
      );
      var certtoolFingerprint = Platform.environment['CI'] == 'true'
          ? cert.value
          : ((await Process.run(
              certtool,
              [
                '--fingerprint',
                '--infile',
                cert.key,
              ],
              workingDirectory: taskddata,
            ))
                  .stdout as String)
              .trim();
      expect(fp, certtoolFingerprint);
    }
  });

  test('test ssl.com example certs', () async {
    // compare:
    //
    // ```
    // % gnutls-certtool --fingerprint --infile test-ev-rsa-ssl-com.pem
    // 85e06e10dbe34b98ba7cd124935148409c16ad6d
    //
    // % gnutls-certtool --fingerprint --infile test-ev-rsa-ssl-com-chain.pem
    // too many certificates (3).import error: The given memory buffer is too short to hold parameters.
    //
    // % openssl x509 -in test-ev-rsa-ssl-com-chain.pem -noout -fingerprint
    // SHA1 Fingerprint=85:E0:6E:10:DB:E3:4B:98:BA:7C:D1:24:93:51:48:40:9C:16:AD:6D
    // ```
    var certtoolFingerprint = Platform.environment['CI'] == 'true'
        ? '85e06e10dbe34b98ba7cd124935148409c16ad6d'
        : ((await Process.run(
            certtool,
            [
              '--fingerprint',
              '--infile',
              'test-ev-rsa-ssl-com.pem',
            ],
            workingDirectory: 'test/fingerprint',
          ))
                .stdout as String)
            .trim();
    var certs = [
      'test-ev-rsa-ssl-com-chain.pem',
      'test-ev-rsa-ssl-com.pem',
    ];
    for (var cert in certs) {
      var fp = fingerprint(
        File('./test/fingerprint/$cert').readAsStringSync(),
      );
      expect(fp, certtoolFingerprint);
    }
  });
}
