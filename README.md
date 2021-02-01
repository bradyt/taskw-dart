# What is it?

`task` is a todo app for
Android<sup>[0](#fdroid-MR),[1](#fdroid),[2](#playstore)</sup> and
iOS<sup>[3](#ios)</sup>, inspired by
[Taskwarrior](https://taskwarrior.org) and
[TaskwarriorC2](https://bitbucket.org/kvorobyev/taskwarriorc2/).

Brief list of planned features:

- [x] List tasks.
- [x] Add tasks.
- [x] Edit tasks.
- [x] Sync task list with a
      [Taskserver](https://taskwarrior.org/docs/taskserver/why.html).
- [ ] Import and export tasks to a format compatible with cli
      [task](https://taskwarrior.org/docs/commands/export.html).

Slightly finer grained list of features that might be prioritized
sooner than later:

- [ ] Sort task list by fields like date created, tags, etc.
- [ ] Add more Taskwarrior fields to edit view, like wait, until.
- [x] Add a UI for editings tags, as currently user can only toggle
      the `next` tag.
- [ ] Add some feature to effectively remove the `status:pending`
      filter, for example add an `all` report.

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

<a name="fdroid-MR">0</a>:
<https://gitlab.com/fdroid/fdroiddata/-/merge_requests/8436/></br>
<a name="fdroid">1</a>:
<https://f-droid.org/en/packages/info.tangential.task/></br>
<a name="playstore">2</a>:
<https://play.google.com/store/apps/details?id=info.tangential.task></br>
<a name="ios">3</a>:
<https://apps.apple.com/app/task-add/id1553253179>
