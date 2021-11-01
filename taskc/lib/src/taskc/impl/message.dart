// ignore_for_file: always_put_required_named_parameters_first

import 'dart:convert';

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
