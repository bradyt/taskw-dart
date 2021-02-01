import 'package:intl/intl.dart';
import 'package:meta/meta.dart';

DateFormat iso8601Basic = DateFormat('yMMddTHHmmss\'Z\'');

@immutable
class Task {
  const Task({
    @required this.status,
    @required this.uuid,
    @required this.entry,
    @required this.description,
    this.id,
    this.start,
    this.end,
    this.due,
    this.until,
    this.wait,
    this.modified,
    this.scheduled,
    this.recur,
    this.mask,
    this.imask,
    this.parent,
    this.project,
    this.priority,
    this.depends,
    this.tags,
    this.annotations,
    this.udas,
  });

  factory Task.fromJson(Map rawJson) {
    var json = {};
    var udas = {};
    for (var entry in rawJson.entries.toList()
      ..removeWhere((entry) => entry.value == null)) {
      if ({'id', 'imask'}.contains(entry.key)) {
        json[entry.key] = entry.value.round();
      } else if ({
        'entry',
        'start',
        'end',
        'due',
        'until',
        'scheduled',
        'wait',
        'modified',
      }.contains(entry.key)) {
        json[entry.key] = DateTime.parse(entry.value);
      } else if ({
        'status',
        'uuid',
        'description',
        'recur',
        'mask',
        'parent',
        'project',
        'priority',
        'depends',
        'tags',
        'annotations',
      }.contains(entry.key)) {
        json[entry.key] = entry.value;
      } else {
        udas[entry.key] = entry.value;
      }
    }
    udas = (udas.isEmpty) ? null : udas;

    return Task(
      id: json['id'],
      status: json['status'],
      uuid: json['uuid'],
      entry: json['entry'],
      description: json['description'],
      start: json['start'],
      end: json['end'],
      due: json['due'],
      until: json['until'],
      wait: json['wait'],
      modified: json['modified'],
      scheduled: json['scheduled'],
      recur: json['recur'],
      mask: json['mask'],
      imask: json['imask'],
      parent: json['parent'],
      project: json['project'],
      priority: json['priority'],
      depends: json['depends'],
      tags: json['tags']?.cast<String>(),
      annotations: json['annotations']
          ?.map<Annotation>((annotation) => Annotation.fromJson(annotation))
          ?.toList(),
      udas: udas,
    );
  }

  final int id;
  final String status;
  final String uuid;
  final DateTime entry;
  final String description;
  final DateTime start;
  final DateTime end;
  final DateTime due;
  final DateTime until;
  final DateTime wait;
  final DateTime modified;
  final DateTime scheduled;
  final String recur;
  final String mask;
  final int imask;
  final String parent;
  final String project;
  final String priority;
  final String depends;
  final List<String> tags;
  final List<Annotation> annotations;
  final Map udas;

  Map toJson() => {
        'id': id,
        'status': status,
        'uuid': uuid,
        'entry': entry,
        'description': description,
        'start': start,
        'end': end,
        'due': due,
        'until': until,
        'scheduled': scheduled,
        'wait': wait,
        'recur': recur,
        'mask': mask,
        'imask': imask,
        'parent': parent,
        'annotations':
            annotations?.map((annotation) => annotation.toJson())?.toList(),
        'project': project,
        'tags': tags,
        'priority': priority,
        'depends': depends,
        'modified': modified,
        if (udas != null) ...udas,
      }
        ..removeWhere((_, value) => value == null)
        ..updateAll((key, value) =>
            'entry,start,end,due,until,scheduled,wait,modified'.contains(key)
                ? iso8601Basic.format(value)
                : value);

  @override
  int get hashCode => 0;

  @override
  bool operator ==(Object other) =>
      other is Task &&
      id == other.id &&
      status == other.status &&
      uuid == other.uuid &&
      entry == other.entry &&
      description == other.description &&
      start == other.start &&
      end == other.end &&
      due == other.due &&
      until == other.until &&
      scheduled == other.scheduled &&
      wait == other.wait &&
      recur == other.recur &&
      mask == other.mask &&
      imask == other.imask &&
      parent == other.parent &&
      _listEquals(annotations, other.annotations) &&
      project == other.project &&
      _listEquals(tags, other.tags) &&
      priority == other.priority &&
      depends == other.depends &&
      modified == other.modified &&
      _mapEquals(udas, other.udas);

  // copied from 'package:flutter/foundation.dart'
  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    if (identical(a, b)) return true;
    for (var index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }

  // copied from 'package:flutter/foundation.dart'
  bool _mapEquals<T, U>(Map<T, U> a, Map<T, U> b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    if (identical(a, b)) return true;
    for (var key in a.keys) {
      if (!b.containsKey(key) || b[key] != a[key]) {
        return false;
      }
    }
    return true;
  }
}

@immutable
class Annotation {
  const Annotation({@required this.entry, @required this.description});

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
