// ignore_for_file: always_put_required_named_parameters_first

import 'dart:io';

import 'package:taskc/taskc.dart';
import 'package:taskc/taskc_impl.dart';
import 'package:taskc/taskrc.dart';

Future<Response> statistics({
  required Server? server,
  required SecurityContext context,
  bool Function(X509Certificate)? onBadCertificate,
  required Credentials? credentials,
  required String client,
}) =>
    message(
      server: server,
      context: context,
      onBadCertificate: onBadCertificate,
      credentials: credentials,
      client: client,
      type: 'statistics',
    );

Future<Response> synchronize({
  Server? server,
  required SecurityContext context,
  bool Function(X509Certificate)? onBadCertificate,
  Credentials? credentials,
  required String client,
  required String payload,
}) =>
    message(
      server: server,
      context: context,
      onBadCertificate: onBadCertificate,
      credentials: credentials,
      client: client,
      type: 'sync',
      payload: payload,
    );
