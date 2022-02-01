import 'dart:io';

import 'package:test/test.dart';

import 'package:petitparser/petitparser.dart';
import 'package:quiver/iterables.dart';

Iterable filterParser(String filter) {
  return pattern('^()')
      .star()
      .flatten()
      .separatedBy(pattern('()'))
      .end()
      .parse(filter)
      .value
      .cast<String>()
      .map((it) => it.split(' '))
      .toList()
      .expand((x) => x)
      .where((x) => x.isNotEmpty)
      .toList();
}

void main() {
  var filters = File('test/filter_parser_test.txt')
      .readAsStringSync()
      .trim()
      .split('\n')
      .where((line) => !line.startsWith('#'))
      .map((line) => line.split(RegExp(' +')).sublist(1).join(' '));

  test('test filter parser with small example', () {
    expect(
      filterParser('x and (y or (z and w))'),
      ['x', 'and', '(', 'y', 'or', '(', 'z', 'and', 'w', ')', ')'],
    );
  });
  test('test filter parser with default reports', () {
    expect(
      filters.map(filterParser),
      [
        ['status:pending', 'and', '+ACTIVE'],
        ['status:pending', '-WAITING', '+BLOCKED'],
        ['status:pending', '-WAITING', '+BLOCKING'],
        ['status:completed'],
        ['status:pending', '-WAITING'],
        ['status:pending', '-WAITING'],
        ['status:pending', '-WAITING'],
        ['status:pending'],
        ['status:pending'],
        ['status:pending', '-WAITING', 'limit:page'],
        ['status:pending'],
        ['status:pending', 'and', '+OVERDUE'],
        ['+READY'],
        ['status:pending', 'and', '(', '+PARENT', 'or', '+CHILD', ')'],
        [
          '(',
          '+PENDING',
          'and',
          'start.after:now-4wks',
          ')',
          'or',
          '(',
          '+COMPLETED',
          'and',
          'end.after:now-4wks',
          ')'
        ],
        ['status:pending', '-WAITING', '-BLOCKED'],
        ['+WAITING'],
      ],
    );
  });
  test('make implicit operator explicit', () {
    expect(explicitAnd(['a', 'b']), ['a', 'and', 'b']);
    expect(explicitAnd(['a', 'b', 'c']), ['a', 'and', 'b', 'and', 'c']);
    expect(explicitAnd(['a', '(', 'b', 'c', ')']),
        ['a', 'and', '(', 'b', 'and', 'c', ')']);
  });
  test('test shunting yard algorithm with simple examples', () {
    expect(shuntingYard(['z']), ['z']);
    expect(shuntingYard(['z', 'and', 'w']), ['z', 'w', 'and']);
    expect(shuntingYard(['(', 'z', 'and', 'w', ')']), ['z', 'w', 'and']);
    expect(
      shuntingYard(
        ['x', 'and', '(', 'y', 'or', '(', 'z', 'and', 'w', ')', ')'],
      ),
      ['x', 'y', 'z', 'w', 'and', 'or', 'and'],
    );
    expect(
      shuntingYard(explicitAnd(['y', 'z', 'or', 'w'])),
      ['y', 'z', 'and', 'w', 'or'],
    );
  });
  test('test shunting yard algorithm with default reports', () {
    expect(
      filters.map((filter) => shuntingYard(explicitAnd(filterParser(filter)))),
      [
        ['status:pending', '+ACTIVE', 'and'],
        ['status:pending', '-WAITING', 'and', '+BLOCKED', 'and'],
        ['status:pending', '-WAITING', 'and', '+BLOCKING', 'and'],
        ['status:completed'],
        ['status:pending', '-WAITING', 'and'],
        ['status:pending', '-WAITING', 'and'],
        ['status:pending', '-WAITING', 'and'],
        ['status:pending'],
        ['status:pending'],
        ['status:pending', '-WAITING', 'and', 'limit:page', 'and'],
        ['status:pending'],
        ['status:pending', '+OVERDUE', 'and'],
        ['+READY'],
        ['status:pending', '+PARENT', '+CHILD', 'or', 'and'],
        [
          '+PENDING',
          'start.after:now-4wks',
          'and',
          '+COMPLETED',
          'end.after:now-4wks',
          'and',
          'or'
        ],
        ['status:pending', '-WAITING', 'and', '-BLOCKED', 'and'],
        ['+WAITING'],
      ],
    );
  });
}

Iterable explicitAnd(Iterable input) {
  bool implicitAnd(List pair) {
    if (pair.last == null) {
      return false;
    }
    if (pair.toSet().intersection(operators.keys.toSet()).isNotEmpty) {
      return false;
    }
    if (pair.first == '(' || pair.last == ')') {
      return false;
    }
    return true;
  }

  var zipped = zip([
    input,
    input.skip(1).cast<String?>().followedBy([null]),
  ]);

  return [
    for (var pair in zipped) [pair.first, if (implicitAnd(pair)) 'and']
  ].expand((x) => x);
}

Map operators = {
  'and': 1,
  'or': 0,
};

// https://wikipedia.org/wiki/Shunting-yard_algorithm
dynamic shuntingYard(Iterable filter) {
  var outputQueue = [];
  var operatorStack = [];

  for (var element in filter) {
    if (operators.keys.contains(element)) {
      while (operatorStack.isNotEmpty &&
          operatorStack.last != '(' &&
          (operators[operatorStack.last] as int) >= operators[element]) {
        outputQueue.add(operatorStack.removeLast());
      }
      operatorStack.add(element);
    } else if (element == '(') {
      operatorStack.add(element);
    } else if (element == ')') {
      while (operatorStack.last != '(') {
        outputQueue.add(operatorStack.removeLast());
      }
      operatorStack.removeLast();
    } else {
      outputQueue.add(element);
    }
  }

  operatorStack.forEach(outputQueue.add);

  return outputQueue;
}
