import 'package:taskc/taskc.dart';

double urgency(Task task) {
  // https://github.com/GothenburgBitFactory/taskwarrior/blob/v2.5.3/src/Task.cpp#L1912-L2031

  var result = 0.0;

  if (task.tags?.contains('next') ?? false) {
    result += 15;
  }

  switch (task.priority) {
    case 'H':
      result += 6;
      break;
    case 'M':
      result += 3.9;
      break;
    case 'L':
      result += 1.8;
      break;
    default:
  }

  result += 5.0 * urgencyScheduled(task);
  result += -3.0 * urgencyWaiting(task);
  result += 1.0 * urgencyTags(task);
  result += 12.0 * urgencyDue(task);
  result += 2.0 * urgencyAge(task);

  return num.parse(result.toStringAsFixed(3));
}

double urgencyScheduled(Task task) =>
    (task.scheduled != null && task.scheduled.isBefore(DateTime.now())) ? 1 : 0;

double urgencyWaiting(Task task) => (task.status == 'waiting') ? 1 : 0;

double urgencyTags(Task task) {
  if (task.tags?.isNotEmpty ?? false) {
    if (task.tags.length == 1) {
      return 0.8;
    } else if (task.tags.length == 2) {
      return 0.9;
    } else if (task.tags.length > 2) {
      return 1;
    }
  }
  return 0;
}

double urgencyDue(Task task) {
  if (task.due != null) {
    var daysOverdue = DateTime.now().difference(task.due).inSeconds / 86400;

    if (daysOverdue >= 7.0) {
      return 1;
    } else if (daysOverdue >= -14.0) {
      return num.parse(
          ((daysOverdue + 14) * 0.8 / 21 + 0.2).toStringAsFixed(3));
    }

    return 0.2;
  }
  return 0;
}

double urgencyAge(Task task) {
  if (task.entry != null) {
    var entryAge =
        DateTime.now().difference(task.entry).inMilliseconds / 86400000;
    if (entryAge >= 365) {
      return 1;
    } else {
      return num.parse((entryAge / 365).toStringAsFixed(3));
    }
  }
  return 0;
}
