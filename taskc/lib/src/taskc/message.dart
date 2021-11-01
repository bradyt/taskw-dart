// ignore_for_file: always_put_required_named_parameters_first

import 'dart:io';

import 'package:taskc/taskc.dart';
import 'package:taskc/taskc_impl.dart';
import 'package:taskc/taskrc.dart';

Future<Response> statistics({
  required SecureSocket socket,
  required Credentials? credentials,
  required String client,
}) =>
    message(
      socket: socket,
      credentials: credentials,
      client: client,
      type: 'statistics',
    );

Future<Response> synchronize({
  required SecureSocket socket,
  Credentials? credentials,
  required String client,
  required String payload,
}) =>
    message(
      socket: socket,
      credentials: credentials,
      client: client,
      type: 'sync',
      payload: payload,
    );
