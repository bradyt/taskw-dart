// ignore_for_file: always_put_control_body_on_new_line

import 'package:taskc/taskc.dart';

import 'package:taskw/taskw.dart';

class Modify {
  Modify({Storage storage, String uuid})
      : _storage = storage,
        _uuid = uuid {
    _draft = storage.getTask(_uuid);
    _saved = storage.getTask(_uuid);
  }

  final Storage _storage;
  final String _uuid;
  Task _draft;
  Task _saved;

  Task get draft => _draft;

  Map get changes {
    var result = {};
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
    if (_draft.priority != _saved.priority) {
      result['priority'] = {
        'old': _saved.priority,
        'new': _draft.priority,
      };
    }
    if (!_listEquals(_draft.tags, _saved.tags)) {
      result['tags'] = {
        'old': _saved.tags,
        'new': _draft.tags,
      };
    }
    return result;
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

  void setDue(DateTime due) {
    _draft = _draft.copyWith(due: () => due);
  }

  void setPriority(String priority) {
    _draft = _draft.copyWith(priority: () => priority);
  }

  void setTags(List<String> tags) {
    _draft = _draft.copyWith(tags: () => tags);
  }

  void save({DateTime Function() modified}) {
    _storage.mergeTask(
      _draft.copyWith(modified: modified),
    );
    _saved = _storage.getTask(_uuid);
    _draft = _storage.getTask(_uuid);
  }

  // copied from 'package:flutter/foundation.dart'
  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    if (identical(a, b)) return true;
    for (var index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }
}
