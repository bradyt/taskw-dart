import 'package:flutter/material.dart';

import 'package:path_provider/path_provider.dart';

import 'package:taskw/taskw.dart';

import 'package:task/task.dart';

class ProfilesRoute extends StatefulWidget {
  @override
  _ProfilesRouteState createState() => _ProfilesRouteState();
}

class _ProfilesRouteState extends State<ProfilesRoute> {
  List<String> _profiles;

  @override
  void initState() {
    super.initState();
    getApplicationDocumentsDirectory().then((dir) {
      _profiles = Profiles(dir).listProfiles();
      setState(() {});
    });
  }

  void _addProfile() {
    getApplicationDocumentsDirectory().then((dir) {
      var profiles = Profiles(dir);
      profiles.addProfile();
      _profiles = profiles.listProfiles();
      setState(() {});
    });
  }

  void _selectProfile(String profile) {
    getApplicationDocumentsDirectory().then((dir) {
      Profiles(dir).setCurrentProfile(profile);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TaskListRoute(),
        ),
      ).then((_) => setState(() {}));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('profiles'),
      ),
      body: ListView(
        children: [
          for (var profile in (_profiles ?? []))
            Card(
              child: InkWell(
                onTap: () => _selectProfile(profile),
                child: ListTile(
                  title: Text(profile),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addProfile,
        tooltip: 'Add profile',
        child: Icon(Icons.add),
      ),
    );
  }
}
