/// This library is a small wrapper around the [Socket] class, and provides an
/// API to send messages to a
/// [Taskserver](https://github.com/GothenburgBitFactory/taskserver).
///
/// Inspired by [taskd-client-py](https://github.com/jrabbit/taskd-client-py/).
///
/// Some of the naming in this library was loosely inspired by the taskserver
/// design documents, which can be found at
/// <https://taskwarrior.org/docs/design/index.html>.

//
//  # Tests
//
//  Run `make` or the following:
//
//  ```sh
//  dart pub run test
//  ```
//
//  But you will need a taskd server to pass all tests. There are several
//  ways to do this.
//
//  ## macOS and GNU/Linux
//
//  ```sh
//  cd fixture
//  make install
//  make setup
//  make
//  ```
//
//  ## Windows
//
//  Open Debian in WSL in Terminal.exe.
//
//  Debian is recommended as their package manager provides taskd.
//
//  ```sh
//  cd fixture
//  make install
//  make setup
//  make
//  ```
//
//  ## Docker
//
//  ```sh
//  cd docker
//  make
//  ```

library taskc;

import 'dart:io';

export 'src/taskc/connection.dart';
export 'src/taskc/message.dart';
export 'src/taskc/payload.dart';
export 'src/taskc/response.dart';
