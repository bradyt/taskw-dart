import 'package:collection/collection.dart';

import 'package:taskc/taskc.dart';

import 'package:taskw/taskw.dart';

class Modify {
  Modify({
    required Task Function(String) getTask,
    required void Function(Task) mergeTask,
    required String uuid,
  })   : _getTask = getTask,
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
    if (!(const ListEquality()).equals(_draft.tags, _saved.tags)) {
      result['tags'] = {
        'old': _saved.tags,
        'new': _draft.tags,
      };
    }
    return result;
  }

  void setDescription(String description) {
    _draft = _draft.copyWith(description: () => description);
  }

  void setStatus(String status) {
    if (status == 'pending') {
      _draft = _draft.copyWith(
        status: () => status,
        end: () => null,
      );
    } else {
      var now = DateTime.now().toUtc();
      _draft = _draft.copyWith(
        status: () => status,
        end: () => now,
      );
    }
  }

  void setDue(DateTime? due) {
    _draft = _draft.copyWith(due: () => due);
  }

  void setWait(DateTime? wait) {
    _draft = _draft.copyWith(status: () => 'waiting', wait: () => wait);
  }

  void setUntil(DateTime? until) {
    _draft = _draft.copyWith(until: () => until);
  }

  void setPriority(String? priority) {
    _draft = _draft.copyWith(priority: () => priority);
  }

  void setTags(List<String>? tags) {
    _draft = _draft.copyWith(tags: () => tags);
  }

  void save({required DateTime Function() modified}) {
    _mergeTask(
      _draft.copyWith(modified: modified),
    );
    _saved = _getTask(_uuid);
    _draft = _getTask(_uuid);
  }
}
