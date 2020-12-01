import 'dart:math';
import 'dart:convert';
import 'dart:typed_data';

class Codec {
  static int fold(Iterable<int> bytes) =>
      bytes.reduce((x, y) => x * pow(2, 8) + y);
  static Iterable<int> unfold(int n) => [
        for (var i in [3, 2, 1, 0]) (n ~/ pow(256, i)) % 256
      ];

  static String decode(Uint8List bytes) {
    assert(fold(bytes.take(4)) == bytes.length);
    return utf8.decode(bytes.sublist(4));
  }

  static Uint8List encode(String string) {
    var utf8Encoded = utf8.encode(string);
    var byteLength = utf8Encoded.length + 4;
    return Uint8List.fromList(
        unfold(byteLength).followedBy(utf8Encoded).toList());
  }
}
