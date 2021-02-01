class TaskserverConfigurationException implements Exception {
  TaskserverConfigurationException(this.message);

  String message;

  @override
  String toString() => message;
}
