import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:task/task.dart';

void main([List<String> args = const []]) {
  GoogleFonts.config.allowRuntimeFetching = false;

  LicenseRegistry.addLicense(() async* {
    var license = await rootBundle.loadString('google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });

  WidgetsFlutterBinding.ensureInitialized();

  Directory? testingDirectory;
  if (args.contains('flutter_driver_test')) {
    testingDirectory = Directory(
      '${Directory.systemTemp.path}/flutter_driver_test/${const Uuid().v1()}',
    )..createSync(recursive: true);
    stdout.writeln(testingDirectory);
    Directory(
      '${testingDirectory.path}/profiles/acae0462-6a34-11e4-8001-002590720087',
    ).createSync(recursive: true);
  }

  runApp(
    FutureBuilder<Directory>(
      future: getApplicationDocumentsDirectory(),
      builder: (context, snapshot) => (snapshot.hasData)
          ? ProfilesWidget(
              baseDirectory: testingDirectory ?? snapshot.data!,
              child: const TaskApp(),
            )
          : const Placeholder(),
    ),
  );
}

class TaskApp extends StatelessWidget {
  const TaskApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'task',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData.dark(),
      home: const TaskListRoute(),
    );
  }
}
