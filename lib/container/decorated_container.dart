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
    this.alignment,
    this.color,
    required this.radius,
    double? width,
    double? height,
    BoxConstraints? constraints,
    this.transform,
    this.transformAlignment,
    this.child,
    this.clipBehavior = Clip.none,
    this.decoration,
  })  : assert(constraints == null || constraints.debugAssertIsValid()),
        assert(clipBehavior == Clip.none),
        constraints = (width != null || height != null)
            ? constraints?.tighten(width: width, height: height) ??
                BoxConstraints.tightFor(width: width, height: height)
            : constraints;
  final double radius;
  final Widget? child;
  final AlignmentGeometry? alignment;
  final Color? color;
  final Decoration? decoration;
  final BoxConstraints? constraints;
  final Matrix4? transform;
  final AlignmentGeometry? transformAlignment;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    Widget? current = child;

    if (child == null && (constraints == null || !constraints!.isTight)) {
      current = LimitedBox(
        maxWidth: 0.0,
        maxHeight: 0.0,
        child: ConstrainedBox(constraints: const BoxConstraints.expand()),
      );
    } else if (alignment != null) {
      current = Align(alignment: alignment!, child: current);
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
          spreadRadius: 3,
          blurRadius: 10,
          offset: const Offset(0, 0), // changes position of shadow
        ),
      ],
      color: color,
    );
    current = DecoratedBox(decoration: decoration, child: current);

    if (clipBehavior != Clip.none) {
      current = ClipPath(
        clipper: _DecorationClipper(
          textDirection: Directionality.maybeOf(context),
          decoration: decoration,
        ),
        clipBehavior: clipBehavior,
        child: current,
      );
    }

    current = DecoratedBox(decoration: decoration, child: current);

    if (constraints != null) {
      current = ConstrainedBox(constraints: constraints!, child: current);
    }

    if (transform != null) {
      current = Transform(
          transform: transform!, alignment: transformAlignment, child: current);
    }

    return current;
  }
}

class _DecorationClipper extends CustomClipper<Path> {
  _DecorationClipper({
    TextDirection? textDirection,
    required this.decoration,
  }) : textDirection = textDirection ?? TextDirection.ltr;

  final TextDirection textDirection;
  final Decoration decoration;

  @override
  Path getClip(Size size) {
    return decoration.getClipPath(Offset.zero & size, textDirection);
  }

  @override
  bool shouldReclip(_DecorationClipper oldClipper) {
    return oldClipper.decoration != decoration ||
        oldClipper.textDirection != textDirection;
  }
}
