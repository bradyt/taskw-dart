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
  List<String> profiles;
  String currentProfile;
  Map<String, String> aliases;

  @override
  void initState() {
    super.initState();
    aliases = {};
    getApplicationDocumentsDirectory().then((dir) {
      var p = Profiles(dir);
      if (p.listProfiles().isEmpty) {
        p.addProfile();
        p.setCurrentProfile(p.listProfiles().first);
      }
      tasks = p.getCurrentStorage().listTasks();
      profiles = p.listProfiles();
      currentProfile = p.getCurrentProfile();
      for (var profile in profiles) {
        aliases[profile] = p.getAlias(profile);
      }
      setState(() {});
    });
  }

  void _addProfile() {
    getApplicationDocumentsDirectory().then((dir) {
      Profiles(dir).addProfile();
      profiles = Profiles(dir).listProfiles();
      setState(() {});
    });
  }

  void _selectProfile(String profile) {
    getApplicationDocumentsDirectory().then((dir) {
      Profiles(dir).setCurrentProfile(profile);
      tasks = Profiles(dir).getCurrentStorage().listTasks();
      currentProfile = Profiles(dir).getCurrentProfile();
      setState(() {});
    });
  }

  void _renameProfile(String profile) {
    var controller = TextEditingController();
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
                p.renameProfile(
                  profile: profile,
                  alias: controller.text,
                );
                aliases[profile] = p.getAlias(profile);
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
                profiles = p.listProfiles();
                if (currentProfile == profile) {
                  p.setCurrentProfile(profiles.first);
                  currentProfile = p.getCurrentProfile();
                  tasks = p.getCurrentStorage().listTasks();
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
                Profiles(dir).getCurrentStorage().addTask(
                      Task(
                        status: 'pending',
                        uuid: Uuid().v1(),
                        entry: DateTime.now().toUtc(),
                        description: addTaskController.text,
                      ),
                    );
                tasks = Profiles(dir).getCurrentStorage().listTasks();
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
    return Scaffold(
      appBar: AppBar(
        title: Text('task list'),
      ),
      drawer: Drawer(
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
            for (var profile in (profiles ?? []))
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
                    (aliases[profile]?.isEmpty ?? true)
                        ? profile
                        : aliases[profile],
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
      body: ListView(
        children: [
          if (tasks != null)
            for (var task in tasks)
              Card(
                child: InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailRoute(task),
                    ),
                  ).then((_) => setState(() {})),
                  child: ListTile(
                    title: Text('${task.description}'),
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
