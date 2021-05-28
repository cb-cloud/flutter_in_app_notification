import 'dart:async';

import 'package:flutter/material.dart';

/// A widget for display foreground notification.
///
/// It is mainly intended to be inserted in the `builder` of [WidgetsApp].
///
/// {@tool snippet}
/// Usage example:
///
/// ```dart
/// return MaterialApp(
///   home: Home(),
///   builder: (context, child) => AlertNotification(
///     safeAreaPadding: MediaQuery.of(context).viewPadding,
///     child: child,
///   ),
/// );
/// ```
/// {@end-tool}
///
/// Showing and hiding notifications is managed by animation,
/// and the process is as follows.
///
/// 1. Execute `show` method, start animation.
/// 2. After the notification appears at the specified time,
///    it is displayed for the specified `duration`.
/// 3. After the `duration` has elapsed,
///    play the animation in reverse and dispose the notification.
class InAppNotification extends StatefulWidget {
  /// Creates an in-app notification system.
  ///
  /// The [safeAreaPadding] must not be null.
  const InAppNotification({
    Key key,
    @required this.safeAreaPadding,
    this.minAlertHeight = 120.0,
    this.child,
  })  : assert(safeAreaPadding != null),
        super(key: key);

  final Widget child;

  /// The value of padding for something that narrows the view port,
  /// like The Notch on the iPhone X family.
  ///
  /// Usually, this would be `viewPadding` of `MediaQueryData`.
  final EdgeInsets safeAreaPadding;

  /// The value at minimal height of notification.
  ///
  /// The default value is 120.0.
  final double minAlertHeight;

  static InAppNotificationState of(BuildContext context) =>
      context.findAncestorStateOfType<InAppNotificationState>();

  @override
  InAppNotificationState createState() => InAppNotificationState();
}

class InAppNotificationState extends State<InAppNotification>
    with SingleTickerProviderStateMixin {
  Widget _body;
  VoidCallback _onTap;
  AnimationController _controller;
  Timer _timer;
  Animation<double> _alertAnimation;
  double _initialPosition = 0.0;
  double _dragDistance = 0.0;

  double get _currentPosition => _alertAnimation.value + _dragDistance;

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 350));
    final curve = CurvedAnimation(parent: _controller, curve: Curves.ease);
    _initialPosition = -widget.minAlertHeight - widget.safeAreaPadding.top;
    _alertAnimation = Tween(begin: _initialPosition, end: 0.0).animate(curve);
    super.initState();
  }

  void show({
    @required Widget child,
    VoidCallback onTap,
    Duration duration = const Duration(seconds: 10),
  }) async {
    _timer?.cancel();

    if (_controller.isCompleted) {
      await dismiss();
    }

    setState(() {
      _dragDistance = 0.0;
      _body = child;
      _onTap = onTap;
    });
    _controller?.forward(from: 0.0);

    if (duration?.inMicroseconds == 0) return;
    _timer = Timer(duration, () => dismiss());
  }

  Future dismiss({double from}) async {
    _timer?.cancel();
    await _controller?.reverse(from: from ?? 1.0);
    setState(() => _body = null);
  }

  void _onTapNotification() {
    if (_onTap == null) return;

    dismiss();
    _onTap();
  }

  void _onTapDown() {
    _timer?.cancel();
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragDistance =
          (_dragDistance + details.delta.dy).clamp(_initialPosition, 0.0);
    });
  }

  void _onVerticalDragEnd() {
    final percentage = 1.0 - _currentPosition.abs() / _initialPosition.abs();
    if (percentage >= 0.4) {
      if (_dragDistance == 0.0) return;
      setState(() {
        _dragDistance = 0.0;
      });
      _controller?.forward(from: percentage);
    } else {
      dismiss(from: percentage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        AnimatedBuilder(
          animation: _alertAnimation,
          builder: (context, _) {
            return Positioned(
              top: _currentPosition,
              width: MediaQuery.of(context).size.width,
              child: GestureDetector(
                onTapDown: (detail) => _onTapDown(),
                onVerticalDragUpdate: _onVerticalDragUpdate,
                onVerticalDragEnd: (detail) => _onVerticalDragEnd(),
                onTapUp: (_) => _onTapNotification(),
                child: Padding(
                  padding: EdgeInsets.only(top: widget.safeAreaPadding.top),
                  child: Material(
                    color: Colors.transparent,
                    child: _body ?? SizedBox.shrink(),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
