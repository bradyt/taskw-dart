import 'package:taskc/taskc.dart';
import 'package:taskc/taskc_impl.dart';
import 'package:taskc/taskrc.dart';

Future<Response> statistics({
  required Connection connection,
  required Credentials credentials,
  required String client,
}) =>
    message(
      connection: connection,
      credentials: credentials,
      client: client,
      type: 'statistics',
    );

Future<Response> synchronize({
  required Connection connection,
  required Credentials credentials,
  required String client,
  required String payload,
}) =>
    message(
      connection: connection,
      credentials: credentials,
      client: client,
      type: 'sync',
      payload: payload,
    );
