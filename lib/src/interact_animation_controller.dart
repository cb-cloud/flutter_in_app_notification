import 'package:flutter/material.dart';

final _defaultCurve = CurveTween(curve: Curves.easeOutCubic);

abstract class InteractnimationController {
  Animation<double>? currentAnimation;
  late double dragDistance;

  /// Animate to make the notification stay in screen.
  Future<void> stay();

  /// Animate to dismiss the notification.
  Future<void> dismiss({required double currentPosition});
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
  Future<void> dismiss({required double currentPosition}) async {
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
