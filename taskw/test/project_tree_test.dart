import 'package:test/test.dart';

import 'package:taskw/taskw.dart';

Map<String, int> projects = {
  'a': 1,
  'b.c': 2,
  'b.c.d': 4,
  'e.f': 8,
  'e.g': 16,
  'h.i.j': 32,
};

void main() {
  test('Test sparse decorated tree implementation', () {
    expect(
      sparseDecoratedProjectTree(projects)
          .map((project, nodeData) => MapEntry(project, nodeData.toMap())),
      <String, Map>{
        'a': {'parent': null, 'children': [], 'tasks': 1, 'subtasks': 1},
        'b.c': {
          'parent': null,
          'children': ['b.c.d'],
          'tasks': 2,
          'subtasks': 6
        },
        'b.c.d': {'parent': 'b.c', 'children': [], 'tasks': 4, 'subtasks': 4},
        'e': {
          'parent': null,
          'children': ['e.f', 'e.g'],
          'tasks': 0,
          'subtasks': 24
        },
        'e.f': {'parent': 'e', 'children': [], 'tasks': 8, 'subtasks': 8},
        'e.g': {'parent': 'e', 'children': [], 'tasks': 16, 'subtasks': 16},
        'h.i.j': {'parent': null, 'children': [], 'tasks': 32, 'subtasks': 32}
      },
    );
  });
}
