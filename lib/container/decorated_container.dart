import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class DecoratedBox extends SingleChildRenderObjectWidget {
  const DecoratedBox({
    super.key,
    required this.decoration,
    this.position = DecorationPosition.background,
    super.child,
  });

  final Decoration decoration;

  final DecorationPosition position;

  @override
  RenderDecoratedBox createRenderObject(BuildContext context) {
    return RenderDecoratedBox(
      decoration: decoration,
      position: position,
      configuration: createLocalImageConfiguration(context),
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderDecoratedBox renderObject) {
    renderObject
      ..decoration = decoration
      ..configuration = createLocalImageConfiguration(context)
      ..position = position;
  }
}

class DecoratedContainer extends StatelessWidget {
  DecoratedContainer({
    super.key,
    this.color,
    required this.radius,
    this.width,
    this.height,
    BoxConstraints? constraints,
    this.transform,
    this.transformAlignment,
    this.child,
    this.decoration,
  }) : assert(constraints == null || constraints.debugAssertIsValid());
  final double? width;
  final double? height;
  final double radius;
  final Widget? child;
  final Color? color;
  final Decoration? decoration;
  final Matrix4? transform;
  final AlignmentGeometry? transformAlignment;

  @override
  Widget build(BuildContext context) {
    Widget? current = child;

    if (child == null) {
      current = LimitedBox(
        maxWidth: 0.0,
        maxHeight: 0.0,
        child: ConstrainedBox(
            constraints: BoxConstraints.expand(width: width, height: height)),
      );
    }

    final decoration = BoxDecoration(
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(radius),
          topRight: Radius.circular(radius),
          bottomLeft: Radius.circular(radius),
          bottomRight: Radius.circular(radius)),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.3),
          spreadRadius: 10,
          blurRadius: 10,
          offset: const Offset(0, 0),
        ),
      ],
      color: color,
    );
    current = DecoratedBox(decoration: decoration, child: current);

    if (transform != null) {
      current = Transform(
          transform: transform!, alignment: transformAlignment, child: current);
    }

    return current;
  }
}
