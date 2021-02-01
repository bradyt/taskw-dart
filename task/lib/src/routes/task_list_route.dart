import 'dart:io';

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

  @override
  void initState() {
    super.initState();
    profiles = {};
    getApplicationDocumentsDirectory().then((dir) {
      var p = Profiles(dir);
      if (p.listProfiles().isEmpty) {
        p.addProfile();
        p.setCurrentProfile(p.listProfiles().first);
      }
      tasks = p.getCurrentStorage().next();
      currentProfile = p.getCurrentProfile();
      for (var profile in p.listProfiles()) {
        profiles[profile] = p.getAlias(profile);
      }
      setState(() {});
    });
  }

  void _addProfile() {
    getApplicationDocumentsDirectory().then((dir) {
      Profiles(dir).addProfile();
      profiles = {
        for (var profile in Profiles(dir).listProfiles())
          profile: Profiles(dir).getAlias(profile),
      };
      setState(() {});
    });
  }

  void _selectProfile(String profile) {
    getApplicationDocumentsDirectory().then((dir) {
      Profiles(dir).setCurrentProfile(profile);
      tasks = Profiles(dir).getCurrentStorage().next();
      currentProfile = Profiles(dir).getCurrentProfile();
      setState(() {});
    });
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
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            child: Text('Submit'),
            onPressed: () {
              getApplicationDocumentsDirectory().then((dir) {
                var p = Profiles(dir);
                p.setAlias(
                  profile: profile,
                  alias: controller.text,
                );
                profiles[profile] = p.getAlias(profile);
                setState(() {});
                Navigator.of(context).pop();
              });
            },
          ),
        ],
      ),
    );
  }

  void _deleteProfile(String profile) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        content: Text('Delete profile?'),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            child: Text('Confirm'),
            onPressed: () async {
              getApplicationDocumentsDirectory().then((dir) {
                var p = Profiles(dir);
                p.deleteProfile(profile);
                if (p.listProfiles().isEmpty) {
                  p.addProfile();
                  p.setCurrentProfile(p.listProfiles().first);
                }
                profiles = {
                  for (var profile in p.listProfiles())
                    profile: p.getAlias(profile),
                };
                if (currentProfile == profile) {
                  p.setCurrentProfile(profiles.keys.first);
                  currentProfile = p.getCurrentProfile();
                  tasks = p.getCurrentStorage().next();
                }
                setState(() {});
              });
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _addTask() {
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
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            child: Text('Submit'),
            onPressed: () {
              getApplicationDocumentsDirectory().then((dir) {
                var now = DateTime.now().toUtc();
                Profiles(dir).getCurrentStorage().mergeTask(
                      Task(
                        status: 'pending',
                        uuid: Uuid().v1(),
                        entry: now,
                        description: addTaskController.text,
                        modified: now,
                      ),
                    );
                tasks = Profiles(dir).getCurrentStorage().next();
                setState(() {});
                Navigator.of(context).pop();
              });
            },
          ),
        ],
      ),
    );
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
              onPressed: () {
                getApplicationDocumentsDirectory().then(
                  (dir) async {
                    try {
                      var header =
                          await Profiles(dir).getCurrentStorage().synchronize();
                      tasks = Profiles(dir).getCurrentStorage().next();
                      setState(() {});
                      Scaffold.of(context).showSnackBar(SnackBar(
                        content: Text('${header['code']}: ${header['status']}'),
                      ));
                    } catch (e, trace) {
                      showExceptionDialog(
                        context: context,
                        e: e,
                        trace: trace,
                      );
                    }
                  },
                );
              },
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
                    for (var profile in (profiles.keys ?? []))
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
                            onTap: () => _deleteProfile(profile),
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
      body: ListView(
        children: [
          if (tasks != null)
            for (var task in tasks)
              Card(
                child: InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailRoute(task.uuid),
                    ),
                  ).then((_) {
                    getApplicationDocumentsDirectory().then((dir) {
                      var p = Profiles(dir);
                      if (p.listProfiles().isEmpty) {
                        p.addProfile();
                        p.setCurrentProfile(p.listProfiles().first);
                      }
                      tasks = p.getCurrentStorage().next();
                      setState(() {});
                    });
                  }),
                  child: ListTile(
                    title: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        '${task.description}',
                        style: GoogleFonts.firaMono(),
                      ),
                    ),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        tooltip: 'Add task',
        child: Icon(Icons.add),
      ),
    );
  }
}
