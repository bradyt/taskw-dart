import 'package:taskc/src/codec.dart';
import 'package:taskc/src/config.dart';
import 'package:taskc/src/connection.dart';
import 'package:taskc/src/response.dart';

Future<Response> statistics(Config config) async {
  var connection = Connection.fromConnectionData(config.connectionData);
  var auth = config.authData;
  var message = '''
type: statistics
org: ${auth.org}
user: ${auth.user}
key: ${auth.key}
protocol: v1

''';
  var response = await connection.send(Codec.encode(message));
  return Response.fromString(Codec.decode(response));
}
