import 'dart:math';

import 'package:taskw/json.dart';

import 'package:taskw/taskw.dart';

// ignore: prefer_expression_function_bodies
int Function(Task, Task) compareTasks(String column) {
  return (a, b) {
    int? result;
    switch (column) {
      case 'entry':
        result = a.entry.compareTo(b.entry);
        break;
      case 'due':
        if (a.due == null && b.due == null) {
          result = 0;
        } else if (a.due == null) {
          return 1;
        } else if (b.due == null) {
          return -1;
        } else {
          result = a.due!.compareTo(b.due!);
        }
        break;
      case 'priority':
        var compare = {'H': 2, 'M': 1, 'L': 0};
        result =
            (compare[a.priority] ?? -1).compareTo(compare[b.priority] ?? -1);
        break;
      case 'tags':
        for (var i = 0;
            i < min(a.tags?.length ?? 0, b.tags?.length ?? 0);
            i++) {
          if (result == null || result == 0) {
            result = a.tags![i].compareTo(b.tags![i]);
          }
        }
        if (result == null || result == 0) {
          result = (a.tags?.length ?? 0).compareTo(b.tags?.length ?? 0);
        }
        break;
      case 'urgency':
        result = -urgency(a).compareTo(urgency(b));
        break;
      default:
    }
    return result!;
  };
}
