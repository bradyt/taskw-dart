import 'package:collection/collection.dart';

import 'package:taskj/json.dart';

import 'package:taskw/taskw.dart';

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

  // ignore: avoid_annotating_with_dynamic
  void set(String key, dynamic value) {
    _draft = patch(_draft, {
      key: value,
      if (key == 'status') ...{
        'start': (value == 'completed') ? null : _saved.start,
        'end': (value == 'pending') ? null : DateTime.now().toUtc(),
      },
    });
  }

  void save({required DateTime Function() modified}) {
    _mergeTask(
      _draft = _draft.rebuild((b) => b..modified = modified()),
    );
    _saved = _getTask(_uuid);
    _draft = _getTask(_uuid);
  }
}
