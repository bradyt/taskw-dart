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
  return Response.fromString(Codec.decode(response));
}
