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
     duration: Duration(milliseconds: _duration),
   );
   ```

## 🗺 Roadmap / Known issue
- ~~Null-safety migration~~ ✅
- Implementation for more gesture
  - Swipe horizontal
- Performance optimization
  - ~~Currently `InAppNotification` is recommended to use in `builder` of `MaterialApp`, but it means create instance each time of routing.~~ ✅
- Animation improvement
  - ~~So far, we have confirmed that using a Widget with a height higher than the `minAlertHeight ` specified for `InApp` will slightly break the animation.~~ ✅

## 💭 Have a question?
If you have a question or found issue, feel free to [create an issue](https://github.com/cb-cloud/flutter_in_app_notification/issues/new).
