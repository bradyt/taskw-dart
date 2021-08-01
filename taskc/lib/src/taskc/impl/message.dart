import 'package:taskc/taskc.dart';
import 'package:taskc/taskc_impl.dart';

Future<Response> message({
  required Connection connection,
  required Credentials credentials,
  required String type,
  String? payload,
}) async {
  var message = '''
type: $type
org: ${credentials.org}
user: ${credentials.user}
key: ${credentials.key}
protocol: v1

$payload''';
  var response =
      await send(connection: connection, bytes: Codec.encode(message));
  if (response.isEmpty) {
    throw EmptyResponseException();
  }
  return Response.fromString(Codec.decode(response));
}

class EmptyResponseException implements Exception {
  @override
  String toString() => 'The server returned an empty response. '
      'Please review the server logs or contact administrator.';
}
