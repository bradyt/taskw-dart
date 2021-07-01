import 'dart:math';
import 'dart:typed_data';

import 'package:test/test.dart';

import 'package:taskw/taskc_impl.dart';

void main() {
  group('Test string encoding/decoding', () {
    test('test string \'ABC\'', () async {
      var string = 'ABC';
      var bytes = Uint8List.fromList([0, 0, 0, 7, 65, 66, 67]);

      expect(Codec.decode(bytes), string);
      expect(Codec.encode(string), bytes);
    });

    test('test long messages', () async {
      var string = 'A' * 1000;

      expect(Codec.decode(Codec.encode(string)), string);
    });

    test('test integer representation', () async {
      for (var i = 0; i < 10; i++) {
        expect(Codec.fold(Codec.unfold(pow(10, i) as int)), pow(10, i));
      }
    });
  });
}
