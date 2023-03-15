import 'package:flutter/material.dart';

import 'package:custom_widgets/demo_widget.dart';
import 'package:custom_widgets/ellipsized_text/ellipsized_text.dart';

class EllipsizedTextDemo extends DemoWidget {
  const EllipsizedTextDemo({super.key});

  @override
  final title = 'EllipsizedText';

  @override
  DemoWidgetState createState() => _EllipsizedTextDemoState();
}

class _EllipsizedTextDemoState extends DemoWidgetState {
  var _fraction = 1.0;

  @override
  Widget buildContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 100),
        Slider(
            value: _fraction,
            onChanged: (value) => setState(() => _fraction = value)),
        Expanded(child: _buildTextExamples()),
      ],
    );
  }

  Widget _buildTextExamples() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Text'),
        CustomSingleChildLayout(
          delegate: _SingleChildLayoutDelegate(_fraction),
          child: const Text(
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.black),
          ),
        ),
        const Text('EllipsizedText'),
        CustomSingleChildLayout(
          delegate: _SingleChildLayoutDelegate(_fraction),
          child: const EllipsizedText(
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit',
            style: TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }
}

class _SingleChildLayoutDelegate extends SingleChildLayoutDelegate {
  final double _width;

  _SingleChildLayoutDelegate(this._width);

  @override
  Size getSize(BoxConstraints constraints) {
    return constraints.constrainDimensions(double.infinity, 30);
  }

  @override
  bool shouldRelayout(_SingleChildLayoutDelegate oldDelegate) {
    return oldDelegate._width != _width;
  }

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return constraints.copyWith(
        maxWidth: constraints.maxWidth * _width, minHeight: 0);
  }
}
