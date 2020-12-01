import 'dart:io';
import 'dart:typed_data';

import 'package:meta/meta.dart';

typedef Handler = bool Function(X509Certificate);

class Connection {
  Connection({
    @required this.address,
    @required this.port,
    @required this.context,
    this.onBadCertificate,
  });

  final String address;
  final int port;
  final SecurityContext context;
  final Handler onBadCertificate;

  Future<Uint8List> send(Uint8List bytes) async {
    Uint8List response;

    var socket = await SecureSocket.connect(
      address,
      port,
      context: context,
      onBadCertificate: onBadCertificate,
    );

    socket.add(bytes);

    response = await socket.first;

    await socket.close();

    return response;
  }
}
