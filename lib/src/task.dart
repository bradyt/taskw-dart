class Task {
  Task({
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

  factory Task.fromJson(Map json) => Task(
        status: json['status'],
        uuid: json['uuid'],
        entry: (json['entry'] == null) ? null : DateTime.parse(json['entry']),
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

  Map toJson() => {
        'description': description,
      };
}
