import 'package:flutter/widgets.dart';

enum Ellipsis { start, middle, end }

class EllipsizedText extends LeafRenderObjectWidget {
  final String text;
  final TextStyle? style;
  final Ellipsis ellipsis;

  const EllipsizedText(
    this.text, {
    Key? key,
    this.style,
    this.ellipsis = Ellipsis.end,
  }) : super(key: key);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderEllipsizedText()
      ..text = text
      ..style = style
      ..ellipsis = ellipsis;
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderEllipsizedText renderObject) {
    renderObject
      ..text = text
      ..style = style
      ..ellipsis = ellipsis;
  }
}

class RenderEllipsizedText extends RenderBox {
  RenderEllipsizedText({
    String text = '',
    TextStyle? style,
    Ellipsis ellipsis = Ellipsis.end,
  })  : _text = text,
        _style = style,
        _ellipsis = ellipsis;

  var _constraints = const BoxConstraints();
  final _textPainter = TextPainter(textDirection: TextDirection.ltr);

  String _text;
  String get text => _text;
  set text(String value) {
    if (_text != value) {
      _text = value;
      markNeedsLayout();
    }
  }

  TextStyle? _style;
  TextStyle? get style => _style;
  set style(TextStyle? value) {
    assert(value != null);
    if (_style != value) {
      _style = value;
      markNeedsLayout();
    }
  }

  Ellipsis _ellipsis;
  Ellipsis get ellipsis => _ellipsis;
  set ellipsis(Ellipsis value) {
    if (_ellipsis != value) {
      _ellipsis = value;
      markNeedsLayout();
    }
  }

  @override
  void performLayout() {
    if (_constraints == constraints && hasSize) {
      return;
    }

    _constraints = constraints;

    size = _ellipsize(
      minWidth: constraints.minWidth,
      maxWidth: constraints.maxWidth,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    _textPainter.paint(context.canvas, offset);
  }

  Size _ellipsize({required double minWidth, required double maxWidth}) {
    final text = _text;

    if (_layoutText(length: text.length, minWidth: minWidth) > maxWidth) {
      var left = 0;
      var right = text.length - 1;

      while (left < right) {
        final index = (left + right) ~/ 2;
        if (_layoutText(length: index, minWidth: minWidth) > maxWidth) {
          right = index;
        } else {
          left = index + 1;
        }
      }
      _layoutText(length: right - 1, minWidth: minWidth);
    }

    return constraints.constrain(Size(_textPainter.width, _textPainter.height));
  }

  double _layoutText({required int length, required double minWidth}) {
    final text = _text;
    final style = _style;
    final ellipsis = _ellipsis;

    String ellipsizedText = '';

    switch (ellipsis) {
      case Ellipsis.start:
        if (length > 0) {
          ellipsizedText = text.substring(text.length - length, text.length);
          if (length != text.length) {
            ellipsizedText = '...$ellipsizedText';
          }
        }
        break;
      case Ellipsis.middle:
        if (length > 0) {
          ellipsizedText = text;
          if (length != text.length) {
            var start = text.substring(0, (length / 2).round());
            var end = text.substring(text.length - start.length, text.length);
            ellipsizedText = '$start...$end';
          }
        }
        break;
      case Ellipsis.end:
        if (length > 0) {
          ellipsizedText = text.substring(0, length);
          if (length != text.length) {
            ellipsizedText = '$ellipsizedText...';
          }
        }
        break;
    }

    _textPainter.text = TextSpan(text: ellipsizedText, style: style);
    _textPainter.layout(minWidth: minWidth, maxWidth: double.infinity);
    return _textPainter.width;
  }
}
