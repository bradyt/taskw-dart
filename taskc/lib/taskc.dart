/// This library is a small wrapper around the [Socket] class, and provides an
/// API to send messages to a
/// [Taskserver](https://github.com/GothenburgBitFactory/taskserver).
///
/// Inspired by [taskd-client-py](https://github.com/jrabbit/taskd-client-py/).
///
/// Some of the naming in this library was loosely inspired by the taskserver
/// design documents, which can be found at
/// <https://taskwarrior.org/docs/design/index.html>.

library taskc;

import 'dart:io';

export 'src/taskc/message.dart';
export 'src/taskc/payload.dart';
export 'src/taskc/response.dart';
