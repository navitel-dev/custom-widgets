import 'package:custom_widgets/container/decorated_container.dart';
import 'package:flutter/material.dart';

import 'package:custom_widgets/demo_widget.dart';

class DecoratedContainerDemo extends DemoWidget {
  const DecoratedContainerDemo({super.key});

  @override
  final title = 'DecoratedContainer';

  @override
  DemoWidgetState createState() => _DecoratedContainerDemoState();
}

class _DecoratedContainerDemoState extends DemoWidgetState {
  @override
  Widget buildContent() {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.black,
        child: Center(
          child: DecoratedContainer(
            width: 100,
            height: 100,
            color: Colors.yellow,
            radius: 16,
          ),
        ));
  }
}
