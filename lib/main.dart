import 'package:custom_widgets/demo_widget.dart';
import 'package:custom_widgets/ellipsized_text/ellipsized_text_demo.dart';
import 'package:custom_widgets/child_size/child_size_demo.dart';
import 'package:custom_widgets/column/max_child_column_demo.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Custom Widgets',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Custom Widgets')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildItem(context, const EllipsizedTextDemo()),
            _buildItem(context, const ChildSizeDemo()),
            _buildItem(context, const MaxChildColumnDemo()),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, DemoWidget screen) {
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: Text(screen.title, style: const TextStyle(fontSize: 20)),
      ),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
      },
    );
  }
}
