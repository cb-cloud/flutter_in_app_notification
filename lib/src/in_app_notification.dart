import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_notification/src/size_listenable_container.dart';

@visibleForTesting
const notificationShowingDuration = Duration(milliseconds: 350);

@visibleForTesting
const notificationHorizontalAnimationDuration = Duration(milliseconds: 350);

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
    Curve curve = Curves.ease,
    @visibleForTesting FutureOr Function()? notificationCreatedCallback,
  }) async {
    _state ??= context.findAncestorStateOfType<_InAppNotificationState>();

    assert(_state != null);

    await _state!.create(
      child: child,
      context: context,
      onTap: onTap,
      curve: curve,
    );
    if (kDebugMode) {
      await notificationCreatedCallback?.call();
    }
    _state!.show(duration: duration);
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
  double _verticalDragDistance = 0.0;
  double _horizontalDragDistance = 0.0;

  OverlayEntry? _overlay;
  late CurvedAnimation _animation;
  Animation? _horizontalAnimation;

  double get _currentVerticalPosition =>
      _animation.value * _notificationSize.height + _verticalDragDistance;
  double get _currentHorizontalPosition =>
      (_horizontalAnimation?.value ?? 0.0) + _horizontalDragDistance;

  late final AnimationController _controller =
      AnimationController(vsync: this, duration: notificationShowingDuration)
        ..addListener(_updateNotification);

  late final AnimationController _horizontalAnimationController =
      AnimationController(
          vsync: this, duration: notificationHorizontalAnimationDuration)
        ..addListener(_updateNotification);

  Size _notificationSize = Size.zero;
  Completer<Size> _notificationSizeCompleter = Completer();
  Size _screenSize = Size.zero;
  bool _isDismissedByHorizontalSwipe = false;

  @override
  void initState() {
    _animation = CurvedAnimation(parent: _controller, curve: Curves.ease);
    super.initState();
  }

  void _updateNotification() {
    _overlay?.markNeedsBuild();
  }

  Future<void> create({
    required Widget child,
    required BuildContext context,
    VoidCallback? onTap,
    Curve curve = Curves.ease,
  }) async {
    await dismiss(animationFrom: _isDismissedByHorizontalSwipe ? 0.0 : 1.0);

    _verticalDragDistance = 0.0;
    _horizontalDragDistance = 0.0;
    _onTap = onTap;
    _animation = CurvedAnimation(parent: _controller, curve: curve);
    _horizontalAnimation = null;

    _overlay = OverlayEntry(
      builder: (context) {
        if (_screenSize == Size.zero) {
          _screenSize = MediaQuery.of(context).size;
        }

        return Positioned(
          bottom: MediaQuery.of(context).size.height -
              MediaQuery.of(context).viewPadding.top -
              _currentVerticalPosition,
          left: _currentHorizontalPosition,
          width: MediaQuery.of(context).size.width,
          child: SizeListenableContainer(
            onSizeChanged: (size) => _notificationSizeCompleter.complete(size),
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
    Duration duration = const Duration(seconds: 10),
  }) async {
    _notificationSize = await _notificationSizeCompleter.future;

    _controller.forward(from: 0.0);

    if (duration.inMicroseconds == 0) return;
    _timer = Timer(duration, () => dismiss());
  }

  Future dismiss({double animationFrom = 1.0}) async {
    _timer?.cancel();

    if (_controller.status == AnimationStatus.completed) {
      await _controller.reverse(from: animationFrom);
    }

    _overlay?.remove();
    _overlay = null;
    _notificationSizeCompleter = Completer();
    _isDismissedByHorizontalSwipe = false;
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
    _verticalDragDistance = (_verticalDragDistance + details.delta.dy)
        .clamp(-_notificationSize.height, 0.0);
    _updateNotification();
  }

  void _onVerticalDragEnd(DragEndDetails details) async {
    final percentage =
        _currentVerticalPosition.abs() / _notificationSize.height;
    final velocity = details.velocity.pixelsPerSecond.dy * _screenSize.height;
    if (velocity <= -1.0) {
      await dismiss(animationFrom: percentage);
      return;
    }

    if (percentage >= 0.5) {
      if (_verticalDragDistance == 0.0) return;
      _verticalDragDistance = 0.0;
      _controller.forward(from: percentage);
    } else {
      dismiss(animationFrom: percentage);
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
              .chain(CurveTween(curve: Curves.easeOutCubic))
              .animate(_horizontalAnimationController);
      _horizontalDragDistance = 0.0;

      _isDismissedByHorizontalSwipe = true;
      await _horizontalAnimationController.forward(from: 0.0);
    } else {
      final endValue = 0.0;
      _horizontalAnimation =
          Tween(begin: _horizontalDragDistance, end: endValue)
              .chain(CurveTween(curve: Curves.easeOutCubic))
              .animate(_horizontalAnimationController);
      _horizontalDragDistance = 0.0;

      await _horizontalAnimationController.forward(from: 0.0);
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
