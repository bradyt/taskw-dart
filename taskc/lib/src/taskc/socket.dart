import 'dart:io';

import 'package:taskc/taskrc.dart';

Future<SecureSocket> getSocket({
  Server? server,
  // ignore: always_put_required_named_parameters_first
  required SecurityContext context,
  bool Function(X509Certificate)? onBadCertificate,
}) async {
  if (server == null) {
    throw Exception(
      'Server cannot be null.',
    );
  }

  var socket = await Socket.connect(
    server.address,
    server.port,
  );

  var secureSocket = await SecureSocket.secure(
    socket,
    context: context,
    onBadCertificate: onBadCertificate,
  );

  return secureSocket;
}
