# 💬 in_app_notification
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
   We recommend to place it in the `builder` of the `MaterialApp`.

   ```dart
    return MaterialApp(
      home: const HomePage(),
      builder: (context, child) => InAppNotification(
        safeAreaPadding: MediaQuery.of(context).viewPadding,
        minAlertHeight: 60.0,
        child: child,
      ),
    );
   ```

3. Get `InAppNotification` instance via `of()` method, and invoke `show()` method.
   
   ```dart
   InAppNotification.of(context).show(
       child: YourOwnWidget(),
       onTap: () => print('Notification tapped!'),
       duration: Duration(milliseconds: _duration),
   );
   ```

## 🗺 Roadmap / Known issue
- Null-safety migration
- Implementation for more gesture
  - Swipe horizontal
- Performance optimization
  - Currently `InAppNotification` is recommended to use in `builder` of `MaterialApp`, but it means create instance each time of routing.
- Animation improvement
  - So far, we have confirmed that using a Widget with a height higher than the `minAlertHeight ` specified for `InApp` will slightly break the animation.

## 💭 Have a question?
If you have a question or found issue, feel free to [create an issue](https://github.com/cb-cloud/flutter_in_app_notification/issues/new).
