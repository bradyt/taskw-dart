import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:taskw/taskw.dart';

import 'package:task/task.dart';

class ProjectsColumn extends StatelessWidget {
  const ProjectsColumn(this.projects, this.projectFilter, {Key? key})
      : super(key: key);

  final Map<String, ProjectMetadata> projects;
  final String projectFilter;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      key: const PageStorageKey('project-filter'),
      title: Text(
        'project:$projectFilter',
        style: GoogleFonts.firaMono(),
      ),
      children: [
        for (var entry in projects.entries)
          if (entry.value.nodeData.parent == null)
            ProjectTile(entry.key, entry.value.nodeData),
      ],
    );
  }
}

class ProjectTile extends StatelessWidget {
  const ProjectTile(this.project, this.node, {Key? key}) : super(key: key);

  final String project;
  final ProjectNode node;

  @override
  Widget build(BuildContext context) {
    if (node.children.isNotEmpty) {
      return ExpansionTile(
        textColor: Theme.of(context).textTheme.subtitle1!.color,
        controlAffinity: ListTileControlAffinity.leading,
        leading: Radio(
          toggleable: true,
          value: project,
          groupValue: StorageWidget.of(context).projectFilter,
          onChanged: (_) =>
              StorageWidget.of(context).toggleProjectFilter(project),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                project,
                style: GoogleFonts.firaMono(),
              ),
            ),
            Text(
              '(${node.tasks}) ${node.subtasks}',
              style: GoogleFonts.firaMono(),
            ),
          ],
        ),
        children: [
          for (var project in node.children)
            ProjectTile(
              project,
              StorageWidget.of(context).projects[project]!.nodeData,
            ),
        ],
      );
    }
    return RadioListTile(
      toggleable: true,
      value: project,
      groupValue: StorageWidget.of(context).projectFilter,
      onChanged: (_) => StorageWidget.of(context).toggleProjectFilter(project),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              project,
              style: GoogleFonts.firaMono(),
            ),
          ),
          Text(
            '${node.subtasks}',
            style: GoogleFonts.firaMono(),
          ),
        ],
      ),
    );
  }
}
