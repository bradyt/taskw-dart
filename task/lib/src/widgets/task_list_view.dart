import 'package:flutter/material.dart';

import 'package:taskj/json.dart';

import 'package:task/task.dart';

class TaskListView extends StatelessWidget {
  const TaskListView({
      required this.taskData,
      required this.pendingFilter,
    Key? key,
  }) : super(key: key);

  final List<Task> taskData;
  final bool pendingFilter;

  @override
  Widget build(BuildContext context) {
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
