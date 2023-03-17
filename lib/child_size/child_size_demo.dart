import 'dart:async';
import 'dart:math';

import 'package:custom_widgets/demo_widget.dart';
import 'package:custom_widgets/child_size/child_size.dart';
import 'package:flutter/material.dart';

class ChildSizeDemo extends StatefulWidget implements DemoWidget {
  const ChildSizeDemo({super.key});

  @override
  final title = 'ChildSize';

  @override
  DemoWidgetState createState() => _ChildSizeDemoState();
}

class _ChildSizeDemoState extends DemoWidgetState {
  var _fraction = 1.0;
  var _size = Size.zero;

  @override
  Widget buildContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 100),
        Slider(
            value: _fraction,
            onChanged: (value) => setState(() => _fraction = value)),
        Text(_size.toString()),
        Center(child: _buildContent()),
      ],
    );
  }

  Widget _buildContent() {
    return ChildSize(
      child: _buildImage(),
      onChildSizeChanged: (size) => scheduleMicrotask(() {
        setState(() => _size = size);
      }),
    );
  }

  Widget _buildImage() {
    return LayoutBuilder(builder: (_, constraints) {
      return ColoredBox(
        color: Colors.amber,
        child: Icon(
          Icons.abc,
          color: Colors.yellow,
          size: min(constraints.maxWidth, constraints.maxHeight) * _fraction,
        ),
      );
    });
  }
}
