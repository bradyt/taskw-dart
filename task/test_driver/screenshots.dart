import 'package:flutter_driver/driver_extension.dart';
import 'package:task/main.dart' as task;

void main() {
  enableFlutterDriverExtension();

  task.main(['flutter_driver_test']);
}
