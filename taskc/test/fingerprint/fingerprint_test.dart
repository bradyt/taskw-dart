// ignore_for_file: lines_longer_than_80_chars

import 'dart:io';

import 'package:path/path.dart';
import 'package:test/test.dart';

import 'package:taskc/fingerprint.dart';

void main() {
  test(r'test $TASKDDATA/pki certs', () async {
    var taskddata = normalize(absolute('../fixture/var/taskd'));

    var certs = [
      'ca.cert.pem',
      'client.cert.pem',
      'server.cert.pem',
      'pki/first_last.cert.pem',
    ];

    for (var cert in certs) {
      var fp = fingerprint(
        File('$taskddata/$cert').readAsStringSync(),
      );
      var certtoolFingerprint = ((await Process.run(
        'gnutls-certtool',
        [
          '--fingerprint',
          '--infile',
          cert,
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
    var certtoolFingerprint = ((await Process.run(
      'gnutls-certtool',
      [
        '--fingerprint',
        '--infile',
        'test-ev-rsa-ssl-com.pem',
      ],
      workingDirectory: 'test/fingerprints',
    ))
            .stdout as String)
        .trim();
    var certs = [
      'test-ev-rsa-ssl-com-chain.pem',
      'test-ev-rsa-ssl-com.pem',
    ];
    for (var cert in certs) {
      var fp = fingerprint(
        File('./test/fingerprints/$cert').readAsStringSync(),
      );
      expect(fp, certtoolFingerprint);
    }
  });
}
