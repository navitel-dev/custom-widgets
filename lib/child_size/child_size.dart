import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class ChildSize extends SingleChildRenderObjectWidget {
  final void Function(Size)? onChildSizeChanged;

  const ChildSize({
    Key? key,
    Widget? child,
    this.onChildSizeChanged,
  }) : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return ChildSizeRender()..onChildSizeChanged = onChildSizeChanged;
  }

  @override
  void updateRenderObject(BuildContext context, ChildSizeRender renderObject) {
    renderObject.onChildSizeChanged = onChildSizeChanged;
  }
}

class ChildSizeRender extends RenderBox
    with RenderObjectWithChildMixin<RenderBox> {
  ChildSizeRender({
    Widget? child,
    Function(Size)? onChildSizeChanged,
  }) : _onChildSizeChanged = onChildSizeChanged;

  Function(Size)? _onChildSizeChanged;
  Function(Size)? get onChildSizeChanged => _onChildSizeChanged;
  set onChildSizeChanged(Function(Size)? value) {
    if (_onChildSizeChanged != value) {
      _onChildSizeChanged = value;
      markNeedsLayout();
    }
  }

  var _lastSize = Size.zero;

  @override
  void performLayout() {
    final child = this.child;
    if (child != null) {
      child.layout(constraints, parentUsesSize: true);
      size = child.size;
    } else {
      size = constraints.smallest;
    }

    if (_lastSize != size) {
      _lastSize = size;
      _onChildSizeChanged?.call(_lastSize);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final child = this.child;
    if (child != null) {
      context.paintChild(child, offset);
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return child?.hitTest(result, position: position) == true;
  }
}
