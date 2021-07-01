import 'dart:math';

import 'package:test/test.dart';

import 'package:taskw/taskw.dart';

void main() {
  group('Test age function;', () {
    test('age of 42 minute old timestamp', () {
      expect(
          age(DateTime.now().subtract(const Duration(minutes: 42))), '42min');
    });
  });
  group('Test difference function;', () {
    test('positive values', () {
      expect(difference(const Duration(minutes: 42)), '42min');
    });
    test('negative values', () {
      expect(difference(const Duration(minutes: -42)), '-42min');
    });
  });
  group('Test when function;', () {
    test('how long until a due date?', () {
      expect(when(DateTime.now().add(const Duration(minutes: 42))), '41min');
    });
    test('what if the due date passed?', () {
      expect(
          when(DateTime.now().subtract(const Duration(minutes: 42))), '-42min');
    });
  });
  group('Test other time intervals;', () {
    test('fractional number of years', () {
      expect(difference(Duration(days: (365 * pi).round())), '3.1y');
    });
    test('check rounding up of fractional number of years', () {
      expect(difference(Duration(days: (365 * 2 * pi).round())), '6.3y');
    });
    test('integer number of years', () {
      expect(difference(const Duration(days: 366)), '1y');
    });
    test('90 days', () {
      expect(difference(const Duration(days: 90)), '3mo');
    });
    test('42 seconds', () {
      expect(difference(const Duration(seconds: 42)), '42s');
    });
    test('10 hours', () {
      expect(difference(const Duration(hours: 10)), '10h');
    });
    test('3 days', () {
      expect(difference(const Duration(days: 3)), '3d');
    });
    test('3 weeks', () {
      expect(difference(const Duration(days: 21)), '3w');
    });
  });
}
