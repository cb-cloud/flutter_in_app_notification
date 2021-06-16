// ignore_for_file: missing_return

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_notification/in_app_notification.dart';
import 'package:in_app_notification/src/size_listenable_container.dart';

void main() {
  Widget base(Key key) => MaterialApp(
        home: InAppNotification(
          child: Scaffold(
            key: key,
            body: SizedBox(height: 400, width: 400),
          ),
        ),
      );

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('SizeListenableContainer test.', (tester) async {
    await tester.runAsync(() async {
      var widgetSize = Size.zero;
      await tester.pumpWidget(
        SizeListenableContainer(
          onSizeChanged: (size) {
            widgetSize = size;
          },
          child: SizedBox.expand(),
        ),
      );

      expect(find.byType(SizeListenableContainer), findsOneWidget);
      expect(widgetSize, Size(800, 600));
    });
  });

  testWidgets(
    'InAppNotification should show specified Widget on called `show` method.',
    (tester) async {
      await tester.runAsync(() async {
        final key = GlobalKey();
        await tester.pumpWidget(base(key));

        final context = key.currentContext!;

        await InAppNotification.show(
          child: Center(child: Text('foo')),
          context: context,
          onTap: () {},
          duration: Duration(seconds: 2),
          notificationCreatedCallback: () async => await tester.pumpAndSettle(),
        );
        expect(find.text('foo'), findsOneWidget);
      });
    },
  );

  testWidgets(
    'InAppNotification should dismiss on tap notification and execute callback.',
    (tester) async {
      await tester.runAsync(() async {
        var tapped = false;

        final key = GlobalKey();
        await tester.pumpWidget(base(key));

        final context = key.currentContext!;

        await InAppNotification.show(
          child: Center(child: Text('foo')),
          context: context,
          onTap: () => tapped = true,
          duration: Duration(seconds: 2),
          notificationCreatedCallback: () async => await tester.pumpAndSettle(),
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
