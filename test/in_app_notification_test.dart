// ignore_for_file: missing_return

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_notification/in_app_notification.dart';

void main() {
  Widget base(Key key) => MaterialApp(
        home: InAppNotification(
          key: key,
          safeAreaPadding: const EdgeInsets.all(0),
          child: Scaffold(
            body: SizedBox(height: 400, width: 400),
          ),
          minAlertHeight: 120.0,
        ),
      );

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets(
    'InAppNotification should show specified Widget on called `show` method.',
    (tester) async {
      await tester.runAsync(() async {
        final notificationKey = GlobalKey<InAppNotificationState>();
        await tester.pumpWidget(base(notificationKey));

        await notificationKey.currentState?.show(
          child: Center(child: Text('foo')),
          onTap: () {},
          duration: Duration(seconds: 2),
        );

        await tester.pumpAndSettle();
        expect(find.text('foo'), findsOneWidget);
      });
    },
  );

  testWidgets(
    'InAppNotification should dismiss on tap notification and execute callback.',
    (tester) async {
      await tester.runAsync(() async {
        var tapped = false;

        final notificationKey = GlobalKey<InAppNotificationState>();
        await tester.pumpWidget(base(notificationKey));

        await notificationKey.currentState?.show(
          child: Center(child: Text('foo')),
          onTap: () => tapped = true,
          duration: Duration(seconds: 2),
        );

        await tester.pumpAndSettle();
        await tester.tap(find.text('foo'));

        await tester.pumpAndSettle();

        expect(tapped, isTrue);
        expect(find.text('foo'), findsNothing);
      });
    },
  );
}
