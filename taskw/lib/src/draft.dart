import 'package:taskj/json.dart';

import 'package:taskw/taskw.dart';

class Draft {
  Draft(
    Task original,
  )   : _original = original,
        _draft = original.rebuild((b) => b);

  final Task _original;
  Task _draft;

  Task get original => _original;
  Task get draft => _draft;

  // ignore: avoid_annotating_with_dynamic
  void set(String key, dynamic value) {
    _draft = patch(_draft, {
      key: value,
      if (key == 'status') ...{
        'start': (value == 'completed') ? null : _original.start,
        'end': (value == 'pending') ? null : DateTime.now().toUtc(),
      },
    });
  }
}
