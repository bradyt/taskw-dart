import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:taskc/taskc.dart';

class DetailRoute extends StatefulWidget {
  DetailRoute(this.task);

  final Task task;

  @override
  _DetailRouteState createState() => _DetailRouteState();
}

class _DetailRouteState extends State<DetailRoute> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task.uuid.split('-').first),
      ),
      body: ListView(
        children: [
          for (var attribute in {
            'description': widget.task.description,
            'status': widget.task.status,
            'entry': widget.task.entry,
            'modified': widget.task.modified,
            'end': widget.task.end,
            'due': widget.task.due,
            'priority': widget.task.priority,
            'tags': widget.task.tags,
          }.entries)
            AttributeWidget(
              name: attribute.key,
              value: attribute.value,
            ),
        ],
      ),
    );
  }
}

class AttributeWidget extends StatelessWidget {
  AttributeWidget({this.name, this.value});

  final String name;
  final dynamic value;

  @override
  Widget build(BuildContext context) {
    var localValue =
        (value is DateTime) ? (value as DateTime).toLocal() : value;
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
