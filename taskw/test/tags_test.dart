import 'package:test/test.dart';

import 'package:uuid/uuid.dart';

import 'package:taskj/json.dart';

import 'package:taskw/taskw.dart';

void main() {
  test('Test tags', () {
    var now = DateTime.now().toUtc();
    var tasks = [
      for (var tags in ['a,b', 'a,c', null])
        Task.fromJson({
          'status': 'pending',
          'uuid': const Uuid().v1(),
          'entry': '$now',
          'description': 'foo',
          'tags': tags?.split(','),
        }),
    ];

    expect(tagFrequencies(tasks), {'a': 2, 'b': 1, 'c': 1});
    expect(tagSet(tasks), {'a', 'b', 'c'});
    expect(tagsLastModified(tasks), {
      'a': now,
      'b': now,
      'c': now,
    });
  });
  test('Test modified tags', () {
    var now1 = DateTime.now().toUtc();
    var now2 = DateTime.now().toUtc();
    var tasks = [
      for (var now in [now1, now2])
        Task.fromJson({
          'status': 'pending',
          'uuid': const Uuid().v1(),
          'entry': '$now',
          'description': 'foo',
          'tags': ['a'],
        }),
    ];
    expect(tagsLastModified(tasks), {'a': now2});
  });
}
