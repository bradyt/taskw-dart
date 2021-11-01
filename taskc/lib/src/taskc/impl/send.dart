import 'dart:io';
import 'dart:typed_data';

import 'package:taskc/taskrc.dart';

Future<Uint8List> send({
  required Server server,
  required SecurityContext context,
  bool Function(X509Certificate)? onBadCertificate,
  // ignore: always_put_required_named_parameters_first
  required Uint8List bytes,
}) async {
  Uint8List response;

  var socket = await Socket.connect(
    server.address,
    server.port,
  );

  var secureSocket = await SecureSocket.secure(
    socket,
    context: context,
    onBadCertificate: onBadCertificate,
  );

  secureSocket.add(bytes);

  response = Uint8List.fromList(
    (await secureSocket.toList())
        .expand(
          (x) => x,
        )
        .toList(),
  );

  await secureSocket.close();

  return response;
}
