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
      'ca.cert.pem': '5af6be490c85794f5ea6789ac9348107224ea9ab',
      'client.cert.pem': '925132d002e0633891e0911bf4588255cc6a035c',
      'server.cert.pem': 'c9229d1b818f063fdf510c6db665193eb18ad9e0',
      'pki/first_last.cert.pem': '194ef6dd023a5aa7ccdc23ec709aedd1ae7af16b',
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
