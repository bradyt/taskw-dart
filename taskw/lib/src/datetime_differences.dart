String age(DateTime dt) {
  var difference = DateTime.now().difference(dt);
  var days = difference.inDays;
  if (days > 365) {
    return '${days / 365}y';
  } else if (days > 7) {
    return '${days ~/ 7}w';
  } else if (days > 0) {
    return '${days}d';
  } else if (difference.inHours > 0) {
    return '${difference.inHours}h';
  } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes}m';
  } else {
    return '${difference.inSeconds}s';
  }
}
