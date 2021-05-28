import 'package:flutter/material.dart';
import 'package:in_app_notification/in_app_notification.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  const App({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'In-App Notification Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomePage(),
      builder: (context, child) => InAppNotification(
        safeAreaPadding: MediaQuery.of(context).viewPadding,
        minAlertHeight: 60.0,
        child: child,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _count = 0;

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
            ElevatedButton(
              onPressed: () {
                _incrementCount();
                InAppNotification.of(context).show(
                  child: NotificationBody(count: _count),
                  onTap: () => print('Notification tapped!'),
                  duration: const Duration(seconds: 3),
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

class NotificationBody extends StatelessWidget {
  final int count;

  NotificationBody({
    Key key,
    this.count = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              spreadRadius: 8,
              blurRadius: 16,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              'Count: $count',
              style: Theme.of(context).textTheme.headline4,
            ),
          ),
        ),
      ),
    );
  }
}
