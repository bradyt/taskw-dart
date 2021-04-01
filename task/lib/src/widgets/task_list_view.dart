import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:taskw/taskw.dart';

import 'package:task/task.dart';

class TaskListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var taskData = StorageWidget.of(context).tasks;
    var pendingFilter = StorageWidget.of(context).pendingFilter;

    return ListView(
      children: [
        for (var task in taskData)
          Card(
            child: InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailRoute(task.uuid),
                ),
              ),
              child: ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Text(
                          task.description,
                          style: GoogleFonts.firaMono(),
                        ),
                      ),
                    ),
                    Text(
                      (task.annotations != null)
                          ? ' [${task.annotations!.length}]'
                          : '',
                      style: GoogleFonts.firaMono(),
                    ),
                  ],
                ),
                subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Text(
                          '${(task.id == 0) ? '-' : task.id} '
                                  '${pendingFilter ? '' : '${task.status[0].toUpperCase()} '}'
                                  '${age(task.entry)} '
                                  '${(task.due != null) ? when(task.due!) : ''} '
                                  '${task.priority ?? ''} '
                                  '[${task.tags?.join(',') ?? ''}]'
                              .replaceFirst(RegExp(r' \[\]$'), '')
                              .replaceAll(RegExp(r' +'), ' '),
                          style: GoogleFonts.firaMono(),
                        ),
                      ),
                    ),
                    Text(
                      ' ${urgency(task).toStringAsFixed(1).replaceFirst(RegExp(r'.0$'), '')}',
                      style: GoogleFonts.firaMono(),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
