import 'package:taskc/src/payload.dart';

class Response {
  Response({this.header, this.payload});

  final Map header;
  final String payload;

  factory Response.fromString(String string) {
    var firstPart = string.split('\n\n').first;
    var lastPart = string.split('\n\n').sublist(1).join('\n\n');
    var header = {
      for (var pair in firstPart.split('\n').map((line) => line.split(': ')))
        pair.first: pair.sublist(1).join(': '),
    };
    var payload = lastPart.trim();
    Payload.fromString(payload);
    return Response(
      header: header,
      payload: payload,
    );
  }
}
