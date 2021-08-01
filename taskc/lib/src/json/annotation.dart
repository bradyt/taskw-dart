import 'package:meta/meta.dart';

import 'package:taskc/json.dart';

@immutable
class Annotation {
  const Annotation({required this.entry, required this.description});

  factory Annotation.fromJson(Map annotation) => Annotation(
        entry: DateTime.parse(annotation['entry']),
        description: annotation['description'],
      );

  final DateTime entry;
  final String description;

  Map toJson() => {
        'entry': iso8601Basic.format(entry),
        'description': description,
      };

  @override
  int get hashCode => 0;

  @override
  bool operator ==(Object other) =>
      other is Annotation &&
      entry == other.entry &&
      description == other.description;
}
