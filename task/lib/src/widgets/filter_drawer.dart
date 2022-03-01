import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:taskw/taskw.dart';

import 'package:task/task.dart';

class FilterDrawer extends StatelessWidget {
  const FilterDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var storageWidget = StorageWidget.of(context);

    return Drawer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: ListView(
            primary: false,
            key: const PageStorageKey('tags-filter'),
            children: [
              Card(
                child: ListTile(
                  title: Text(
                    'filter:${storageWidget.pendingFilter ? 'status:pending' : ''}',
                    style: GoogleFonts.firaMono(),
                  ),
                  onTap: storageWidget.togglePendingFilter,
                ),
              ),
              const Divider(),
              const ProjectsColumn(),
              const Divider(),
              Wrap(
                spacing: 4,
                children: [
                  FilterChip(
                    onSelected: (_) => storageWidget.toggleTagUnion(),
                    label: Text(
                      storageWidget.tagUnion ? 'OR' : 'AND',
                      style: GoogleFonts.firaMono(),
                    ),
                  ),
                  // ignore: unnecessary_null_comparison
                  if (storageWidget.globalTags != null)
                    for (var tag in storageWidget.globalTags.entries.where(
                        (entry) =>
                            entry.value.frequency > 0 || entry.value.selected))
                      FilterChip(
                        onSelected: (_) =>
                            storageWidget.toggleTagFilter(tag.key),
                        label: Text(
                          '${storageWidget.selectedTags.firstWhere(
                            (selectedTag) =>
                                selectedTag.substring(1) == tag.key,
                            orElse: () => tag.key,
                          )} ${tag.value.frequency}',
                          style: GoogleFonts.firaMono(
                            fontWeight: storageWidget.selectedTags.any(
                                    (selectedTag) =>
                                        selectedTag.substring(1) == tag.key)
                                ? FontWeight.w700
                                : null,
                          ),
                        ),
                      ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProjectsColumn extends StatelessWidget {
  const ProjectsColumn({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var storageWidget = StorageWidget.of(context);

    return ExpansionTile(
      key: const PageStorageKey('project-filter'),
      title: Text(
        'project:${storageWidget.projectFilter}',
        style: GoogleFonts.firaMono(),
      ),
      children: [
        for (var entry in storageWidget.projects.entries)
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
