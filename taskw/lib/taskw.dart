/// This library currently serves two purposes:
///
/// 1. Acting as a small wrapper around the [taskc] library, to implement a
/// notion of [Storage] of tasks consistent with a method to synchronize tasks
/// with a [Taskserver](https://github.com/GothenburgBitFactory/taskserver).
/// 2. Drawing non-Flutter-specific code out of the Flutter `task` app, so for
/// example we might have a focussed effort of unit tests here.

library taskw;

// import 'package:taskw/taskc.dart';

export 'src/taskw/bad_certificate_exception.dart';
export 'src/taskw/comparator.dart';
export 'src/taskw/datetime_differences.dart';
export 'src/taskw/modify.dart';
export 'src/taskw/profiles.dart';
export 'src/taskw/storage.dart';
export 'src/taskw/task_copy_with.dart';
export 'src/taskw/taskserver_configuration_exception.dart';
export 'src/taskw/urgency.dart';
