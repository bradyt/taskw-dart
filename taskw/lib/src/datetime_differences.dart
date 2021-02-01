String age(DateTime dt) => difference(DateTime.now().difference(dt));

String difference(Duration difference) {
  String result;
  var days = difference.abs().inDays;
  if (days > 365) {
    result = '${days / 365}y';
  } else if (days > 7) {
    result = '${days ~/ 7}w';
  } else if (days > 0) {
    result = '${days}d';
  } else if (difference.abs().inHours > 0) {
    result = '${difference.abs().inHours}h';
  } else if (difference.abs().inMinutes > 0) {
    result = '${difference.abs().inMinutes}m';
  } else {
    result = '${difference.abs().inSeconds}s';
  }
  return '${(difference.isNegative) ? '-' : ''}$result';
}
