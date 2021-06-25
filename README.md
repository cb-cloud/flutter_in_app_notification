# 💬 in_app_notification
[![pub package](https://img.shields.io/pub/v/in_app_notification.svg)](https://pub.dev/packages/in_app_notification)

A Flutter package to show custom in-app notification with any Widgets.

<p align="center">
<image src="https://raw.githubusercontent.com/wiki/cb-cloud/flutter_in_app_notification/assets/doc/top.gif"/>
</p>

## ✍️ Usage

1. Import it.
    ```yaml
    dependencies:
        in_app_notification: <latest-version>
    ```

    ```dart
    import 'package:in_app_notification/in_app_notification.dart';
    ```
2. Place `InAppNotification` Widget into your app.

   ```dart
    return InAppNotification(
      child: MaterialApp(
        title: 'In-App Notification Demo',
        home: const HomePage(),
      ),
    );
   ```

3. Invoke `show()` static method of `InAppNotification`.
   
   ```dart
   InAppNotification.show(
     child: NotificationBody(count: _count),
     context: context,
     onTap: () => print('Notification tapped!'),
   );
   ```

## 🗺 Roadmap / Known issue
See [Discussions](https://github.com/cb-cloud/flutter_in_app_notification/discussions).
If you have some idea or proposal, feel free to [create new one](https://github.com/cb-cloud/flutter_in_app_notification/discussions/new).

## 💭 Have a question?
If you have a question or found issue, feel free to [create an issue](https://github.com/cb-cloud/flutter_in_app_notification/issues/new).
