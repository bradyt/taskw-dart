import 'package:taskw/taskc_impl.dart';

import 'package:taskw/taskc.dart';

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
