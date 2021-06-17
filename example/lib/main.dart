import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:in_app_notification/in_app_notification.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InAppNotification(
      child: MaterialApp(
        title: 'In-App Notification Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _count = 0;
  int _duration = 3000;

  void _incrementCount() => setState(() => _count++);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('In-App Notification Demo')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Current count: $_count'),
            const SizedBox(height: 32),
            Text('Duration: $_duration ms'),
            const SizedBox(height: 16),
            Slider.adaptive(
              value: _duration.toDouble(),
              onChanged: (value) => setState(() => _duration = value.toInt()),
              min: 500,
              max: 5000,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                _incrementCount();
                InAppNotification.show(
                  child: NotificationBody(count: _count),
                  context: context,
                  onTap: () => print('Notification tapped!'),
                  duration: Duration(milliseconds: _duration),
                );
              },
              child: Text('Show Notification'),
            )
          ],
        ),
      ),
    );
  }
}

/// An example of notification Widget.
///
/// Please replace this into your own Widget.
class NotificationBody extends StatelessWidget {
  final int count;

  NotificationBody({
    Key? key,
    this.count = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 12,
              blurRadius: 16,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.lightGreen.withOpacity(0.4),
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(
                  width: 1.4,
                  color: Colors.lightGreen.withOpacity(0.2),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    'Count: $count',
                    style: Theme.of(context)
                        .textTheme
                        .headline4!
                        .copyWith(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
