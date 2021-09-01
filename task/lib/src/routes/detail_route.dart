import 'package:flutter/material.dart';

import 'package:built_collection/built_collection.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:taskw/taskw.dart';

import 'package:task/task.dart';

class DetailRoute extends StatefulWidget {
  const DetailRoute(this.uuid);

  final String uuid;

  @override
  _DetailRouteState createState() => _DetailRouteState();
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
      switch (name) {
        case 'description':
          modify.setDescription(newValue);
          break;
        case 'status':
          modify.setStatus(newValue);
          break;
        case 'due':
          modify.setDue(newValue);
          break;
        case 'wait':
          modify.setWait(newValue);
          break;
        case 'until':
          modify.setUntil(newValue);
          break;
        case 'priority':
          modify.setPriority(newValue);
          break;
        case 'project':
          modify.setProject(newValue);
          break;
        case 'tags':
          modify.setTags(newValue);
          break;
        case 'annotations':
          modify.setAnnotations(newValue);
          break;
        default:
      }
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
        children: [
          for (var entry in {
            'description': modify.draft.description,
            'status': modify.draft.status,
            'entry': modify.draft.entry,
            'modified': modify.draft.modified,
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
                      title: Text('Review changes:'),
                      content: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (var change in modify.changes.entries)
                              (change) {
                                var _old = change.value['old'];
                                var _new = change.value['new'];
                                if (_old is DateTime) {
                                  _old = _old.toLocal();
                                }
                                if (_new is DateTime) {
                                  _new = _new.toLocal();
                                }
                                return Text(
                                  '${change.key}:\n'
                                  '  old: $_old\n'
                                  '  new: $_new',
                                  style: GoogleFonts.firaMono(),
                                );
                              }(change),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Cancel'),
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
                          child: Text('Submit'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Icon(Icons.save),
            ),
    );
  }
}

class AttributeWidget extends StatelessWidget {
  const AttributeWidget({
    required this.name,
    required this.value,
    required this.callback,
  });

  final String name;
  final dynamic value;
  final void Function(dynamic) callback;

  @override
  Widget build(BuildContext context) {
    var localValue = (value is DateTime)
        ? value.toLocal()
        : ((value is BuiltList) ? value.toBuilder() : value);
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
          color: Color(0x00000000),
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
              title: Text('Edit description'),
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
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    try {
                      validateTaskDescription(controller.text);
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
                  child: Text('Submit'),
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

class DateTimeWidget extends StatelessWidget {
  const DateTimeWidget({
    required this.name,
    required this.value,
    required this.callback,
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
              title: Text('Edit project'),
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
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    try {
                      validateTaskProject(controller.text);
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
                  child: Text('Submit'),
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
                '${'$name:'.padRight(13)}${value?.build()}',
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
                    : '${'$name:'.padRight(13)}${value.length} annotation(s)',
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
