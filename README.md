# What is it?

`task` is a todo app for Android and iOS, inspired by
[Taskwarrior](https://taskwarrior.org) and
[TaskwarriorC2](https://bitbucket.org/kvorobyev/taskwarriorc2/).

Brief list of planned features:

- List tasks.
- Add tasks.
- Edit tasks.
- Sync task list with a
  [Taskserver](https://taskwarrior.org/docs/taskserver/why.html).
- Import and export tasks to a format compatible with cli
  [task](https://taskwarrior.org/docs/commands/export.html).

# Project structure

The present project,
[taskw-dart](https://github.com/bradyt/taskw-dart/), contains two
subprojects, in the subdirectories `taskw` and `task`.

The `taskw` directory is intended to contain a core library, written
in Dart, where development and tests don't require the Flutter SDK or
an emulator.

The `task` directory is where the mobile app is implemented via the
Flutter framework.

The code used to synchronize tasks with a Taskserver was started in an
earlier project, at
[taskd-client-dart](https://github.com/bradyt/taskd-client-dart).
