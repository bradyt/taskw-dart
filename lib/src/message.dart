import 'package:taskc/src/codec.dart';
import 'package:taskc/src/config.dart';
import 'package:taskc/src/connection.dart';
import 'package:taskc/src/payload.dart';
import 'package:taskc/src/response.dart';

Future<Response> statistics(Config config) =>
    message(config: config, type: 'statistics');

Future<Response> synchronize(Config config, Payload payload) =>
    message(config: config, type: 'sync', payload: payload);

Future<Response> message({Config config, String type, Payload payload}) async {
  var connection = Connection.fromConnectionData(config.connectionData);
  var auth = config.authData;
  var message = '''
type: $type
org: ${auth.org}
user: ${auth.user}
key: ${auth.key}
protocol: v1

${payload ?? ''}''';
  var response = await connection.send(Codec.encode(message));
  return Response.fromString(Codec.decode(response));
}
