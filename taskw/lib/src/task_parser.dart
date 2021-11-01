import 'package:petitparser/petitparser.dart';
import 'package:uuid/uuid.dart';

import 'package:taskj/json.dart';

class Tag {
  const Tag(this.tag);

  final String tag;

  @override
  String toString() => 'Tag($tag)';
}

class Attribute {
  const Attribute(
    this.key,
    this.value,
  );

  final String key;
  final String? value;

  @override
  String toString() => 'Attribute($key, $value)';
}

Parser space() => char(' ');
Parser colon() => char(':');

Parser quote() => char('\'');
Parser notQuote() => quote().not() & any();
Parser quotedWordPrimitive() =>
    (quote() & notQuote().star() & quote()).pick(1).flatten();

Parser unquotedWordPrimitive() =>
    ((space() | colon() | quote()).not() & any()).plus().flatten();

Parser wordPrimitive() =>
    unquotedWordPrimitive() | quotedWordPrimitive().flatten();

Parser tagPrimitive() =>
    (char('+') & unquotedWordPrimitive()).pick(1).map((value) => Tag(value));
Parser attributePrimitive() =>
    (unquotedWordPrimitive() & char(':') & wordPrimitive().optional())
        .map((value) => Attribute(value[0], value[2]));
Parser descriptionWordPrimitive() => wordPrimitive();

final add = (tagPrimitive() | attributePrimitive() | descriptionWordPrimitive())
    .separatedBy(
  char(' '),
  includeSeparators: false,
);

Task taskParser(String task) {
  var now = DateTime.now().toUtc();
  var uuid = const Uuid().v1();
  var description = add
      .parse(task)
      .value
      .whereType<String>()
      .map((part) => (part.startsWith('\'') && part.endsWith('\''))
          ? part.substring(1, part.length - 1)
          : part)
      .join(' ');
  var draft = Task(
    (b) => b
      ..description = description
      ..status = 'pending'
      ..uuid = uuid
      ..entry = now
      ..modified = now,
  );
  for (var match in add.parse(task).value) {
    if (match is Attribute) {
      var value = match.value;
      value = (value != null && value.startsWith('\'') && value.endsWith('\''))
          ? value.substring(1, value.length - 1)
          : value;
      switch (match.key) {
        case 'st':
        case 'sta':
        case 'stat':
        case 'statu':
        case 'status':
          draft = draft.rebuild((b) => b..status = value);
          break;
        case 'pro':
        case 'proj':
        case 'proje':
        case 'projec':
        case 'project':
          draft = draft.rebuild((b) => b..project = value);
          break;
        case 'pri':
        case 'prio':
        case 'prior':
        case 'priori':
        case 'priorit':
        case 'priority':
          draft = draft.rebuild((b) => b..priority = value);
          break;
        case 'due':
          draft = draft.rebuild(
            (b) =>
                b..due = (value == null) ? null : DateTime.parse(value).toUtc(),
          );
          break;
        case 'wait':
          draft = draft.rebuild(
            (b) => b
              ..wait = (value == null) ? null : DateTime.parse(value).toUtc(),
          );
          break;
        case 'until':
          draft = draft.rebuild(
            (b) => b
              ..until = (value == null) ? null : DateTime.parse(value).toUtc(),
          );
          break;
      }
    } else if (match is Tag) {
      draft = draft.rebuild((b) => b..tags = (b.tags..add(match.tag)));
    }
  }
  return draft;
}