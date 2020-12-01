import 'dart:io';
import 'dart:typed_data';

import 'package:taskc/src/config.dart';

class Connection {
  Connection({
    this.address,
    this.port,
    this.certificate,
    this.key,
    this.ca,
  });

  factory Connection.fromConnectionData(ConnectionData data) => Connection(
        address: data.address,
        port: data.port,
        certificate: data.certificate,
        key: data.key,
        ca: data.ca,
      );

  final String address;
  final int port;
  final String certificate;
  final String key;
  final String ca;

  Future<Uint8List> send(Uint8List bytes) async {
    var response;

    var context = SecurityContext()
      ..useCertificateChain(certificate)
      ..usePrivateKey(key)
      ..setTrustedCertificates(ca);

    var socket = await SecureSocket.connect(
      address,
      port,
      context: context,
      onBadCertificate: (_) => true,
    );

    await socket.add(bytes);

    response = await socket.first;

    await socket.close();

    return response;
  }
}
