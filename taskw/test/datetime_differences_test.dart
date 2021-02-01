import 'dart:math';

import 'package:test/test.dart';

import 'package:taskw/taskw.dart';

void main() {
  group('Test age function;', () {
    test('age of 42 minute old timestamp', () {
      expect(age(DateTime.now().subtract(const Duration(minutes: 42))), '42m');
    });
  });
  group('Test difference function;', () {
    test('positive values', () {
      expect(difference(const Duration(minutes: 42)), '42m');
    });
    test('negative values', () {
      expect(difference(const Duration(minutes: -42)), '-42m');
    });
  });
  group('Test when function;', () {
    test('how long until a due date?', () {
      expect(when(DateTime.now().add(const Duration(minutes: 42))), '41m');
    });
    test('what if the due date passed?', () {
      expect(
          when(DateTime.now().subtract(const Duration(minutes: 42))), '-42m');
    });
  });
  group('Test other time intervals;', () {
    test('fractional number of years', () {
      expect(difference(Duration(days: (365 * pi).round())),
          '3.1424657534246574y');
    });
    test('integer number of years', () {
      expect(difference(const Duration(days: 366)), '1.0027397260273974y');
    });
    test('90 days', () {
      expect(difference(const Duration(days: 90)), '12w');
    });
  });
}
