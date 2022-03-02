import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_notification/src/interact_animation_controller.dart';
import 'package:in_app_notification/src/size_listenable_container.dart';

@visibleForTesting
const notificationShowingDuration = Duration(milliseconds: 350);

@visibleForTesting
const notificationHorizontalAnimationDuration = Duration(milliseconds: 350);

final _defaultCurve = CurveTween(curve: Curves.easeOutCubic);

/// A widget for display foreground notification.
///
/// It is mainly intended to wrap whole your app Widgets.
/// e.g. Just wrapping [MaterialApp].
///
/// {@tool snippet}
/// Usage example:
///
/// ```dart
/// return InAppNotification(
///   child: MaterialApp(
///     title: 'In-App Notification Demo',
///     home: const HomePage(),
///   ),
/// );
/// ```
/// {@end-tool}
class InAppNotification extends StatefulWidget {
  /// Creates an in-app notification system.
  const InAppNotification({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  static _InAppNotificationState? _state;

  /// Shows specified Widget as notification.
  ///
  /// [child] is required, this will be displayed as notification body.
  /// [context] is required, this is used to get Navigator instance.
  ///
  /// Showing and hiding notifications is managed by animation,
  /// and the process is as follows.
  ///
  /// 1. Execute this method, start animation via call state's `show` method
  ///    internally.
  /// 2. Then the notification appear, it will stay at specified [duration].
  /// 3. After the [duration] has elapsed,
  ///    play the animation in reverse and dispose the notification.
  static FutureOr<void> show({
    required Widget child,
    required BuildContext context,
    VoidCallback? onTap,
    Duration duration = const Duration(seconds: 10),
    Curve curve = Curves.easeOutCubic,
    Curve dismissCurve = Curves.easeOutCubic,
    @visibleForTesting FutureOr Function()? notificationCreatedCallback,
  }) async {
    _state ??= context.findAncestorStateOfType<_InAppNotificationState>();

    assert(_state != null);

    await _state!.create(
      child: child,
      context: context,
      onTap: onTap,
    );
    if (kDebugMode) {
      await notificationCreatedCallback?.call();
    }
    _state!.show(duration: duration, curve: curve, dismissCurve: dismissCurve);
  }

  @visibleForTesting
  static void clearStateCache() {
    _state = null;
  }

  @override
  _InAppNotificationState createState() => _InAppNotificationState();
}

class _InAppNotificationState extends State<InAppNotification>
    with TickerProviderStateMixin {
  VoidCallback? _onTap;
  Timer? _timer;
  double _horizontalDragDistance = 0.0;

  OverlayEntry? _overlay;
  Animation<double>? _showAnimation;
  Animation? _horizontalAnimation;

  double get _currentVerticalPosition =>
      (_showAnimation?.value ?? 0.0) +
      (_verticalAnimation?.value ?? 0.0) +
      _verticalAnimationController.dragDistance;
  double get _currentHorizontalPosition =>
      (_horizontalAnimation?.value ?? 0.0) + _horizontalDragDistance;

  late final AnimationController _controller =
      AnimationController(vsync: this, duration: notificationShowingDuration)
        ..addListener(_updateNotification);

  late final VerticalInteractAnimationController _verticalAnimationController =
      VerticalInteractAnimationController(
          vsync: this, duration: notificationShowingDuration)
        ..addListener(_updateNotification);
  Animation<double>? get _verticalAnimation =>
      _verticalAnimationController.currentAnimation;

  late final AnimationController _horizontalAnimationController =
      AnimationController(
          vsync: this, duration: notificationHorizontalAnimationDuration)
        ..addListener(_updateNotification);

  Size _notificationSize = Size.zero;
  Completer<Size> _notificationSizeCompleter = Completer();
  Size _screenSize = Size.zero;

  void _updateNotification() {
    _overlay?.markNeedsBuild();
  }

  Future<void> create({
    required Widget child,
    required BuildContext context,
    VoidCallback? onTap,
  }) async {
    await dismiss(shouldAnimation: !_controller.isDismissed);

    _verticalAnimationController.dragDistance = 0.0;
    _horizontalDragDistance = 0.0;
    _onTap = onTap;
    _horizontalAnimation = null;

    _overlay = OverlayEntry(
      builder: (context) {
        if (_screenSize == Size.zero) {
          _screenSize = MediaQuery.of(context).size;
        }

        return Positioned(
          bottom: _screenSize.height - _currentVerticalPosition,
          left: _currentHorizontalPosition,
          width: _screenSize.width,
          child: SizeListenableContainer(
            onSizeChanged: (size) {
              final topPadding = MediaQuery.of(context).viewPadding.top;
              _notificationSizeCompleter.complete(size + Offset(0, topPadding));
            },
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _onTapNotification,
              onTapDown: (_) => _onTapDown(),
              onVerticalDragUpdate: _onVerticalDragUpdate,
              onVerticalDragEnd: _onVerticalDragEnd,
              onHorizontalDragUpdate: _onHorizontalDragUpdate,
              onHorizontalDragEnd: _onHorizontalDragEnd,
              child: Material(color: Colors.transparent, child: child),
            ),
          ),
        );
      },
    );

    Navigator.of(context).overlay?.insert(_overlay!);
  }

  Future<void> show({
    required Duration duration,
    required Curve curve,
    required Curve dismissCurve,
  }) async {
    final size = await _notificationSizeCompleter.future;
    final isSizeChanged = _notificationSize != size;
    _notificationSize = size;
    _verticalAnimationController.notificationHeight = _notificationSize.height;

    if (isSizeChanged) {
      _showAnimation = Tween(
        begin: 0.0,
        end: _notificationSize.height,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: curve,
          reverseCurve: dismissCurve,
        ),
      );
    }

    await _controller.forward(from: 0.0);

    if (duration.inMicroseconds == 0) return;
    _timer = Timer(duration, () => dismiss());
  }

  Future<void> dismiss({bool shouldAnimation = true}) async {
    _timer?.cancel();

    await _controller.reverse(from: shouldAnimation ? 1.0 : 0.0);

    _overlay?.remove();
    _overlay = null;
    _notificationSizeCompleter = Completer();
  }

  void _onTapNotification() {
    if (_onTap == null) return;

    dismiss();
    _onTap!();
  }

  void _onTapDown() {
    _timer?.cancel();
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    _verticalAnimationController.dragDistance =
        (_verticalAnimationController.dragDistance + details.delta.dy)
            .clamp(-_notificationSize.height, 0.0);
    _updateNotification();
  }

  void _onVerticalDragEnd(DragEndDetails details) async {
    final percentage =
        _currentVerticalPosition.abs() / _notificationSize.height;
    final velocity = details.velocity.pixelsPerSecond.dy * _screenSize.height;
    if (velocity <= -1.0) {
      await _verticalAnimationController.dismiss(
          currentPosition: _currentVerticalPosition);
      await dismiss(shouldAnimation: false);
      return;
    }

    if (percentage >= 0.5) {
      if (_verticalAnimationController.dragDistance == 0.0) return;
      await _verticalAnimationController.stay();
    } else {
      await _verticalAnimationController.dismiss(
          currentPosition: _currentVerticalPosition);
      await dismiss(shouldAnimation: false);
    }
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    _horizontalDragDistance += details.delta.dx;
    _updateNotification();
  }

  void _onHorizontalDragEnd(DragEndDetails details) async {
    final velocity = details.velocity.pixelsPerSecond.dx / _screenSize.width;
    final position = _horizontalDragDistance / _screenSize.width;

    if (velocity.abs() >= 1.0 || position.abs() >= 0.2) {
      final endValue = _horizontalDragDistance.sign * _screenSize.width;
      _horizontalAnimation =
          Tween(begin: _horizontalDragDistance, end: endValue)
              .chain(_defaultCurve)
              .animate(_horizontalAnimationController);
      _horizontalDragDistance = 0.0;

      await _horizontalAnimationController.forward(from: 0.0);
      _horizontalAnimation = null;
      dismiss(shouldAnimation: false);
    } else {
      final endValue = 0.0;
      _horizontalAnimation =
          Tween(begin: _horizontalDragDistance, end: endValue)
              .chain(_defaultCurve)
              .animate(_horizontalAnimationController);
      _horizontalDragDistance = 0.0;

      await _horizontalAnimationController.forward(from: 0.0);
      _horizontalAnimation = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void dispose() {
    _controller.dispose();
    _horizontalAnimationController.dispose();
    super.dispose();
  }
}
