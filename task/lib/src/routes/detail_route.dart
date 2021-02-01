import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';

import 'package:taskw/taskw.dart';

class DetailRoute extends StatefulWidget {
  DetailRoute(this.uuid);

  final String uuid;

  @override
  _DetailRouteState createState() => _DetailRouteState();
}

class _DetailRouteState extends State<DetailRoute> {
  Modify modify;

  @override
  void initState() {
    super.initState();
    getApplicationDocumentsDirectory().then((dir) {
      modify = Modify(
        storage: Profiles(dir).getCurrentStorage(),
        uuid: widget.uuid,
      );
      setState(() {});
    });
  }

  void Function(dynamic) callback(String name) {
    return (newValue) {
      switch (name) {
        case 'status':
          modify.setStatus(newValue);
          break;
        case 'due':
          modify.setDue(newValue);
          break;
        case 'priority':
          modify.setPriority(newValue);
          break;
        case 'tags':
          modify.setTags(newValue);
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
        title: Text(widget.uuid.split('-').first),
      ),
      body: ListView(
        children: [
          if (modify?.draft != null)
            for (var entry in {
              'description': modify.draft.description,
              'status': modify.draft.status,
              'entry': modify.draft.entry,
              'modified': modify.draft.modified,
              'end': modify.draft.end,
              'due': modify.draft.due,
              'priority': modify.draft.priority,
              'tags': modify.draft.tags,
              'urgency': urgency(modify.draft),
            }.entries)
              AttributeWidget(
                name: entry.key,
                value: entry.value,
                callback: callback(entry.key),
              ),
        ],
      ),
      floatingActionButton: (modify?.changes?.isEmpty ?? false)
          ? null
          : FloatingActionButton(
              child: Icon(Icons.save),
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
                              Text(
                                '${change.key}:\n'
                                '  old: ${change.value['old']}\n'
                                '  new: ${change.value['new']}',
                                style: GoogleFonts.firaMono(),
                              ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          child: Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        ElevatedButton(
                          child: Text('Submit'),
                          onPressed: () {
                            var now = DateTime.now().toUtc();
                            modify.save(
                              modified: () => now,
                            );
                            setState(() {});
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
    );
  }
}

class AttributeWidget extends StatelessWidget {
  AttributeWidget({this.name, this.value, this.callback});

  final String name;
  final dynamic value;
  final void Function(dynamic) callback;

  @override
  Widget build(BuildContext context) {
    var localValue =
        (value is DateTime) ? (value as DateTime).toLocal() : value;
    switch (name) {
      case 'status':
        return StatusWidget(
          name: name,
          value: localValue,
          callback: callback,
        );
      case 'due':
        return DueWidget(
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
      case 'tags':
        return TagsWidget(
          name: name,
          value: localValue,
          callback: callback,
        );
      default:
        return Card(
          child: ListTile(
            title: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Text(
                    '${'$name:'.padRight(13)}$localValue',
                    style: GoogleFonts.firaMono(),
                  ),
                ],
              ),
            ),
          ),
        );
    }
  }
}

class StatusWidget extends StatelessWidget {
  StatusWidget({this.name, this.value, this.callback});

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
              break;
            case 'completed':
              return callback('deleted');
              break;
            case 'deleted':
              return callback('pending');
              break;
          }
        },
      ),
    );
  }
}

class DueWidget extends StatelessWidget {
  DueWidget({this.name, this.value, this.callback});

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
        onTap: (name == 'due')
            ? () {
                var dt = DateTime.now().toUtc();
                return callback(dt);
              }
            : null,
        onLongPress: (name == 'due') ? () => callback(null) : null,
      ),
    );
  }
}

class PriorityWidget extends StatelessWidget {
  PriorityWidget({this.name, this.value, this.callback});

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

class TagsWidget extends StatelessWidget {
  TagsWidget({this.name, this.value, this.callback});

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
          if (value == null) {
            return callback(['next']);
          } else if (value.contains('next')) {
            value.remove('next');
            if (value.isEmpty) {
              return callback(null);
            }
            return callback(value);
          } else {
            value.add('next');
            return callback(value);
          }
        },
      ),
    );
  }
}
