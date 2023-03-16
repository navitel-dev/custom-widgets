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
    required this.blurRadius,
    required this.colorShadow,
    required this.spreadRadius,
    required this.width,
    required this.height,
    this.transform,
    this.transformAlignment,
    this.child,
    this.decoration,
    this.constraints,
  }) : assert(constraints == null || constraints.debugAssertIsValid());
  final double width;
  final double height;
  final Color colorShadow;
  final double spreadRadius;
  final double blurRadius;
  final double radius;
  final Widget? child;
  final Color? color;
  final Decoration? decoration;
  final BoxConstraints? constraints;
  final Matrix4? transform;
  final AlignmentGeometry? transformAlignment;

  @override
  Widget build(BuildContext context) {
    Widget? current = child;
    final defDecoration = BoxDecoration(
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(radius),
          topRight: Radius.circular(radius),
          bottomLeft: Radius.circular(radius),
          bottomRight: Radius.circular(radius)),
      boxShadow: [
        BoxShadow(
          color: colorShadow,
          spreadRadius: spreadRadius,
          blurRadius: blurRadius,
          offset: const Offset(0, 0),
        ),
      ],
      color: color,
    );
    if (child == null && (constraints == null || !constraints!.isTight)) {
      current = LimitedBox(
        maxWidth: 0.0,
        maxHeight: 0.0,
        child: ConstrainedBox(constraints: const BoxConstraints.expand()),
      );
    } else {
      current = Container(
        width: width,
        height: height,
        decoration: defDecoration,
        child: current,
      );
    }

    current = DecoratedBox(decoration: defDecoration, child: current);

    if (constraints != null) {
      current = ConstrainedBox(constraints: constraints!, child: current);
    }

    if (transform != null) {
      current = Transform(
          transform: transform!, alignment: transformAlignment, child: current);
    }

    return current;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    if (color != null) {
      properties.add(DiagnosticsProperty<Color>('bg', color));
    } else {
      properties.add(DiagnosticsProperty<Decoration>('bg', decoration,
          defaultValue: null));
    }
    properties.add(DiagnosticsProperty<BoxConstraints>(
        'constraints', constraints,
        defaultValue: null));
  }
}
