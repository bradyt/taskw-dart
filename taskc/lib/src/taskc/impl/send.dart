import 'dart:io';
import 'dart:typed_data';

import 'package:taskc/taskc.dart';

Future<Uint8List> send(
    {required Connection connection, required Uint8List bytes}) async {
  Uint8List response;

  var socket = await SecureSocket.connect(
    connection.address,
    connection.port,
    context: connection.context,
    onBadCertificate: connection.onBadCertificate,
  );

  socket.add(bytes);

  response = Uint8List.fromList(
    (await socket.toList())
        .expand(
          (x) => x,
        )
        .toList(),
  );

  await socket.close();

  return response;
}
