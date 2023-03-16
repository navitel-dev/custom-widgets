import 'package:custom_widgets/container/circle_style.dart';
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
  var _fractionWidth = 100.0;
  var _fractionHeight = 100.0;
  var _fractionRadius = 100.0;

  @override
  Widget buildContent() {
    StyleCircle style = StyleCircle();

    return Column(children: [
      const Text("width"),
      Slider(
          min: 10,
          max: 300,
          value: _fractionWidth,
          onChanged: (value) => setState(() => _fractionWidth = value)),
      const Text("height"),
      Slider(
          min: 10,
          max: 300,
          value: _fractionHeight,
          onChanged: (value) => setState(() => _fractionHeight = value)),
      const Text('radius'),
      Slider(
          min: 0,
          max: 100,
          value: _fractionRadius,
          onChanged: (value) => setState(() => _fractionRadius = value)),
      Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height - 350,
          color: Colors.black,
          child: Center(
            child: DecoratedContainer(
              colorShadow: Colors.grey.withOpacity(0.3),
              spreadRadius: 10,
              blurRadius: 10,
              width: _fractionWidth,
              height: _fractionHeight,
              color: Colors.red,
              radius: _fractionRadius,
              child: ElevatedButton(
                style: style.giveStyle(_fractionRadius),
                onPressed: () {},
                child: const Icon(
                  Icons.favorite,
                  color: Colors.white,
                ),
              ),
            ),
          ))
    ]);
  }
}
