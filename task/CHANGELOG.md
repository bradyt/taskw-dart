# 0.0.14

- Display filename of pem file
- Do not show misleading/invented fingerprint for private key
- Use more reliable fingerprint methods

# 0.0.13

- Improve display and feedback for server error
- Update state of cert/key fingerprint in display
- Fix fingerprint in bad certificate exception

# 0.0.12

- Persist each profile's sorting and filtering
- Add feature for copying Taskserver configuration to new profile
- Display SHA-1 fingerprint of certs and keys
- Fix fingerprint in bad certificate exception

# 0.0.11

- Fix bug deserializing imask as int

# 0.0.10

- Add annotations feature
  - Indicate count in list and detail views
  - Add UI that lists annotations, and has an add button
  - Linkify urls and emails
- Display UDAs in detail view
- Prevent trailing slashes in task description which may corrupt
  account at Taskserver
- Prevent newlines in task descriptions
- Prevent spaces in new tags
- Active chips are made bold for easier visual scanning
- Move task id and status to after the task description
- Catch more errors during sync, to present to user

# 0.0.9

- Add feature to export tasks from a profile.
- Let user decide what to do when server certificates cannot be
  verified. This issue was seen with Taskserver's pki generated
  self-signed certificates, configured on iOS version of app.

# 0.0.8

- Fix bugs in tags and taskserver pages.

# 0.0.7

- Potential quick fix for short ids breaking sync.
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
