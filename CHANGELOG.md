## 1.1.2
### FIX
- Prevent some `Completer` error.
  - When the size of a notification was changed unexpectedly, a `Future already completed.` error could occur.

## 1.1.1
### FIX
- Fixed warnings for Flutter3.0.0 
  - Wrapped code containing warnings in `_ambiguate()`

## 1.1.0
### FEAT
- Added `InAppNotification.dismiss()` method that hides notification programmatically.
  - from #14 .

### CHORE
- Refactored again.
  - Get rid of `StatefulWidget`, using `findAncestorStateOfType()` method.
    - This is expensive when using `BuildContext` that obtained from deep hierarchy of Widget tree, so it replaced with `getElementForInheritedWidgetOfExactType()` method on `InheritedWidget`.

## 1.0.2
### FIX
- Fixed a bug that `curve` option in `InAppNotification.show()` didn't affect.

### FEAT
- Added `dismissCurve` option in `InAppNotification.show()`.
### CHORE
- Refactored a whole of code.
  - More readable logic around showing and dismissing notification.
  - Isolated `AnimationController` for interactions from one for showing.
- Expanded example app to change sample notification size.

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
