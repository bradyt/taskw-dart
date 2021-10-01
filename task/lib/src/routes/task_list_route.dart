import 'dart:io';

import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

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
                ? Icon(Icons.cancel)
                : Icon(Icons.search),
            onPressed: storageWidget.toggleSearch,
          ),
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () => storageWidget.synchronize(context),
            ),
          ),
          IconButton(
            icon: Icon(Icons.sort),
            onPressed: storageWidget.toggleSortHeader,
          ),
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.filter_list),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: ProfilesColumn(),
        ),
      ),
      body: Column(
        children: [
          if (storageWidget.searchVisible)
            Card(
              child: TextField(
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
                padding: EdgeInsets.all(4),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (var sort in [
                      'id',
                      'entry',
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
              child: TaskListView(),
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(8),
            child: ListView(
              key: PageStorageKey('tags-filter'),
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
                Divider(),
                ExpansionTile(
                  key: PageStorageKey('project-filter'),
                  title: Text('project:${storageWidget.projectFilter}'),
                  children: [
                    for (var entry in storageWidget.projects.entries)
                      ListTile(
                        onTap: () =>
                            storageWidget.toggleProjectFilter(entry.key),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                entry.key,
                                style: GoogleFonts.firaMono(),
                              ),
                            ),
                            Text(
                              '${entry.value.frequency}',
                              style: GoogleFonts.firaMono(),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                Divider(),
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
        onPressed: () => showDialog(
          context: context,
          builder: (context) => AddTaskDialog(),
        ),
        tooltip: 'Add task',
        child: Icon(Icons.add),
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
            key: PageStorageKey('task-list'),
            children: [
              ListTile(
                title: Text('Profiles'),
                trailing: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () => profilesWidget.addProfile(),
                ),
              ),
              for (var entry in profilesMap.entries)
                ExpansionTile(
                  key: PageStorageKey<String>('exp-${entry.key}'),
                  leading: Radio<String>(
                    value: entry.key,
                    groupValue: currentProfile,
                    onChanged: (profile) =>
                        profilesWidget.selectProfile(profile!),
                  ),
                  title: SingleChildScrollView(
                    key: PageStorageKey<String>('scroll-${entry.key}'),
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      entry.value ?? entry.key,
                      style: GoogleFonts.firaMono(),
                    ),
                  ),
                  children: [
                    ListTile(
                      leading: Padding(
                        padding: EdgeInsets.all(12),
                        child: Icon(Icons.edit),
                      ),
                      title: Text('Rename profile'),
                      onTap: () => showDialog(
                        context: context,
                        builder: (context) => RenameProfileDialog(
                          profile: entry.key,
                          alias: entry.value,
                          context: context,
                        ),
                      ),
                    ),
                    ListTile(
                      leading: Padding(
                        padding: EdgeInsets.all(12),
                        child: Icon(Icons.link),
                      ),
                      title: Text('Configure Taskserver'),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ConfigureTaskserverRoute(
                            ProfilesWidget.of(context).getStorage(
                              entry.key,
                            ),
                          ),
                        ),
                      ),
                    ),
                    ListTile(
                        leading: Padding(
                          padding: EdgeInsets.all(12),
                          child: Icon(Icons.file_download),
                        ),
                        title: Text('Export tasks'),
                        onTap: () {
                          var tasks = ProfilesWidget.of(context)
                              .getStorage(entry.key)
                              .home
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
                      leading: Padding(
                        padding: EdgeInsets.all(12),
                        child: Icon(Icons.copy),
                      ),
                      title: Text('Copy config to new profile'),
                      onTap: () => ProfilesWidget.of(context)
                          .copyConfigToNewProfile(entry.key),
                    ),
                    ListTile(
                      leading: Padding(
                        padding: EdgeInsets.all(12),
                        child: Icon(Icons.delete),
                      ),
                      title: Text('Delete profile'),
                      onTap: () => showDialog(
                        context: context,
                        builder: (context) => DeleteProfileDialog(
                          profile: entry.key,
                          context: context,
                        ),
                      ),
                    ),
                  ],
                ),
              Divider(),
              ListTile(
                title: Text('Queries'),
                trailing: IconButton(
                  icon: Icon(Icons.add),
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
                      leading: Padding(
                        padding: EdgeInsets.all(12),
                        child: Icon(Icons.edit),
                      ),
                      title: Text('Rename query'),
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
                      leading: Padding(
                        padding: EdgeInsets.all(12),
                        child: Icon(Icons.delete),
                      ),
                      title: Text('Delete query'),
                      onTap: () => storageWidget.removeTab(entry.key),
                    ),
                  ],
                ),
            ],
          ),
        ),
        if (Platform.isAndroid) ...[
          Divider(),
          ListTile(
            title: Text('Privacy policy:'),
            subtitle: Text('This app does not collect data.'),
          ),
        ],
      ],
    );
  }
}
