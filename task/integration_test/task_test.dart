import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:path_provider/path_provider.dart';

import 'package:taskw/taskw.dart';

import 'package:task/main.dart' as taskApp;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('tap on the floating action button; verify profile',
        (WidgetTester tester) async {
      taskApp.main();
      await tester.pumpAndSettle();

      // Finds the floating action button to tap on.
      final Finder fab = find.byTooltip('Add profile');

      // Emulate a tap on the floating action button.
      await tester.tap(fab);

      await tester.pumpAndSettle();

      var dir = await getApplicationDocumentsDirectory();
      var profiles = Profiles(dir).listProfiles();

      expect(find.text(profiles.first), findsOneWidget);
    });
  });
}
