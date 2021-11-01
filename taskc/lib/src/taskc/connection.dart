import 'dart:io';

import 'package:taskc/taskrc.dart';

class Connection {
  Connection({
    required this.server,
    required this.context,
    this.onBadCertificate,
  });

  final Server server;

  final SecurityContext context;

  final bool Function(X509Certificate)? onBadCertificate;
}
