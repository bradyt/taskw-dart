void validateTaskDescription(String description) {
  if (description.substring(description.length - 1) == r'\') {
    throw FormatException(
      'Trailing backslashes may corrupt your Taskserver account.',
      description,
      description.length - 1,
    );
  }
}
