import 'package:intl/intl.dart';

/// > Dates are rendered in ISO 8601 combined date and time in UTC format using
/// > the template: `YYYYMMDDTHHMMSSZ`. An example: `20120110T231200Z`. No other
/// > formats are supported.  --
/// > <https://taskwarrior.org/docs/design/task.html#type_date>.
final DateFormat iso8601Basic = DateFormat('yMMddTHHmmss\'Z\'');
