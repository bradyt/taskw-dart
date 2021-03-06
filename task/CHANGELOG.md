# 0.0.7

- Improve UI for configuration of Taskserver.
- Add negative tag filtering, e.g. -next means hide tasks that have
  the next tag.
- Sort buttons are simpler, cycling through two states instead of
  three.
- Remove `android.permission.READ_EXTERNAL_STORAGE`.

# 0.0.6

- Add sort feature.
- Add tag filtering UI.
- Add toggle button to remove status:pending filter.
- Add wait and until features.
- Fix issue where tag editing page was not scrollable.
- Add id feature similar to cli task's.
- Add scrollbar to task list view.
- Display fields of Taskserver configuration on separate lines.

# 0.0.5

- Add privacy policy to Android app, to comply with Play Store.
- Make the following display improvements:
  - 3.1424657534246574y ==> 3.1y
  - 1.0027397260273974y ==> 1y
  - 12w ==> 3mo
  - 42m ==> 42min
- Extend upper and lower bounds in datetime picker.
  - Old: 2000-01-01--2037-01-01
  - New: 1990-01-01--2037-12-31

# 0.0.4

- Fix internet permission on Android.
- Sort unused tags alphabetically in tag editing UI.
- Text editing starts with current value, instead of blank.
- Avoid OS notches overlap of tag editing UI.
- Wrap line when editing long descriptions.

# 0.0.3

- Add tag editing UI.
- Add due date and priority to task list view.

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
