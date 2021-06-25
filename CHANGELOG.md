## 1.0.1
### FIX
- Fixed a bug that the notification doesn't apppear when swiping previous one.

## 1.0.0
### FEAT
- Added horizontal swipe gesture to dismiss notifications.
- Now, using cache of `InAppNotification`'s state. This makes it possible to decrease overhead on showing notification.

## 0.3.0
### FEAT
- **BREAKING: Overall, changes API.**
  - Removed `InAppNotification.of()`. To show notificaiton, use `InAppNotification.show()` instead.
  - Changed usage of `InAppNotification`, see Usage section in README.
- Replaced `Stack` with `OverlayEntry` on showing notification sysytem.
- Removed `minAlertHeight` property. Notification size is decided from specified Widget now.
- Removed `safeAreaPadding` property. Notification position is now considering safe area automatically.
- Added `curve` property to `InAppNotification.show()` method.

## 0.2.0+1
Organize documents.

## 0.2.0
**BREAKING: Migrate to sound null safety.**

### CHORE
- Changed description.
- Added pub.dev badge to README.

## 0.1.0
First release.
