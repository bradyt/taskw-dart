import 'dart:io';
import 'dart:typed_data';

import 'package:taskc/taskc.dart';

Future<Uint8List> send(
    {required Connection connection, required Uint8List bytes}) async {
  Uint8List response;

  var socket = await Socket.connect(
    connection.address,
    connection.port,
  );

  var secureSocket = await SecureSocket.secure(
    socket,
    context: connection.context,
    onBadCertificate: connection.onBadCertificate,
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
