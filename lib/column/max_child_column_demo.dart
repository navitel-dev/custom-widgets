import 'package:custom_widgets/demo_widget.dart';
import 'package:custom_widgets/column/max_child_column.dart';
import 'package:flutter/material.dart';

class MaxChildColumnDemo extends DemoWidget {
  const MaxChildColumnDemo({super.key});

  @override
  final title = 'MaxChildColumn';

  @override
  DemoWidgetState createState() => _MyColumnDemoState();
}

class _MyColumnDemoState extends DemoWidgetState {
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
    return MaxChildColumn(
      children: <Widget>[
        Container(
          color: Colors.red,
          height: 50,
        ),
        Container(
          color: Colors.green,
          height: 100,
        ),
        Container(
          color: Colors.blue,
          height: 100,
          width: MediaQuery.of(context).size.width * _fraction,
        ),
      ],
    );
  }
}