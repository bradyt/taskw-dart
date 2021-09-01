import 'package:built_collection/built_collection.dart';

import 'package:taskc/json.dart';

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

  Map get changes {
    var result = {};
    if (_draft.description != _saved.description) {
      result['description'] = {
        'old': _saved.description,
        'new': _draft.description,
      };
    }
    if (_draft.status != _saved.status) {
      result['status'] = {
        'old': _saved.status,
        'new': _draft.status,
      };
    }
    if (_draft.end != _saved.end) {
      result['end'] = {
        'old': _saved.end,
        'new': _draft.end,
      };
    }
    if (_draft.due != _saved.due) {
      result['due'] = {
        'old': _saved.due,
        'new': _draft.due,
      };
    }
    if (_draft.wait != _saved.wait) {
      result['wait'] = {
        'old': _saved.wait,
        'new': _draft.wait,
      };
    }
    if (_draft.until != _saved.until) {
      result['until'] = {
        'old': _saved.until,
        'new': _draft.until,
      };
    }
    if (_draft.priority != _saved.priority) {
      result['priority'] = {
        'old': _saved.priority,
        'new': _draft.priority,
      };
    }
    if (_draft.project != _saved.project) {
      result['project'] = {
        'old': _saved.project,
        'new': _draft.project,
      };
    }
    if (_draft.tags != _saved.tags) {
      result['tags'] = {
        'old': _saved.tags,
        'new': _draft.tags,
      };
    }
    if (_draft.annotations != _saved.annotations) {
      result['annotations'] = {
        'old': _saved.annotations?.length ?? 0,
        'new': _draft.annotations?.length ?? 0,
      };
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
