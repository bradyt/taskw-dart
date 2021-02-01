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
    return result;
  }

  void setDue(DateTime due) {
    _draft = _draft.copyWith(due: () => due);
  }

  void setPriority(String priority) {
    _draft = _draft.copyWith(priority: () => priority);
  }

  void save({DateTime Function() modified}) {
    _storage.mergeTask(
      _draft.copyWith(modified: modified),
    );
    _saved = _storage.getTask(_uuid);
    _draft = _storage.getTask(_uuid);
  }
}
