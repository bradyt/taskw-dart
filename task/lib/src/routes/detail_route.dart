import 'package:flutter/material.dart';

import 'package:built_collection/built_collection.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:taskw/taskw.dart';

import 'package:task/task.dart';

class DetailRoute extends StatefulWidget {
  const DetailRoute(this.uuid, {super.key});

  final String uuid;

  @override
  State<DetailRoute> createState() => _DetailRouteState();
}

class _DetailRouteState extends State<DetailRoute> {
  late Modify modify;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    var storageWidget = StorageWidget.of(context);
    modify = Modify(
      getTask: storageWidget.getTask,
      mergeTask: storageWidget.mergeTask,
      uuid: widget.uuid,
    );
  }

  void Function(dynamic) callback(String name) {
    return (newValue) {
      modify.set(name, newValue);
      setState(() {});
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'id: ${(modify.id == 0) ? '-' : modify.id}',
          style: GoogleFonts.firaMono(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        children: [
          for (var entry in {
            'description': modify.draft.description,
            'status': modify.draft.status,
            'entry': modify.draft.entry,
            'modified': modify.draft.modified,
            'start': modify.draft.start,
            'end': modify.draft.end,
            'due': modify.draft.due,
            'wait': modify.draft.wait,
            'until': modify.draft.until,
            'priority': modify.draft.priority,
            'project': modify.draft.project,
            'tags': modify.draft.tags,
            'annotations': modify.draft.annotations,
            'udas': modify.draft.udas,
            'urgency': urgency(modify.draft),
            'uuid': modify.draft.uuid,
          }.entries)
            AttributeWidget(
              name: entry.key,
              value: entry.value,
              callback: callback(entry.key),
            ),
        ],
      ),
      floatingActionButton: (modify.changes.isEmpty)
          ? null
          : FloatingActionButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      scrollable: true,
                      title: const Text('Review changes:'),
                      content: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Text(
                          modify.changes.entries
                              .map((entry) => '${entry.key}:\n'
                                  '  old: ${entry.value['old']}\n'
                                  '  new: ${entry.value['new']}')
                              .toList()
                              .join('\n'),
                          style: GoogleFonts.firaMono(),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            var now = DateTime.now().toUtc();
                            modify.save(
                              modified: () => now,
                            );
                            setState(() {});
                            Navigator.of(context).pop();
                          },
                          child: const Text('Submit'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Icon(Icons.save),
            ),
    );
  }
}

class AttributeWidget extends StatelessWidget {
  const AttributeWidget({
    required this.name,
    required this.value,
    required this.callback,
    super.key,
  });

  final String name;
  final dynamic value;
  final void Function(dynamic) callback;

  @override
  Widget build(BuildContext context) {
    var localValue = (value is DateTime)
        ? (value as DateTime).toLocal()
        : ((value is BuiltList) ? (value as BuiltList).toBuilder() : value);
    switch (name) {
      case 'description':
        return DescriptionWidget(
          name: name,
          value: localValue,
          callback: callback,
        );
      case 'status':
        return StatusWidget(
          name: name,
          value: localValue,
          callback: callback,
        );
      case 'start':
        return StartWidget(
          name: name,
          value: localValue,
          callback: callback,
        );
      case 'due':
        return DateTimeWidget(
          name: name,
          value: localValue,
          callback: callback,
        );
      case 'wait':
        return DateTimeWidget(
          name: name,
          value: localValue,
          callback: callback,
        );
      case 'until':
        return DateTimeWidget(
          name: name,
          value: localValue,
          callback: callback,
        );
      case 'priority':
        return PriorityWidget(
          name: name,
          value: localValue,
          callback: callback,
        );
      case 'project':
        return ProjectWidget(
          name: name,
          value: localValue,
          callback: callback,
        );
      case 'tags':
        return TagsWidget(
          name: name,
          value: localValue,
          callback: callback,
        );
      case 'annotations':
        return AnnotationsWidget(
          name: name,
          value: localValue,
          callback: callback,
        );
      default:
        return Card(
          color: const Color(0x00000000),
          elevation: 0,
          child: ListTile(
            title: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Text(
                    '${'$name:'.padRight(13)}$localValue',
                    style: GoogleFonts.firaMono(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
    }
  }
}

class DescriptionWidget extends StatelessWidget {
  const DescriptionWidget({
    required this.name,
    required this.value,
    required this.callback,
    super.key,
  });

  final String name;
  final dynamic value;
  final void Function(dynamic) callback;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Text(
                '${'$name:'.padRight(13)}$value',
                style: GoogleFonts.firaMono(),
              ),
            ],
          ),
        ),
        onTap: () {
          var controller = TextEditingController(
            text: value,
          );
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              scrollable: true,
              title: const Text('Edit description'),
              content: TextField(
                autofocus: true,
                maxLines: null,
                controller: controller,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    try {
                      callback(controller.text);
                      Navigator.of(context).pop();
                    } on FormatException catch (e, trace) {
                      showExceptionDialog(
                        context: context,
                        e: e,
                        trace: trace,
                      );
                    }
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class StatusWidget extends StatelessWidget {
  const StatusWidget({
    required this.name,
    required this.value,
    required this.callback,
    super.key,
  });

  final String name;
  final dynamic value;
  final void Function(dynamic) callback;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Text(
                '${'$name:'.padRight(13)}$value',
                style: GoogleFonts.firaMono(),
              ),
            ],
          ),
        ),
        onTap: () {
          switch (value) {
            case 'pending':
              return callback('completed');
            case 'completed':
              return callback('deleted');
            case 'deleted':
              return callback('pending');
          }
        },
      ),
    );
  }
}

class StartWidget extends StatelessWidget {
  const StartWidget({
    required this.name,
    required this.value,
    required this.callback,
    super.key,
  });

  final String name;
  final dynamic value;
  final void Function(dynamic) callback;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Text(
                '${'$name:'.padRight(13)}$value',
                style: GoogleFonts.firaMono(),
              ),
            ],
          ),
        ),
        onTap: () {
          if (value != null) {
            callback(null);
          } else {
            var now = DateTime.now().toUtc();
            callback(DateTime.utc(
              now.year,
              now.month,
              now.day,
              now.hour,
              now.minute,
              now.second,
            ));
          }
        },
      ),
    );
  }
}

class DateTimeWidget extends StatelessWidget {
  const DateTimeWidget({
    required this.name,
    required this.value,
    required this.callback,
    super.key,
  });

  final String name;
  final dynamic value;
  final void Function(dynamic) callback;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Text(
                '${'$name:'.padRight(13)}$value',
                style: GoogleFonts.firaMono(),
              ),
            ],
          ),
        ),
        onTap: () async {
          var initialDate = DateTime.tryParse('$value') ?? DateTime.now();
          var date = await showDatePicker(
            context: context,
            initialDate: initialDate,
            firstDate: DateTime(1990), // >= 1980-01-01T00:00:00.000Z
            lastDate: DateTime(2037, 12, 31), // < 2038-01-19T03:14:08.000Z
          );
          if (date != null) {
            var time = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.fromDateTime(initialDate),
            );
            if (time != null) {
              var dateTime = date.add(
                Duration(
                  hours: time.hour,
                  minutes: time.minute,
                ),
              );
              dateTime = dateTime.add(
                Duration(
                  hours: time.hour - dateTime.hour,
                ),
              );
              return callback(dateTime.toUtc());
            }
          }
        },
        onLongPress: () => callback(null),
      ),
    );
  }
}

class PriorityWidget extends StatelessWidget {
  const PriorityWidget({
    required this.name,
    required this.value,
    required this.callback,
    super.key,
  });

  final String name;
  final dynamic value;
  final void Function(dynamic) callback;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Text(
                '${'$name:'.padRight(13)}$value',
                style: GoogleFonts.firaMono(),
              ),
            ],
          ),
        ),
        onTap: () {
          switch (value) {
            case 'H':
              return callback('M');
            case 'M':
              return callback('L');
            case 'L':
              return callback(null);
            default:
              return callback('H');
          }
        },
      ),
    );
  }
}

class ProjectWidget extends StatelessWidget {
  const ProjectWidget({
    required this.name,
    required this.value,
    required this.callback,
    super.key,
  });

  final String name;
  final dynamic value;
  final void Function(dynamic) callback;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Text(
                '${'$name:'.padRight(13)}$value',
                style: GoogleFonts.firaMono(),
              ),
            ],
          ),
        ),
        onTap: () {
          var controller = TextEditingController(
            text: value,
          );
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              scrollable: true,
              title: const Text('Edit project'),
              content: TextField(
                autofocus: true,
                maxLines: null,
                controller: controller,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    try {
                      callback(
                          (controller.text == '') ? null : controller.text);
                      Navigator.of(context).pop();
                    } on FormatException catch (e, trace) {
                      showExceptionDialog(
                        context: context,
                        e: e,
                        trace: trace,
                      );
                    }
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class TagsWidget extends StatelessWidget {
  const TagsWidget({
    required this.name,
    required this.value,
    required this.callback,
    super.key,
  });

  final String name;
  final dynamic value;
  final void Function(dynamic) callback;
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Text(
                '${'$name:'.padRight(13)}${(value as ListBuilder?)?.build()}',
                style: GoogleFonts.firaMono(),
              ),
            ],
          ),
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TagsRoute(
              value: value,
              callback: callback,
            ),
          ),
        ),
      ),
    );
  }
}

class AnnotationsWidget extends StatelessWidget {
  const AnnotationsWidget({
    required this.name,
    required this.value,
    required this.callback,
    super.key,
  });

  final String name;
  final dynamic value;
  final void Function(dynamic) callback;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Text(
                (value == null)
                    ? '${'$name:'.padRight(13)}null'
                    : '${'$name:'.padRight(13)}${(value as ListBuilder).length} annotation(s)',
                style: GoogleFonts.firaMono(),
              ),
            ],
          ),
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnnotationsRoute(
              value: value,
              callback: callback,
            ),
          ),
        ),
      ),
    );
  }
}
