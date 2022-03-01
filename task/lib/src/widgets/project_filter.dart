import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:taskw/taskw.dart';

class InheritedProjects extends InheritedWidget {
  const InheritedProjects({
    required this.projects,
    required this.projectFilter,
    required this.callback,
    required Widget child,
    Key? key,
  }) : super(key: key, child: child);

  final Map<String, ProjectNode> projects;
  final String projectFilter;
  final void Function(String) callback;

  static InheritedProjects of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<InheritedProjects>()!;
  }

  @override
  bool updateShouldNotify(InheritedProjects oldWidget) =>
      projectFilter != oldWidget.projectFilter ||
      projects != oldWidget.projects ||
      callback != oldWidget.callback;
}

class ProjectsColumn extends StatelessWidget {
  const ProjectsColumn(this.projects, this.projectFilter, this.callback,
      {Key? key})
      : super(key: key);

  final Map<String, ProjectNode> projects;
  final String projectFilter;
  final void Function(String) callback;

  @override
  Widget build(BuildContext context) {
    return InheritedProjects(
      projectFilter: projectFilter,
      callback: callback,
      projects: projects,
      child: ExpansionTile(
        key: const PageStorageKey('project-filter'),
        title: Text(
          'project:$projectFilter',
          style: GoogleFonts.firaMono(),
        ),
        children: (Map.of(projects)
              ..removeWhere((_, nodeData) => nodeData.parent != null))
            .keys
            .map(ProjectTile.new)
            .toList(),
      ),
    );
  }
}

class ProjectTile extends StatelessWidget {
  const ProjectTile(this.project, {Key? key}) : super(key: key);

  final String project;

  @override
  Widget build(BuildContext context) {
    var inheritedProjects = InheritedProjects.of(context);

    var node = inheritedProjects.projects[project]!;
    var projectFilter = inheritedProjects.projectFilter;
    void callback(String? project) => inheritedProjects.callback(project!);

    var title = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(child: Text(project, style: GoogleFonts.firaMono())),
        Text(
          (node.children.isEmpty)
              ? '${node.subtasks}'
              : '(${node.tasks}) ${node.subtasks}',
          style: GoogleFonts.firaMono(),
        )
      ],
    );

    return (node.children.isEmpty)
        ? RadioListTile(
            toggleable: true,
            value: project,
            groupValue: projectFilter,
            onChanged: callback,
            title: title,
          )
        : ExpansionTile(
            textColor: Theme.of(context).textTheme.subtitle1!.color,
            controlAffinity: ListTileControlAffinity.leading,
            leading: Radio(
              toggleable: true,
              value: project,
              groupValue: projectFilter,
              onChanged: callback,
            ),
            title: title,
            children: [for (var project in node.children) ProjectTile(project)],
          );
  }
}
