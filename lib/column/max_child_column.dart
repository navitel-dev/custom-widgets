import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class MaxChildColumn extends MultiChildRenderObjectWidget {
  MaxChildColumn({
    super.key,
    super.children,
    this.mainAxisSize = MainAxisSize.max,
    this.mainAxisAlignment = MainAxisAlignment.end,
  });

  final MainAxisSize mainAxisSize;
  final MainAxisAlignment mainAxisAlignment;

  @override
  MaxChildColumnRender createRenderObject(BuildContext context) {
    return MaxChildColumnRender(
      mainAxisSize: mainAxisSize,
      mainAxisAlignment: mainAxisAlignment,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant MaxChildColumnRender renderObject) {
    renderObject
      ..mainAxisSize = mainAxisSize
      ..mainAxisAlignment = mainAxisAlignment;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty<MainAxisAlignment>(
        'mainAxisAlignment', mainAxisAlignment));
  }
}

enum FlexFit {
  tight,
  loose,
}

//Класс для подклассов с информацией о дочерних элементах
class FlexParentData extends ContainerBoxParentData<RenderBox> {
  int? flex;
  FlexFit? fit;

  @override
  String toString() => '${super.toString()}; flex=$flex; fit=$fit';
}

typedef _ChildSizingFunction = double Function(RenderBox child, double extent);

//коробка(объект рендеринга)
class MaxChildColumnRender extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, FlexParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, FlexParentData>,
        DebugOverflowIndicatorMixin {
  MaxChildColumnRender({
    List<RenderBox>? children,
    MainAxisSize mainAxisSize = MainAxisSize.max,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.end,
  })  : _mainAxisAlignment = mainAxisAlignment,
        _mainAxisSize = mainAxisSize {
    addAll(children);
  }

  MainAxisSize _mainAxisSize;
  MainAxisAlignment _mainAxisAlignment;

  MainAxisAlignment get mainAxisAlignment => _mainAxisAlignment;
  set mainAxisAlignment(MainAxisAlignment value) {
    if (_mainAxisAlignment != value) {
      _mainAxisAlignment = value;
      markNeedsLayout();
    }
  }

  MainAxisSize get mainAxisSize => _mainAxisSize;
  set mainAxisSize(MainAxisSize value) {
    if (_mainAxisSize != value) {
      _mainAxisSize = value;
      markNeedsLayout();
    }
  }

  double _overflow = 0;
  bool get _hasOverflow => _overflow > precisionErrorTolerance;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! FlexParentData) {
      child.parentData = FlexParentData();
    }
  }

  double _getIntrinsicSize({
    required double extent,
    required _ChildSizingFunction childSize,
  }) {
    double totalFlex = 0.0;
    double inflexibleSpace = 0.0;
    double maxFlexFractionSoFar = 0.0;
    RenderBox? child = firstChild;
    while (child != null) {
      final int flex = _getFlex(child);
      totalFlex += flex;
      if (flex > 0) {
        final double flexFraction = childSize(child, extent) / _getFlex(child);
        maxFlexFractionSoFar = math.max(maxFlexFractionSoFar, flexFraction);
      } else {
        inflexibleSpace += childSize(child, extent);
      }
      final FlexParentData childParentData =
          child.parentData! as FlexParentData;
      child = childParentData.nextSibling;
    }
    return maxFlexFractionSoFar * totalFlex + inflexibleSpace;
  }

  //Минимальная высота бокса
  @override
  double computeMinIntrinsicHeight(double width) {
    return _getIntrinsicSize(
      extent: width,
      childSize: (RenderBox child, double extent) =>
          child.getMinIntrinsicHeight(extent),
    );
  }

  //Максимальная высота бокса
  @override
  double computeMaxIntrinsicHeight(double width) {
    return _getIntrinsicSize(
      extent: width,
      childSize: (RenderBox child, double extent) =>
          child.getMaxIntrinsicHeight(extent),
    );
  }

  //свойство flex часть от целого
  int _getFlex(RenderBox child) {
    final FlexParentData childParentData = child.parentData! as FlexParentData;
    return childParentData.flex ?? 0;
  }

  //свойство fit заполнение или <= родителя
  FlexFit _getFit(RenderBox child) {
    final FlexParentData childParentData = child.parentData! as FlexParentData;
    return childParentData.fit ?? FlexFit.tight;
  }

  //вычисление макета
  @override
  Size computeDryLayout(BoxConstraints constraints) {
    FlutterError? constraintsError;
    if (constraintsError != null) {
      assert(debugCannotComputeDryLayout(error: constraintsError));
      return Size.zero;
    }

    double maxWidth = 0;
    final _LayoutSizes sizes = _customComputeSizes(
        layoutChild: ChildLayoutHelper.dryLayoutChild,
        constraints: constraints,
        maxWidth: maxWidth);

    return constraints.constrain(Size(sizes.crossSize, sizes.mainSize));
  }

  //вычисление макета по ширине и высоте
  _LayoutSizes _customComputeSizes(
      {required BoxConstraints constraints,
      required ChildLayouter layoutChild,
      required double maxWidth}) {
    int totalFlex = 0;
    final double maxMainSize = constraints.maxHeight;
    final bool canFlex = maxMainSize < double.infinity;

    double crossSize = 0.0;
    double allocatedSize = 0.0;
    RenderBox? child = firstChild;
    RenderBox? lastFlexChild;

    while (child != null) {
      final FlexParentData childParentData =
          child.parentData! as FlexParentData;
      final int flex = _getFlex(child);
      if (flex > 0) {
        totalFlex += flex;
        lastFlexChild = child;
      } else {
        final Size childSize =
            layoutChild(child, BoxConstraints(maxWidth: maxWidth));
        allocatedSize += childSize.height;
        crossSize = math.max(crossSize, childSize.width);
      }
      assert(child.parentData == childParentData);
      child = childParentData.nextSibling;
    }

    final double freeSpace =
        math.max(0.0, (canFlex ? maxMainSize : 0.0) - allocatedSize);
    double allocatedFlexSpace = 0.0;
    if (totalFlex > 0) {
      final double spacePerFlex =
          canFlex ? (freeSpace / totalFlex) : double.nan;
      child = firstChild;
      while (child != null) {
        final int flex = _getFlex(child);
        if (flex > 0) {
          final double maxChildExtent = canFlex
              ? (child == lastFlexChild
                  ? (freeSpace - allocatedFlexSpace)
                  : spacePerFlex * flex)
              : double.infinity;
          late final double minChildExtent;
          switch (_getFit(child)) {
            case FlexFit.tight:
              assert(maxChildExtent < double.infinity);
              minChildExtent = maxChildExtent;
              break;
            case FlexFit.loose:
              minChildExtent = 0.0;
              break;
          }
          final BoxConstraints innerConstraints;
          innerConstraints = BoxConstraints(
            minWidth: constraints.maxWidth,
            maxWidth: constraints.maxWidth,
            minHeight: minChildExtent,
            maxHeight: maxChildExtent,
          );
          final Size childSize = layoutChild(child, innerConstraints);
          assert(childSize.height <= maxChildExtent);
          allocatedSize += childSize.height;
          allocatedFlexSpace += maxChildExtent;
          crossSize = math.max(crossSize, childSize.width);
        }
        final FlexParentData childParentData =
            child.parentData! as FlexParentData;
        child = childParentData.nextSibling;
      }
    }

    final double idealSize = canFlex && mainAxisSize == MainAxisSize.max
        ? maxMainSize
        : allocatedSize;

    return _LayoutSizes(
      mainSize: idealSize,
      crossSize: crossSize,
      allocatedSize: allocatedSize,
    );
  }

  //представление макета, здесь вызывается подсчет размеров, layout для каждого из дочерних
  @override
  void performLayout() {
    final BoxConstraints constraints = this.constraints;

    {
      RenderBox? child = firstChild;
      while (child != null) {
        final FlexParentData childParentData =
            child.parentData! as FlexParentData;
        ChildLayoutHelper.layoutChild(
            child, BoxConstraints(maxWidth: constraints.maxWidth));
        assert(child.parentData == childParentData);
        child = childParentData.nextSibling;
      }
    }

    double maxWidth = -1;
    RenderBox? child = firstChild;
    while (child != null) {
      final FlexParentData childParentData =
          child.parentData! as FlexParentData;
      double curWidth = child.size.width;
      if (maxWidth > curWidth || maxWidth == -1) {
        maxWidth = curWidth;
      }
      assert(child.parentData == childParentData);
      child = childParentData.nextSibling;
    }

    final _LayoutSizes mainSizes = _customComputeSizes(
        layoutChild: ChildLayoutHelper.layoutChild,
        constraints: constraints,
        maxWidth: maxWidth);

    double allocatedSize = mainSizes.allocatedSize;
    double actualSize = mainSizes.mainSize;
    double crossSize = mainSizes.crossSize;

    // Align items along the main axis.
    size = constraints.constrain(Size(crossSize, actualSize));
    actualSize = size.height;
    crossSize = size.width;

    final double actualSizeDelta = actualSize - allocatedSize;
    _overflow = math.max(0.0, -actualSizeDelta);
    final double remainingSpace = math.max(0.0, actualSizeDelta);
    late final double leadingSpace;
    late final double betweenSpace;

    switch (_mainAxisAlignment) {
      case MainAxisAlignment.start:
        leadingSpace = 0.0;
        betweenSpace = 0.0;
        break;
      case MainAxisAlignment.end:
        leadingSpace = remainingSpace;
        betweenSpace = 0.0;
        break;
      case MainAxisAlignment.center:
        leadingSpace = remainingSpace / 2.0;
        betweenSpace = 0.0;
        break;
      case MainAxisAlignment.spaceBetween:
        leadingSpace = 0.0;
        betweenSpace = childCount > 1 ? remainingSpace / (childCount - 1) : 0.0;
        break;
      case MainAxisAlignment.spaceAround:
        betweenSpace = childCount > 0 ? remainingSpace / childCount : 0.0;
        leadingSpace = betweenSpace / 2.0;
        break;
      case MainAxisAlignment.spaceEvenly:
        betweenSpace = childCount > 0 ? remainingSpace / (childCount + 1) : 0.0;
        leadingSpace = betweenSpace;
        break;
    }

    double childMainPosition = leadingSpace;
    child = firstChild;
    while (child != null) {
      final FlexParentData childParentData =
          child.parentData! as FlexParentData;
      final double childCrossPosition =
          crossSize / 2.0 - child.size.width / 2.0;
      childParentData.offset = Offset(childCrossPosition, childMainPosition);
      childMainPosition += child.size.height + betweenSpace;
      child = childParentData.nextSibling;
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (!_hasOverflow) {
      defaultPaint(context, offset);
      return;
    }

    if (size.isEmpty) {
      return;
    }

    _clipRectLayer.layer = context.pushClipRect(
      needsCompositing,
      offset,
      Offset.zero & size,
      defaultPaint,
      oldLayer: _clipRectLayer.layer,
    );
  }

  final LayerHandle<ClipRectLayer> _clipRectLayer =
      LayerHandle<ClipRectLayer>();

  @override
  void dispose() {
    _clipRectLayer.layer = null;
    super.dispose();
  }

  @override
  String toStringShort() {
    String header = super.toStringShort();
    if (!kReleaseMode) {
      if (_hasOverflow) {
        header += ' OVERFLOWING';
      }
    }
    return header;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty<MainAxisAlignment>(
        'mainAxisAlignment', mainAxisAlignment));
    properties.add(EnumProperty<MainAxisSize>('mainAxisSize', mainAxisSize));
  }
}

class _LayoutSizes {
  const _LayoutSizes({
    required this.mainSize,
    required this.crossSize,
    required this.allocatedSize,
  });

  final double mainSize;
  final double crossSize;
  final double allocatedSize;
}
