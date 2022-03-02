import 'package:flutter/material.dart';

final _defaultCurve = CurveTween(curve: Curves.easeOutCubic);

abstract class InteractnimationController {
  Animation<double>? currentAnimation;
  late double dragDistance;

  /// Animate to make the notification stay in screen.
  Future<void> stay();

  /// Animate to dismiss the notification.
  Future<void> dismiss();
}

class VerticalInteractAnimationController extends AnimationController
    implements InteractnimationController {
  @override
  Animation<double>? currentAnimation;

  @override
  double dragDistance = 0.0;

  double _notificationHeight = 0.0;

  set notificationHeight(double value) => _notificationHeight = value;

  VerticalInteractAnimationController({
    required TickerProvider vsync,
    required Duration duration,
  }) : super(vsync: vsync, duration: duration);

  @override
  Future<void> dismiss({double currentPosition = 0.0}) async {
    currentAnimation = Tween(
      begin: currentPosition - _notificationHeight,
      end: -_notificationHeight,
    ).chain(_defaultCurve).animate(this);
    dragDistance = 0.0;

    await forward(from: 0.0);
    currentAnimation = null;
  }

  @override
  Future<void> stay() async {
    currentAnimation =
        Tween(begin: dragDistance, end: 0.0).chain(_defaultCurve).animate(this);

    dragDistance = 0.0;
    await forward(from: 0.0);
    currentAnimation = null;
  }
}

class HorizontalInteractAnimationController extends AnimationController
    implements InteractnimationController {
  @override
  Animation<double>? currentAnimation;

  @override
  double dragDistance = 0.0;

  double _screenWidth = 0.0;

  set screenWidth(double value) => _screenWidth = value;

  HorizontalInteractAnimationController({
    required TickerProvider vsync,
    required Duration duration,
  }) : super(vsync: vsync, duration: duration);

  @override
  Future<void> dismiss() async {
    final endValue = dragDistance.sign * _screenWidth;
    currentAnimation = Tween(begin: dragDistance, end: endValue)
        .chain(_defaultCurve)
        .animate(this);
    dragDistance = 0.0;

    await forward(from: 0.0);
    currentAnimation = null;
  }

  @override
  Future<void> stay() async {
    currentAnimation =
        Tween(begin: dragDistance, end: 0.0).chain(_defaultCurve).animate(this);
    dragDistance = 0.0;

    await forward(from: 0.0);
    currentAnimation = null;
  }
}
