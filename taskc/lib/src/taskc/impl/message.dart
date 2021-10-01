import 'dart:convert';

import 'package:taskc/taskc.dart';
import 'package:taskc/taskc_impl.dart';

Future<Response> message({
  required Connection connection,
  required Credentials credentials,
  required String client,
  required String type,
  String? payload,
}) async {
  var message = '''
client: $client
type: $type
org: ${credentials.org}
user: ${credentials.user}
key: ${credentials.key}
protocol: v1

$payload''';
  var responseBytes =
      await send(connection: connection, bytes: Codec.encode(message));
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
