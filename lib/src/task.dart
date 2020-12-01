import 'package:intl/intl.dart';
import 'package:meta/meta.dart';

DateFormat format = DateFormat('yMMddTHHmmss\'Z\'');

@immutable
class Task {
  const Task({
    this.status,
    this.uuid,
    this.entry,
    this.description,
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
    this.annotation,
  });

  factory Task.fromJson(Map json) => Task(
        status: json['status'],
        uuid: json['uuid'],
        entry: DateTime.parse(json['entry']),
        description: json['description'],
        start: (json['start'] == null) ? null : DateTime.parse(json['start']),
        end: (json['end'] == null) ? null : DateTime.parse(json['end']),
        due: (json['due'] == null) ? null : DateTime.parse(json['due']),
        until: (json['until'] == null) ? null : DateTime.parse(json['until']),
        wait: (json['wait'] == null) ? null : DateTime.parse(json['wait']),
        modified: (json['modified'] == null)
            ? null
            : DateTime.parse(json['modified']),
        scheduled: (json['scheduled'] == null)
            ? null
            : DateTime.parse(json['scheduled']),
        recur: json['recur'],
        mask: json['mask'],
        imask: json['imask'],
        parent: json['parent'],
        project: json['project'],
        priority: json['priority'],
        depends: json['depends'],
        tags: json['tags'],
        annotation: json['annotation'],
      );

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
  final String tags;
  final String annotation;

  Map toJson() => {
        'status': status,
        'uuid': uuid,
        'entry': format.format(entry),
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
        'annotation': annotation,
        'project': project,
        'tags': tags,
        'priority': priority,
        'depends': depends,
        'modified': modified,
      }..removeWhere((_, value) => value == null);

  @override
  int get hashCode => 0;

  @override
  bool operator ==(Object other) =>
      other is Task &&
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
      annotation == other.annotation &&
      project == other.project &&
      tags == other.tags &&
      priority == other.priority &&
      depends == other.depends &&
      modified == other.modified;
}
