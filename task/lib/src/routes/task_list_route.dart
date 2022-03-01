import 'dart:io';

import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:task/task.dart';

class Filters {
  const Filters({
    required this.pendingFilter,
    required this.togglePendingFilter,
    required this.tagFilters,
    required this.projects,
    required this.projectFilter,
    required this.toggleProjectFilter,
  });

  final bool pendingFilter;
  final void Function() togglePendingFilter;
  final TagFilters tagFilters;
  final dynamic projects;
  final String projectFilter;
  final void Function(String) toggleProjectFilter;
}

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

    var taskData = storageWidget.tasks;
    var pendingFilter = storageWidget.pendingFilter;

    var pendingTags = storageWidget.pendingTags;

    var selectedTagsMap = {
      for (var tag in storageWidget.selectedTags) tag.substring(1): tag,
    };

    var keys = (pendingTags.keys.toSet()..addAll(selectedTagsMap.keys)).toList()
      ..sort();

    var tags = {
      for (var tag in keys)
        tag: TagFilterMetadata(
          display:
              '${selectedTagsMap[tag] ?? tag} ${pendingTags[tag]?.frequency ?? 0}',
          selected: selectedTagsMap.containsKey(tag),
        ),
    };

    var tagFilters = TagFilters(
      tagUnion: storageWidget.tagUnion,
      toggleTagUnion: storageWidget.toggleTagUnion,
      tags: tags,
      toggleTagFilter: storageWidget.toggleTagFilter,
    );

    var filters = Filters(
      pendingFilter: pendingFilter,
      togglePendingFilter: storageWidget.togglePendingFilter,
      projects: storageWidget.projects,
      projectFilter: storageWidget.projectFilter,
      toggleProjectFilter: storageWidget.toggleProjectFilter,
      tagFilters: tagFilters,
    );

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
                      'modified',
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
          Expanded(
            child: Scrollbar(
              child: TaskListView(
                taskData: taskData,
                pendingFilter: pendingFilter,
              ),
            ),
          ),
        ],
      ),
      endDrawer: FilterDrawer(filters),
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
            primary: false,
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
