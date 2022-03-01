import 'dart:io';

import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:task/task.dart';

class Queries {
  const Queries({
    required this.tabUuids,
    required this.tabAlias,
    required this.initialTabIndex,
    required this.setInitialTabIndex,
    required this.addTab,
    required this.removeTab,
  });

  final List<String> tabUuids;
  final String? Function(String) tabAlias;
  final int initialTabIndex;
  final void Function(int) setInitialTabIndex;
  final void Function() addTab;
  final void Function(int) removeTab;
}

class QueryUI {
  const QueryUI({
    required this.selectedUuid,
    required this.select,
    required this.uuid,
    required this.rename,
    required this.delete,
    this.alias,
  });

  final String selectedUuid;
  final String uuid;
  final void Function() select;
  final void Function() rename;
  final void Function() delete;
  final String? alias;

  Map toMap() => {
        'uuid': uuid,
        'selected': selectedUuid == uuid,
        if (alias != null) 'alias': alias,
      };

  @override
  String toString() => toMap().toString();
}

class MainDrawer extends StatelessWidget {
  const MainDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var storageWidget = StorageWidget.of(context);

    var queries = Queries(
      tabUuids: storageWidget.tabUuids(),
      tabAlias: storageWidget.tabAlias,
      initialTabIndex: storageWidget.initialTabIndex(),
      setInitialTabIndex: storageWidget.setInitialTabIndex,
      addTab: storageWidget.addTab,
      removeTab: storageWidget.removeTab,
    );

    var tabUuids = queries.tabUuids;
    var tabAlias = queries.tabAlias;
    var initialTabIndex = queries.initialTabIndex;
    var setInitialTabIndex = queries.setInitialTabIndex;
    var removeTab = queries.removeTab;

    var queryUIs = tabUuids.asMap().entries.map((entry) {
      return QueryUI(
        uuid: entry.value,
        alias: tabAlias(entry.value),
        select: () => setInitialTabIndex(entry.key),
        selectedUuid: tabUuids[initialTabIndex],
        rename: () => showDialog(
          context: context,
          builder: (_) => RenameTabDialog(
            tab: entry.value,
            alias: null,
            context: context,
          ),
        ),
        delete: () => removeTab(entry.key),
      );
    });

    return SingleChildScrollView(
      primary: false,
      child: Column(
        children: [
          const ProfilesColumn(),
          const Divider(),
          QueriesColumn(queryUIs, queries.addTab),
          if (Platform.isAndroid) ...[
            const Divider(),
            const ListTile(
              title: Text('Privacy policy:'),
              subtitle: Text('This app does not collect data.'),
            ),
          ],
        ],
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

    return Column(
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
                  key: PageStorageKey<String>('scroll-title-${entry.key}'),
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    entry.value ?? '',
                    style: GoogleFonts.firaMono(),
                  ),
                ),
                subtitle: SingleChildScrollView(
                  key: PageStorageKey<String>('scroll-subtitle-${entry.key}'),
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
      ],
    );
  }
}

class QueriesColumn extends StatelessWidget {
  const QueriesColumn(
    this.queryUIs,
    this.addQuery, {
    Key? key,
  }) : super(key: key);

  final Iterable<QueryUI> queryUIs;
  final void Function() addQuery;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: const Text('Queries'),
          trailing: IconButton(
            icon: const Icon(Icons.add),
            onPressed: addQuery,
          ),
        ),
        for (var queryUI in queryUIs) QueryExpansionTile(queryUI),
      ],
    );
  }
}

class QueryExpansionTile extends StatelessWidget {
  const QueryExpansionTile(this.queryUI, {Key? key}) : super(key: key);

  final QueryUI queryUI;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      key: PageStorageKey<String>('exp-${queryUI.uuid}'),
      leading: Radio<String>(
        value: queryUI.uuid,
        groupValue: queryUI.selectedUuid,
        onChanged: (_) => queryUI.select(),
      ),
      title: SingleChildScrollView(
        key: PageStorageKey<String>('scroll-${queryUI.uuid}'),
        scrollDirection: Axis.horizontal,
        child: Text(
          queryUI.alias ?? queryUI.uuid,
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
          onTap: queryUI.rename,
        ),
        ListTile(
          leading: const Padding(
            padding: EdgeInsets.all(12),
            child: Icon(Icons.delete),
          ),
          title: const Text('Delete query'),
          onTap: queryUI.delete,
        ),
      ],
    );
  }
}
