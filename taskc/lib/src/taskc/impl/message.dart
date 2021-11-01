// ignore_for_file: always_put_required_named_parameters_first

import 'dart:convert';
import 'dart:io';

import 'package:taskc/taskc.dart';
import 'package:taskc/taskc_impl.dart';
import 'package:taskc/taskrc.dart';

Future<Response> message({
  required Server? server,
  required SecurityContext context,
  bool Function(X509Certificate)? onBadCertificate,
  required Credentials? credentials,
  required String client,
  required String type,
  String? payload,
}) async {
  if (server == null) {
    throw TaskrcException(
      'Server cannot be null.',
    );
  }
  if (credentials == null) {
    throw TaskrcException(
      'Credentials cannot be null.',
    );
  }
  var message = '''
client: $client
type: $type
org: ${credentials.org}
user: ${credentials.user}
key: ${credentials.key}
protocol: v1

$payload''';
  var responseBytes = await send(
    server: server,
    context: context,
    onBadCertificate: onBadCertificate,
    bytes: Codec.encode(message),
  );
  if (responseBytes.isEmpty) {
    throw EmptyResponseException();
  }
  var response = Response.fromString(Codec.decode(responseBytes));
  if ([
    '200',
    '201',
    '202',
  ].contains(response.header['code'])) {
    return response;
  } else {
    throw TaskserverResponseException(response.header);
  }
}

class TaskserverResponseException implements Exception {
  TaskserverResponseException(this.header);

  final Map header;

  @override
  String toString() =>
      'response.header = ${const JsonEncoder.withIndent('  ').convert(header)}';
}

class EmptyResponseException implements Exception {
  @override
  String toString() => 'The server returned an empty response. '
      'Please review the server logs or contact administrator.';
}
