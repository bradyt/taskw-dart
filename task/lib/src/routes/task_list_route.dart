import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'package:taskc/taskc.dart';

import 'package:taskw/taskw.dart';

import 'package:task/task.dart';

class TaskListRoute extends StatefulWidget {
  @override
  _TaskListRouteState createState() => _TaskListRouteState();
}

class _TaskListRouteState extends State<TaskListRoute> {
  List<Task> tasks;
  String currentProfile;
  Map<String, String> profiles;
  Map<String, int> globalTags;
  Set<String> selectedTags;
  String selectedSort;

  @override
  void initState() {
    super.initState();
    profiles = {};
    selectedTags = {};
    _initialize();
  }

  Future<void> _initialize() async {
    var dir = await getApplicationDocumentsDirectory();
    var p = Profiles(dir);
    if (p.listProfiles().isEmpty) {
      p
        ..addProfile()
        ..setCurrentProfile(p.listProfiles().first);
    }
    tasks = p.getCurrentStorage().pendingData();
    globalTags = p.getCurrentStorage().tags();
    currentProfile = p.getCurrentProfile();
    for (var profile in p.listProfiles()) {
      profiles[profile] = p.getAlias(profile);
    }
    setState(() {});
  }

  Future<void> _addProfile() async {
    var dir = await getApplicationDocumentsDirectory();
    Profiles(dir).addProfile();
    profiles = {
      for (var profile in Profiles(dir).listProfiles())
        profile: Profiles(dir).getAlias(profile),
    };
    setState(() {});
  }

  Future<void> _selectProfile(String profile) async {
    var dir = await getApplicationDocumentsDirectory();
    Profiles(dir).setCurrentProfile(profile);
    currentProfile = Profiles(dir).getCurrentProfile();
    tasks = Profiles(dir).getCurrentStorage().pendingData();
    globalTags = Profiles(dir).getCurrentStorage().tags();
    setState(() {});
  }

  Future<void> _setAlias({String profile, String alias}) async {
    var dir = await getApplicationDocumentsDirectory();
    Profiles(dir).setAlias(profile: profile, alias: alias);
    profiles[profile] = Profiles(dir).getAlias(profile);
    setState(() {});
  }

  void _renameProfile(String profile) {
    var controller = TextEditingController(
      text: profiles[profile],
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        title: Text('Rename profile'),
        content: TextField(
          controller: controller,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _setAlias(profile: profile, alias: controller.text);
              Navigator.of(context).pop();
            },
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProfile(String profile) async {
    var dir = await getApplicationDocumentsDirectory();
    var p = Profiles(dir)..deleteProfile(profile);
    if (p.listProfiles().isEmpty) {
      p
        ..addProfile()
        ..setCurrentProfile(p.listProfiles().first);
      globalTags = p.getCurrentStorage().tags();
    }
    profiles = {
      for (var profile in p.listProfiles()) profile: p.getAlias(profile),
    };
    if (currentProfile == profile) {
      p.setCurrentProfile(profiles.keys.first);
      currentProfile = p.getCurrentProfile();
      tasks = p.getCurrentStorage().pendingData();
      globalTags = p.getCurrentStorage().tags();
    }
    setState(() {});
  }

  void _deleteProfileDialog(String profile) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        content: Text('Delete profile?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _deleteProfile(profile);
              Navigator.of(context).pop();
            },
            child: Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Future<void> _addTask(String description) async {
    var dir = await getApplicationDocumentsDirectory();
    var now = DateTime.now().toUtc();
    Profiles(dir).getCurrentStorage().mergeTask(
          Task(
            status: 'pending',
            uuid: Uuid().v1(),
            entry: now,
            description: description,
            modified: now,
          ),
        );
    tasks = Profiles(dir).getCurrentStorage().pendingData();
    setState(() {});
  }

  void _addTaskDialog() {
    var addTaskController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        title: Text('Add task'),
        content: TextField(
          autofocus: true,
          maxLines: null,
          controller: addTaskController,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _addTask(addTaskController.text);
              Navigator.of(context).pop();
            },
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }

  Future<void> _synchronize(BuildContext context) async {
    var dir = await getApplicationDocumentsDirectory();
    try {
      var header = await Profiles(dir).getCurrentStorage().synchronize();
      tasks = Profiles(dir).getCurrentStorage().pendingData();
      await _sortTasks();
      globalTags = Profiles(dir).getCurrentStorage().tags();
      setState(() {});
      // ignore: deprecated_member_use
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('${header['code']}: ${header['status']}'),
      ));
    } on Exception catch (e, trace) {
      showExceptionDialog(
        context: context,
        e: e,
        trace: trace,
      );
    }
  }

  void _toggleTagFilter(String tag) {
    if (selectedTags.contains(tag)) {
      selectedTags.remove(tag);
    } else {
      selectedTags.add(tag);
    }
    setState(() {});
  }

  Future<void> _refreshTasks() async {
    var dir = await getApplicationDocumentsDirectory();
    var p = Profiles(dir);
    if (p.listProfiles().isEmpty) {
      p
        ..addProfile()
        ..setCurrentProfile(p.listProfiles().first);
    }
    tasks = p.getCurrentStorage().pendingData();
    globalTags = p.getCurrentStorage().tags();
    setState(() {});
  }

  Future<void> _sortTasks() async {
    var dir = await getApplicationDocumentsDirectory();
    tasks = Profiles(dir).getCurrentStorage().pendingData();
    if (selectedSort != null) {
      var sortColumn = selectedSort.substring(0, selectedSort.length - 1);
      var ascending = selectedSort.endsWith('+');
      tasks.sort((a, b) {
        int result;
        switch (sortColumn) {
          case 'entry':
            result = a.entry.compareTo(b.entry);
            break;
          case 'due':
            if (a.due == null && b.due == null) {
              result = 0;
            } else if (a.due == null) {
              return 1;
            } else if (b.due == null) {
              return -1;
            } else {
              result = a.due.compareTo(b.due);
            }
            break;
          case 'priority':
            var compare = {'H': 2, 'M': 1, 'L': 0};
            result = (compare[a.priority] ?? -1)
                .compareTo(compare[b.priority] ?? -1);
            break;
          case 'tags':
            for (var i = 0;
                i < min(a.tags?.length ?? 0, b.tags?.length ?? 0);
                i++) {
              if (result == null || result == 0) {
                result = a.tags[i].compareTo(b.tags[i]);
              }
            }
            if (result == null || result == 0) {
              result = (a.tags?.length ?? 0).compareTo(b.tags?.length ?? 0);
            }
            break;
          default:
        }
        return ascending ? result : -result;
      });
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var listAlias = (profiles[currentProfile]?.isEmpty ?? true)
        ? currentProfile
        : profiles[currentProfile];
    return Scaffold(
      appBar: AppBar(
        title: Text(listAlias ?? ''),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () => _synchronize(context),
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
                        onPressed: _addProfile,
                      ),
                    ),
                    for (var profile in profiles.keys ?? [])
                      ExpansionTile(
                        key: PageStorageKey<String>('exp-$profile'),
                        leading: Radio<String>(
                          value: profile,
                          groupValue: currentProfile,
                          onChanged: _selectProfile,
                        ),
                        title: SingleChildScrollView(
                          key: PageStorageKey<String>('scroll-$profile'),
                          scrollDirection: Axis.horizontal,
                          child: Text(
                            (profiles[profile]?.isEmpty ?? true)
                                ? profile
                                : profiles[profile],
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
                            onTap: () => _renameProfile(profile),
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
                                    profile, profiles[profile]),
                              ),
                            ).then((_) => setState(() {})),
                          ),
                          ListTile(
                            leading: Padding(
                              padding: EdgeInsets.all(12),
                              child: Icon(Icons.delete),
                            ),
                            title: Text('Delete profile'),
                            onTap: () => _deleteProfileDialog(profile),
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
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Padding(
              padding: EdgeInsets.all(4),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (var sort in [
                    'entry',
                    'due',
                    'priority',
                    'tags',
                  ])
                    ChoiceChip(
                      label: Text(
                        (selectedSort?.startsWith(sort) ?? false)
                            ? selectedSort
                            : sort,
                        style: GoogleFonts.firaMono(),
                      ),
                      selected: selectedSort?.startsWith(sort) ?? false,
                      onSelected: (newValue) async {
                        if (selectedSort == '$sort+') {
                          selectedSort = '$sort-';
                        } else if (selectedSort == '$sort-') {
                          selectedSort = null;
                        } else {
                          selectedSort = '$sort+';
                        }
                        await _sortTasks();
                      },
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Scrollbar(
              child: ListView(
                children: [
                  if (tasks != null)
                    for (var task
                        in tasks.where((task) => task.status == 'pending'))
                      if (selectedTags.isEmpty ||
                          (task.tags != null &&
                              task.tags
                                  .toSet()
                                  .intersection(selectedTags)
                                  .isNotEmpty))
                        Card(
                          child: InkWell(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailRoute(task.uuid),
                              ),
                            ).then((_) => _refreshTasks()),
                            child: ListTile(
                              title: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Text(
                                  task.description,
                                  style: GoogleFonts.firaMono(),
                                ),
                              ),
                              subtitle: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Text(
                                        '${age(task.entry)} '
                                                '${(task.due != null) ? when(task.due) : ''} '
                                                '${task?.priority ?? ''} '
                                                '${task.tags?.join(' ') ?? ''}'
                                            .replaceAll(RegExp(r' +'), ' '),
                                        style: GoogleFonts.firaMono(),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${urgency(task)}',
                                    style: GoogleFonts.firaMono(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                ],
              ),
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
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    if (globalTags != null)
                      for (var tag in globalTags.entries)
                        FilterChip(
                          onSelected: (_) => _toggleTagFilter(tag.key),
                          label: Text(
                            '${selectedTags.contains(tag.key) ? '+' : '-'}'
                            '${tag.key}',
                            style: GoogleFonts.firaMono(),
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
        onPressed: _addTaskDialog,
        tooltip: 'Add task',
        child: Icon(Icons.add),
      ),
    );
  }
}
