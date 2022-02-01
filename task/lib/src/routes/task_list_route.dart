import 'dart:io';

import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:taskw/taskw.dart';

import 'package:task/task.dart';

class TaskListRoute extends StatelessWidget {
  const TaskListRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var profilesWidget = ProfilesWidget.of(context);
    var storageWidget = StorageWidget.of(context);

    var profilesMap = profilesWidget.profilesMap;
    var currentProfile = profilesWidget.currentProfile;

    var tabUuid = storageWidget.tabUuids()[storageWidget.initialTabIndex()];
    var title = profilesMap[currentProfile] ?? currentProfile;
    var subtitle = storageWidget.tabAlias(tabUuid) ?? tabUuid;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.firaMono()),
            Text(subtitle, style: GoogleFonts.firaMono()),
          ],
        ),
        actions: [
          IconButton(
            icon: (storageWidget.searchVisible)
                ? const Icon(Icons.cancel)
                : const Icon(Icons.search),
            onPressed: storageWidget.toggleSearch,
          ),
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => storageWidget.synchronize(context),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: storageWidget.toggleSortHeader,
          ),
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      drawer: const Drawer(
        child: SafeArea(
          child: ProfilesColumn(),
        ),
      ),
      body: Column(
        children: [
          if (storageWidget.searchVisible)
            Card(
              child: TextField(
                autofocus: true,
                style: GoogleFonts.firaMono(),
                onChanged: (value) {
                  storageWidget.search(value);
                },
                controller: storageWidget.searchController,
              ),
            ),
          if (storageWidget.sortHeaderVisible)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (var sort in [
                      'id',
                      'entry',
                      'start',
                      'due',
                      'priority',
                      'project',
                      'tags',
                      'urgency',
                    ])
                      ChoiceChip(
                        label: (storageWidget.selectedSort.startsWith(sort))
                            ? Text(
                                storageWidget.selectedSort,
                                style: GoogleFonts.firaMono(
                                  fontWeight: FontWeight.w700,
                                ),
                              )
                            : Text(sort, style: GoogleFonts.firaMono()),
                        selected: false,
                        onSelected: (_) {
                          if (storageWidget.selectedSort == '$sort+') {
                            storageWidget.selectSort('$sort-');
                          } else {
                            storageWidget.selectSort('$sort+');
                          }
                        },
                      ),
                  ],
                ),
              ),
            ),
          const Expanded(
            child: Scrollbar(
              child: TaskListView(),
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: ListView(
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
                              entry.value.frequency > 0 ||
                              entry.value.selected))
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet(
          context: context,
          builder: (context) => const AddTaskBottomSheet(),
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
        ),
        tooltip: 'Add task',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ProfilesColumn extends StatelessWidget {
  const ProfilesColumn({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var profilesWidget = ProfilesWidget.of(context);

    var profilesMap = profilesWidget.profilesMap;
    var currentProfile = profilesWidget.currentProfile;

    var storageWidget = StorageWidget.of(context);

    var tabUuids = storageWidget.tabUuids();

    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              ListTile(
                title: const Text('Profiles'),
                trailing: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => profilesWidget.addProfile(),
                ),
              ),
              ExpansionTile(
                key: const PageStorageKey<String>('task-list'),
                title: const Text('Select profile'),
                children: [
                  for (var entry in profilesMap.entries)
                    ListTile(
                      leading: Radio<String>(
                        value: entry.key,
                        groupValue: currentProfile,
                        onChanged: (profile) =>
                            profilesWidget.selectProfile(profile!),
                      ),
                      title: SingleChildScrollView(
                        key:
                            PageStorageKey<String>('scroll-title-${entry.key}'),
                        scrollDirection: Axis.horizontal,
                        child: Text(
                          entry.value ?? '',
                          style: GoogleFonts.firaMono(),
                        ),
                      ),
                      subtitle: SingleChildScrollView(
                        key: PageStorageKey<String>(
                            'scroll-subtitle-${entry.key}'),
                        scrollDirection: Axis.horizontal,
                        child: Text(
                          entry.key,
                          style: GoogleFonts.firaMono(),
                        ),
                      ),
                    ),
                ],
              ),
              ExpansionTile(
                key: const PageStorageKey<String>('manage-profile'),
                title: const Text('Manage selected profile'),
                children: [
                  ListTile(
                    leading: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Icon(Icons.edit),
                    ),
                    title: const Text('Rename profile'),
                    onTap: () => showDialog(
                      context: context,
                      builder: (context) => RenameProfileDialog(
                        profile: currentProfile,
                        alias: profilesMap[currentProfile],
                        context: context,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Icon(Icons.link),
                    ),
                    title: const Text('Configure Taskserver'),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ConfigureTaskserverRoute(),
                      ),
                    ),
                  ),
                  ListTile(
                      leading: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Icon(Icons.file_download),
                      ),
                      title: const Text('Export tasks'),
                      onTap: () {
                        var tasks = ProfilesWidget.of(context)
                            .getStorage(currentProfile)
                            .data
                            .export();
                        var now = DateTime.now()
                            .toIso8601String()
                            .replaceAll(RegExp(r'[-:]'), '')
                            .replaceAll(RegExp(r'\..*'), '');
                        exportTasks(
                          contents: tasks,
                          suggestedName: 'tasks-$now.txt',
                        );
                      }),
                  ListTile(
                    leading: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Icon(Icons.copy),
                    ),
                    title: const Text('Copy config to new profile'),
                    onTap: () => ProfilesWidget.of(context)
                        .copyConfigToNewProfile(currentProfile),
                  ),
                  ListTile(
                    leading: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Icon(Icons.delete),
                    ),
                    title: const Text('Delete profile'),
                    onTap: () => showDialog(
                      context: context,
                      builder: (context) => DeleteProfileDialog(
                        profile: currentProfile,
                        context: context,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(),
              ListTile(
                title: const Text('Queries'),
                trailing: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => storageWidget.addTab(),
                ),
              ),
              for (var entry in tabUuids.asMap().entries)
                ExpansionTile(
                  key: PageStorageKey<String>('exp-${entry.value}'),
                  leading: Radio<int>(
                    value: entry.key,
                    groupValue: storageWidget.initialTabIndex(),
                    onChanged: (tabUuid) =>
                        storageWidget.setInitialTabIndex(entry.key),
                  ),
                  title: SingleChildScrollView(
                    key: PageStorageKey<String>('scroll-${entry.key}'),
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      StorageWidget.of(context).tabAlias(entry.value) ??
                          entry.value,
                      style: GoogleFonts.firaMono(),
                    ),
                  ),
                  children: [
                    ListTile(
                      leading: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Icon(Icons.edit),
                      ),
                      title: const Text('Rename query'),
                      onTap: () => showDialog(
                        context: context,
                        builder: (context) => RenameTabDialog(
                          tab: entry.value,
                          alias: null,
                          context: context,
                        ),
                      ),
                    ),
                    ListTile(
                      leading: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Icon(Icons.delete),
                      ),
                      title: const Text('Delete query'),
                      onTap: () => storageWidget.removeTab(entry.key),
                    ),
                  ],
                ),
            ],
          ),
        ),
        if (Platform.isAndroid) ...[
          const Divider(),
          const ListTile(
            title: Text('Privacy policy:'),
            subtitle: Text('This app does not collect data.'),
          ),
        ],
      ],
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
            (node.children.isEmpty)
                ? '${node.subtasks}'
                : '(${node.tasks}) ${node.subtasks}',
            style: GoogleFonts.firaMono(),
          ),
        ],
      ),
    );
  }
}
