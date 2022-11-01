# 0.2.8

- JSON export puts attributes and tags next to last, to match CLI task

# 0.2.7

- Allow line breaks in description

# 0.2.6

- Breaking change: tag editing UI buttons limited to tags from pending tasks
- Fix: Project filter wasn't updating when selecting query
- Allow sort by `modified`, display `modified` in task list view
- Tap non-leaf project filters to fold/hide subproject filters
  + Non-leaf projects indicated by contributing task count in parentheses
  + Unfortunately, toggling a non-leaf project filter is less convenient

# 0.2.5

- Updates to project filter UI
  + Task count:
    * Project's task count includes those of subprojects
    * Non-leaf project shows contributing task count in parentheses
  + Changes to project list
    * List now includes nearest common ancestor project
    * Still omits projects with one adjacent subproject and zero tasks

# 0.2.4

- Add radio widget to indicate selected project filter
- Add "d:" prefix to indicate due date in task list view
- Add start feature
  + Toggle start date
  + Display start age in list view
  + Sort by start date
  + Add 4 to urgency
  + Remove start date when marking task completed

# 0.2.3

- Fix bugs in parsing of new task
  + Fix silent dropping of attribute-like terms containing colon, like `foo:bar` or `foo:`
  + Remove problematic quote parsing feature
  + Show FormatException if user submits empty string

# 0.2.2

- Updated "new task" dialog
  + Declutter, move to bottom sheet
  + Allow consecutive inputs

# 0.2.1

- Improved "new task" dialog
  + Parse tags, priority, project, e.g., like 'Build bike +next pri:H pro:diy'
  + Button added to add due date
- Fix issue where connection used same PEM files after removing them
- Improve feedback for incorrect taskd.credentials
- Display start field

# 0.2.0

- Breaking changes:
  + taskd.certificate filename saved before version update is lost, reselect file to replace
  + Fewer or later checks, e.g.:
    * App doesn't catch null credentials
    * App catches null server instead of no TASKRC
    * App allows connection attempts with any PEM files
- Changes to profiles UI
  + List of profiles is folded, so that queries may be easier to access
  + Profile management is now limited to selected profile

# 0.1.4

- Fix bug for 'Copy config to new profile' for partial configurations
- Make taskd.ca optional
  + Long press to remove CA
- If server.cert manually trusted, show its SHA-1 in configuration, and allow to remove cert
- Send client id to Taskserver in message header
  + e.g., "client: info.tangential.task 0.1.4"
- Adjust urgency for wait for task 2.6.X
- Bring up keyboard when searching text
- Clear a task's project field by submitting empty string

# 0.1.3

- Fix bug where BadCertificateException's Trust button was broken
- Add project and annotations to urgency calculation

# 0.1.2

- Add projects feature
  + Project is displayed in list and detail views
  + Simple UI to edit project field
  + Sort by project
  + Very basic project filter
- Add search feature

# 0.1.1

- Add notion of queries, persistent shortcuts to snapshots of sorting
  and filtering options selected from UI
- Rudimentary support to apply union to tag filters
- Fix two issues in tag filter UI
  - list of tag filters were not updating after updating task list
  - a selected tag filter was active but hidden if its only tasks were
    filtered out

# 0.1.0

- Display filename of pem file
- Do not show misleading/invented fingerprint for private key
- Use more reliable fingerprint methods
- Fix for error on arrayed dependencies

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
