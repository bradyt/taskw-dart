import 'package:taskc/json.dart';

double urgency(Task task) {
  // https://github.com/GothenburgBitFactory/taskwarrior/blob/v2.5.3/src/Task.cpp#L1912-L2031
  // https://github.com/GothenburgBitFactory/taskwarrior/blob/v2.5.3/src/Context.cpp#L146-L160

  // % task show coefficient
  //
  // Config Variable                    Value
  // urgency.active.coefficient         4.0
  // urgency.age.coefficient            2.0
  // urgency.annotations.coefficient    1.0
  // urgency.blocked.coefficient        -5.0
  // urgency.blocking.coefficient       8.0
  // urgency.due.coefficient            12.0
  // urgency.project.coefficient        1.0
  // urgency.scheduled.coefficient      5.0
  // urgency.tags.coefficient           1.0
  // urgency.uda.priority.H.coefficient 6.0
  // urgency.uda.priority.L.coefficient 1.8
  // urgency.uda.priority.M.coefficient 3.9
  // urgency.user.tag.next.coefficient  15.0
  // urgency.waiting.coefficient        -3.0

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

  return double.parse(result.toStringAsFixed(3));
}

double urgencyScheduled(Task task) =>
    (task.scheduled != null && task.scheduled!.isBefore(DateTime.now()))
        ? 1
        : 0;

double urgencyWaiting(Task task) => (task.status == 'waiting') ? 1 : 0;

double urgencyTags(Task task) {
  if (task.tags?.isNotEmpty ?? false) {
    if (task.tags!.length == 1) {
      return 0.8;
    } else if (task.tags!.length == 2) {
      return 0.9;
    } else if (task.tags!.length > 2) {
      return 1;
    }
  }
  return 0;
}

double urgencyDue(Task task) {
  if (task.due != null) {
    var daysOverdue = DateTime.now().difference(task.due!).inSeconds / 86400;

    if (daysOverdue >= 7.0) {
      return 1;
    } else if (daysOverdue >= -14.0) {
      return double.parse(
          ((daysOverdue + 14) * 0.8 / 21 + 0.2).toStringAsFixed(3));
    }

    return 0.2;
  }
  return 0;
}

double urgencyAge(Task task) {
  var entryAge =
      DateTime.now().difference(task.entry).inMilliseconds / 86400000;
  if (entryAge >= 365) {
    return 1;
  } else {
    return double.parse((entryAge / 365).toStringAsFixed(3));
  }
}
