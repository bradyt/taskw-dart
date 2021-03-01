import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('Counter App', () {
    var drawerFinder = find.byTooltip('Open navigation menu');

    late FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      await driver.close();
    });

    test('take a screenshot', () async {
      await driver.waitFor(drawerFinder);
      Directory('screenshots').createSync(recursive: true);
      File('screenshots/1.png').writeAsBytesSync(
        await driver.screenshot(),
      );
    });
  });
}
