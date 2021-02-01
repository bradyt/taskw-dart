import 'package:flutter/material.dart';

import 'package:path_provider/path_provider.dart';

import 'package:taskw/taskw.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'task',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData.dark(),
      home: MyHomePage(title: 'profiles'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(
        children: [
          for (var profile in (_profiles ?? []))
            Card(
              child: ListTile(
                title: Text(profile),
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
