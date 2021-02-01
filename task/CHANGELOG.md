# 0.0.3

- Add tag editing UI
- Add due date and priority to task list view

# 0.0.2

- Fix bug: do not fetch fonts after installing.

# 0.0.1

- Fix bug: save due date in UTC timezone, not local time.
- Switch to `file_picker_writable`, may reduce app size.

# 0.0.0

First versioning of app, with the following features:

- Add tasks.
- Edit following fields of tasks.
  - Edit description.
  - Cycle through statuses pending completed or deleted, adjusting end
    date automatically.
  - Pick due date with date and time dialogs.
  - Cycle priority through H M L null.
  - Toggle +next tag.
- Manage list of profiles, each one is a directory containing tasks
  and optionally a Taskserver configuration.
- A sync button in the task list view, functioning if Taskserver is
  configured.
