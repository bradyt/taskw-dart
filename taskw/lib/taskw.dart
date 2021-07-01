/// This library currently serves two purposes:
///
/// 1. Acting as a small wrapper around the [taskc] library, to implement a
/// notion of [Storage] of tasks consistent with a method to synchronize tasks
/// with a [Taskserver](https://github.com/GothenburgBitFactory/taskserver).
/// 2. Drawing non-Flutter-specific code out of the Flutter `task` app, so for
/// example we might have a focussed effort of unit tests here.

library taskw;

// import 'package:taskw/taskc.dart';

export 'src/bad_certificate_exception.dart';
export 'src/comparator.dart';
export 'src/datetime_differences.dart';
export 'src/modify.dart';
export 'src/profiles.dart';
export 'src/storage.dart';
export 'src/task_copy_with.dart';
export 'src/taskserver_configuration_exception.dart';
export 'src/urgency.dart';
