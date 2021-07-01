import 'dart:io';

class Connection {
  Connection({
    required this.address,
    required this.port,
    required this.context,
    this.onBadCertificate,
  });

  final String address;
  final int port;

  final SecurityContext context;

  final bool Function(X509Certificate)? onBadCertificate;
}
