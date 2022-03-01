import 'package:built_collection/built_collection.dart';
import 'package:collection/collection.dart';

import 'package:taskj/json.dart';

class Modify {
  Modify({
    required Task Function(String) getTask,
    required void Function(Task) mergeTask,
    required String uuid,
  })  : _getTask = getTask,
        _mergeTask = mergeTask,
        _uuid = uuid {
    _draft = _getTask(_uuid);
    _saved = _getTask(_uuid);
  }

  final Task Function(String) _getTask;
  final void Function(Task) _mergeTask;
  final String _uuid;
  late Task _draft;
  late Task _saved;

  Task get draft => _draft;
  int get id => _saved.id!;

  Map<dynamic, Map> get changes {
    var result = <dynamic, Map>{};
    var savedJson = _saved.toJson();
    var draftJson = _draft.toJson();

    for (var entry in {
      for (var key in [
        'description',
        'status',
        'start',
        'end',
        'due',
        'wait',
        'until',
        'priority',
        'project',
        'tags',
        'annotations',
      ])
        key: (value) {
          if (value != null &&
              ['start', 'end', 'due', 'wait', 'until'].contains(key)) {
            return DateTime.parse(value).toLocal();
          } else if (key == 'annotations') {
            return (value as List?)?.length ?? 0;
          }
          return value;
        },
    }.entries) {
      var key = entry.key;
      var savedValue = savedJson[key];
      var draftValue = draftJson[key];

      if (draftValue != savedValue &&
          !(key == 'tags' &&
              const ListEquality().equals(draftValue, savedValue)) &&
          !(key == 'annotations' &&
              const DeepCollectionEquality().equals(draftValue, savedValue))) {
        result[key] = {
          'old': entry.value(savedValue),
          'new': entry.value(draftValue),
        };
      }
    }
    return result;
  }

  void setDescription(String description) {
    _draft = _draft.rebuild((b) => b..description = description);
  }

  void setStatus(String status) {
    if (status == 'pending') {
      _draft = _draft.rebuild(
        (b) => b
          ..status = status
          ..end = null,
      );
    } else {
      var now = DateTime.now().toUtc();
      _draft = _draft.rebuild(
        (b) => b
          ..status = status
          ..end = now,
      );
    }
    if (status == 'completed') {
      _draft = _draft.rebuild((b) => b..start = null);
    }
  }

  void setStart(DateTime? start) {
    _draft = _draft.rebuild((b) => b..start = start);
  }

  void setDue(DateTime? due) {
    _draft = _draft.rebuild((b) => b..due = due);
  }

  void setWait(DateTime? wait) {
    _draft = _draft.rebuild(
      (b) => b
        ..status = 'waiting'
        ..wait = wait,
    );
  }

  void setUntil(DateTime? until) {
    _draft = _draft.rebuild((b) => b..until = until);
  }

  void setPriority(String? priority) {
    _draft = _draft.rebuild((b) => b..priority = priority);
  }

  void setProject(String? project) {
    _draft = _draft.rebuild((b) => b..project = project);
  }

  void setTags(ListBuilder<String>? tags) {
    _draft = _draft.rebuild((b) => b..tags = tags);
  }

  void setAnnotations(ListBuilder<Annotation>? annotations) {
    _draft = _draft.rebuild((b) => b..annotations = annotations);
  }

  void save({required DateTime Function() modified}) {
    _mergeTask(
      _draft = _draft.rebuild((b) => b..modified = modified()),
    );
    _saved = _getTask(_uuid);
    _draft = _getTask(_uuid);
  }
}
