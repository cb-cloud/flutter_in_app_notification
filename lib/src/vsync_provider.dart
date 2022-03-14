part of 'in_app_notification.dart';

class _VsyncProvider extends StatefulWidget {
  const _VsyncProvider({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  State<_VsyncProvider> createState() => __VsyncProviderState();
}

class __VsyncProviderState extends State<_VsyncProvider>
    with TickerProviderStateMixin {
  late final _showController = AnimationController(
    vsync: this,
    duration: notificationShowingDuration,
  );

  late final _verticalAnimationController = VerticalInteractAnimationController(
    vsync: this,
    duration: notificationShowingDuration,
  );

  late final _horizontalAnimationController =
      HorizontalInteractAnimationController(
    vsync: this,
    duration: notificationHorizontalAnimationDuration,
  );

  @override
  Widget build(BuildContext context) {
    return _NotificationController(
      state: _NotificationState(
        showController: _showController,
        verticalAnimationController: _verticalAnimationController,
        horizontalAnimationController: _horizontalAnimationController,
      ),
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _showController.dispose();
    _verticalAnimationController.dispose();
    _horizontalAnimationController.dispose();
    super.dispose();
  }
}
