import 'package:test/test.dart';

import 'package:uuid/uuid.dart';

import 'package:taskj/json.dart';

import 'package:taskw/taskw.dart';

void main() {
  test('Test sparse decorated tree implementation', () {
    var tasks = [
      for (var tags in ['a,b', 'a,c', null])
        Task.fromJson({
          'status': 'pending',
          'uuid': const Uuid().v1(),
          'entry': '${DateTime.now()}',
          'description': 'foo',
          'tags': tags?.split(','),
        }),
    ];

    expect(tagFrequencies(tasks), {'a': 2, 'b': 1, 'c': 1});
  });
}
