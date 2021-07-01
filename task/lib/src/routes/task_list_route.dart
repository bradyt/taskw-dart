import 'dart:io';

import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:task/task.dart';

class TaskListRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var profilesWidget = ProfilesWidget.of(context);
    var storageWidget = StorageWidget.of(context);

    var profilesMap = profilesWidget.profilesMap;
    var currentProfile = profilesWidget.currentProfile;

    return Scaffold(
      appBar: AppBar(
        title: Text(profilesMap[currentProfile] ?? currentProfile),
        actions: [
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
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  key: PageStorageKey('task-list'),
                  children: [
                    ListTile(
                      title: Text('Profiles'),
                      trailing: IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () => profilesWidget.addProfile()),
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
          ),
        ),
      ),
      body: Column(
        children: [
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
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    // ignore: unnecessary_null_comparison
                    if (storageWidget.globalTags != null)
                      for (var tag in storageWidget.globalTags.entries)
                        FilterChip(
                          onSelected: (_) =>
                              storageWidget.toggleTagFilter(tag.key),
                          label: Text(
                            storageWidget.selectedTags.firstWhere(
                              (selectedTag) =>
                                  selectedTag.substring(1) == tag.key,
                              orElse: () => tag.key,
                            ),
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
