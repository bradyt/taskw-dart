import 'dart:io';

import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:tuple/tuple.dart';

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
    var profilesWidget = ProfilesWidget.of(context);

    var profilesMap = ProfilesWidget.of(context).profilesMap;
    var currentProfile = ProfilesWidget.of(context).currentProfile;

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
          ProfilesColumn(
            profilesMap,
            currentProfile,
            profilesWidget.addProfile,
            profilesWidget.selectProfile,
          ),
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
  const ProfilesColumn(
    this.profilesMap,
    this.currentProfile,
    this.addProfile,
    this.selectProfile, {
    Key? key,
  }) : super(key: key);

  final Map profilesMap;
  final String currentProfile;
  final void Function() addProfile;
  final void Function(String) selectProfile;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: const Text('Profiles'),
          trailing: IconButton(
            icon: const Icon(Icons.add),
            onPressed: addProfile,
          ),
        ),
        SelectProfile(currentProfile, profilesMap, selectProfile),
        ManageProfile(
          () => showDialog(
            context: context,
            builder: (context) => RenameProfileDialog(
              profile: currentProfile,
              alias: profilesMap[currentProfile],
              context: context,
            ),
          ),
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ConfigureTaskserverRoute(),
            ),
          ),
          () {
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
          },
          () =>
              ProfilesWidget.of(context).copyConfigToNewProfile(currentProfile),
          () => showDialog(
            context: context,
            builder: (context) => DeleteProfileDialog(
              profile: currentProfile,
              context: context,
            ),
          ),
        ),
      ],
    );
  }
}

class SelectProfile extends StatelessWidget {
  const SelectProfile(
    this.currentProfile,
    this.profilesMap,
    this.selectProfile, {
    Key? key,
  }) : super(key: key);

  final String currentProfile;
  final Map profilesMap;
  final void Function(String) selectProfile;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      key: const PageStorageKey<String>('task-list'),
      title: const Text('Select profile'),
      children: [
        for (var entry in profilesMap.entries)
          ListTile(
            leading: Radio<String>(
              value: entry.key,
              groupValue: currentProfile,
              onChanged: (profile) => selectProfile(profile!),
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
    );
  }
}

class ManageProfile extends StatelessWidget {
  const ManageProfile(
    this.rename,
    this.configure,
    this.export,
    this.copy,
    this.delete, {
    Key? key,
  }) : super(key: key);

  final void Function() rename;
  final void Function() configure;
  final void Function() export;
  final void Function() copy;
  final void Function() delete;

  @override
  Widget build(BuildContext context) {
    var triples = [
      Tuple3(Icons.edit, 'Rename profile', rename),
      Tuple3(Icons.link, 'Configure Taskserver', configure),
      Tuple3(Icons.file_download, 'Export tasks', export),
      Tuple3(Icons.copy, 'Copy config to new profile', copy),
      Tuple3(Icons.delete, 'Delete profile', delete),
    ];

    return ExpansionTile(
      key: const PageStorageKey<String>('manage-profile'),
      title: const Text('Manage selected profile'),
      children: [
        for (var triple in triples)
          ListTile(
            leading: Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(triple.item1),
            ),
            title: Text(triple.item2),
            onTap: triple.item3,
          )
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
