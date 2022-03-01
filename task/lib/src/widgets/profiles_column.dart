import 'dart:io';

import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:task/task.dart';

class ProfilesColumn extends StatelessWidget {
  const ProfilesColumn({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var profilesWidget = ProfilesWidget.of(context);

    var profilesMap = profilesWidget.profilesMap;
    var currentProfile = profilesWidget.currentProfile;

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
              const QueriesColumn(),
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

class QueriesColumn extends StatelessWidget {
  const QueriesColumn({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var storageWidget = StorageWidget.of(context);

    var tabUuids = storageWidget.tabUuids();
    var tabAlias = storageWidget.tabAlias;
    var initialTabIndex = storageWidget.initialTabIndex();
    var setInitialTabIndex = storageWidget.setInitialTabIndex;
    var addTab = storageWidget.addTab;
    var removeTab = storageWidget.removeTab;

    return Column(
      children: [
        ListTile(
          title: const Text('Queries'),
          trailing: IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => addTab(),
          ),
        ),
        for (var entry in tabUuids.asMap().entries)
          ExpansionTile(
            key: PageStorageKey<String>('exp-${entry.value}'),
            leading: Radio<int>(
              value: entry.key,
              groupValue: initialTabIndex,
              onChanged: (tabUuid) => setInitialTabIndex(entry.key),
            ),
            title: SingleChildScrollView(
              key: PageStorageKey<String>('scroll-${entry.key}'),
              scrollDirection: Axis.horizontal,
              child: Text(
                tabAlias(entry.value) ?? entry.value,
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
                onTap: () => removeTab(entry.key),
              ),
            ],
          ),
      ],
    );
  }
}
