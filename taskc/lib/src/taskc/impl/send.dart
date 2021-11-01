import 'dart:io';
import 'dart:typed_data';

Future<Uint8List> send({
  required SecureSocket socket,
  required Uint8List bytes,
}) async {
  Uint8List response;

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
