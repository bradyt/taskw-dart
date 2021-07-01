import 'package:taskc/taskc.dart';
import 'package:taskc/taskc_impl.dart';

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
