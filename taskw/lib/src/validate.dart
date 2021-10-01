void validateTaskDescription(String description) {
  if (description.endsWith(r'\')) {
    throw FormatException(
      'Trailing backslashes may corrupt your Taskserver account.',
      description,
      description.length - 1,
    );
  } else if (description.contains('\n')) {
    throw FormatException(
      'Taskwarrior documentation on JSON format indicates your task '
      'description should not contain newline characters.',
      description,
      description.indexOf('\n'),
    );
  }
}

void validateTaskProject(String project) {
  if (project.endsWith(r'\')) {
    throw FormatException(
      'Trailing backslashes may corrupt your Taskserver account.',
      project,
      project.length - 1,
    );
  }
}

void validateTaskTags(String tag) {
  if (tag.contains(' ')) {
    throw FormatException(
      'Taskwarrior documentation on JSON format indicates your task tag '
      'should not contain spaces.',
      tag,
      tag.indexOf(' '),
    );
  }
}
