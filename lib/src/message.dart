import 'package:taskc/taskc.dart';

Future<Response> statistics({
  required Connection connection,
  required Credentials credentials,
}) =>
    message(
      connection: connection,
      credentials: credentials,
      type: 'statistics',
    );

Future<Response> synchronize({
  required Connection connection,
  required Credentials credentials,
  required String payload,
}) =>
    message(
      connection: connection,
      credentials: credentials,
      type: 'sync',
      payload: payload,
    );

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
  var response = await connection.send(Codec.encode(message));
  return Response.fromString(Codec.decode(response));
}
