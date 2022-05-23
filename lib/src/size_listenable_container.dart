import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

// reference: https://qiita.com/najeira/items/0ff716971184042b1434

T? _ambiguate<T>(T? value) => value;

typedef SizeChangedCallback = void Function(Size size);

class SizeListenableContainer extends SingleChildRenderObjectWidget {
  const SizeListenableContainer({
    Key? key,
    required Widget child,
    required this.onSizeChanged,
  }) : super(key: key, child: child);

  final SizeChangedCallback onSizeChanged;

  @override
  _SizeListenableRenderObject createRenderObject(BuildContext context) {
    return _SizeListenableRenderObject(onSizeChanged: onSizeChanged);
  }
}

class _SizeListenableRenderObject extends RenderProxyBox {
  _SizeListenableRenderObject({
    RenderBox? child,
    required this.onSizeChanged,
  }) : super(child);

  final SizeChangedCallback onSizeChanged;

  Size? _oldSize;

  @override
  void performLayout() {
    super.performLayout();

    if (size != _oldSize) {
      _oldSize = size;
      _callback(size);
    }
  }

  void _callback(Size size) {
    _ambiguate(SchedulerBinding.instance)!.addPostFrameCallback((_) {
      onSizeChanged(size);
    });
  }
}
