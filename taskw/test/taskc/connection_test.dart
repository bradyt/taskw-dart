import 'dart:io';

import 'package:pedantic/pedantic.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

import 'package:taskw/taskd.dart';

void main() {
  var address = 'localhost';
  var port = 53589;
  var certificate = '../fixture/var/taskd/pki/first_last.cert.pem';
  var key = '../fixture/var/taskd/pki/first_last.key.pem';
  var ca = '../fixture/var/taskd/pki/ca.cert.pem';

  var taskd = Taskd(normalize(absolute('../fixture/var/taskd')));
  // var taskwarrior = Taskwarrior(absolute('../fixture'));

  setUpAll(() async {
    await taskd.initialize();
    await taskd.setAddressAndPort(
      address: 'localhost',
      port: 53589,
    );
    unawaited(taskd.start());
    await Future.delayed(const Duration(seconds: 1));
  });

  tearDownAll(() async {
    await taskd.kill();
  });

  test('test fails', () async {
    // var exitCode = await taskwarrior.synchronize();
    // expect(exitCode, 0);

    var socket = await Socket.connect(
      address,
      port,
    );

    var madeIt = false;

    try {
      await SecureSocket.secure(
        socket,
        context: SecurityContext(withTrustedRoots: true)
          ..useCertificateChain(certificate)
          ..usePrivateKey(key)
          ..setTrustedCertificates(ca),
      ).then((socket) => socket.close());
      madeIt = true;
    } on HandshakeException catch (_) {}

    expect(madeIt, !Platform.isMacOS);
  });
  test('test succeeds', () async {
    var socket = await Socket.connect(
      address,
      port,
    );
    var secureSocket = await SecureSocket.secure(
      socket,
      context: SecurityContext(withTrustedRoots: true)
        ..useCertificateChain(certificate)
        ..usePrivateKey(key)
        ..setTrustedCertificates(ca),
      onBadCertificate: (_) => true,
    );

    await secureSocket.close();

    expect(secureSocket.done, completion(isA<SecureSocket>()));
    await taskd.kill();
  });
}
