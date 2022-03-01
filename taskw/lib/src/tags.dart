import 'dart:math';

import 'package:taskj/json.dart';

Set<String> tagSet(Iterable<Task> tasks) {
  return tasks.where((task) => task.tags != null).fold(
      <String>{}, (aggregate, task) => aggregate..addAll(task.tags!.toList()));
}

Map<String, int> tagFrequencies(Iterable<Task> tasks) {
  var frequency = <String, int>{};
  for (var task in tasks) {
    for (var tag in task.tags?.asList() ?? []) {
      if (frequency.containsKey(tag)) {
        frequency[tag] = (frequency[tag] ?? 0) + 1;
      } else {
        frequency[tag] = 1;
      }
    }
  }
  return frequency;
}

Map<String, DateTime> tagsLastModified(Iterable<Task> tasks) {
  var modified = <String, DateTime>{};
  for (var task in tasks) {
    var _modified = task.modified ?? task.start ?? task.entry;
    for (var tag in task.tags?.asList() ?? []) {
      if (modified.containsKey(tag)) {
        modified[tag] = DateTime.fromMicrosecondsSinceEpoch(
          max(
            _modified.microsecondsSinceEpoch,
            modified[tag]?.microsecondsSinceEpoch ??
                DateTime.now().toUtc().microsecondsSinceEpoch,
          ),
          isUtc: true,
        );
      } else {
        modified[tag] = _modified;
      }
    }
  }
  return modified;
}
