import 'package:test/test.dart';

import 'package:taskw/taskw.dart';

void main() {
  group('Test age function;', () {
    test('age of 42 minute old timestamp', () {
      expect(age(DateTime.now().subtract(const Duration(minutes: 42))), '42m');
    });
  });
}
