import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';

import 'package:taskc/taskc.dart';

import 'package:taskw/taskw.dart';

class DetailRoute extends StatefulWidget {
  DetailRoute(this.uuid);

  final String uuid;

  @override
  _DetailRouteState createState() => _DetailRouteState();
}

class _DetailRouteState extends State<DetailRoute> {
  Set<String> changes;
  Task savedTask;
  Task draftedTask;

  @override
  void initState() {
    super.initState();
    changes = {};
    getApplicationDocumentsDirectory().then((dir) {
      savedTask = Profiles(dir).getCurrentStorage().getTask(widget.uuid);
      draftedTask = Profiles(dir).getCurrentStorage().getTask(widget.uuid);
      setState(() {});
    });
  }

  void Function(dynamic) callback(String name) {
    return (newValue) {
      if (newValue == savedTask.toJson()[name]) {
        changes.remove(name);
      } else {
        changes.add(name);
      }
      draftedTask = draftedTask.copyWith(
        due: (name == 'due') ? () => newValue : null,
      );
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
          if (draftedTask != null)
            for (var entry in {
              'description': draftedTask.description,
              'status': draftedTask.status,
              'entry': draftedTask.entry,
              'modified': draftedTask.modified,
              'end': draftedTask.end,
              'due': draftedTask.due,
              'priority': draftedTask.priority,
              'tags': draftedTask.tags,
              'urgency': urgency(draftedTask),
            }.entries)
              AttributeWidget(
                name: entry.key,
                value: entry.value,
                callback: callback(entry.key),
              ),
        ],
      ),
      floatingActionButton: (changes.isEmpty)
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
                            if (draftedTask.toJson()['due'] !=
                                savedTask.toJson()['due'])
                              Text(
                                'due:\n'
                                '  old: ${savedTask.due}\n'
                                '  new: ${draftedTask.due}',
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
                            getApplicationDocumentsDirectory().then((dir) {
                              var storage = Profiles(dir).getCurrentStorage();
                              var now = DateTime.now().toUtc();
                              storage.mergeTask(
                                draftedTask.copyWith(
                                  modified: () => now,
                                ),
                              );
                              savedTask = storage.getTask(widget.uuid);
                              draftedTask = storage.getTask(widget.uuid);
                              changes = {};
                              setState(() {});
                              Navigator.of(context).pop();
                            });
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
      case 'due':
        return DueWidget(
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
