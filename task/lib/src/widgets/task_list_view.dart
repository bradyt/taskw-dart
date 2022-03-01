import 'package:flutter/material.dart';

import 'package:task/task.dart';

class TaskListView extends StatelessWidget {
  const TaskListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var taskData = StorageWidget.of(context).tasks;
    var pendingFilter = StorageWidget.of(context).pendingFilter;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
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
              child: TaskListItem(task, pendingFilter: pendingFilter),
            ),
          ),
      ],
    );
  }
}
