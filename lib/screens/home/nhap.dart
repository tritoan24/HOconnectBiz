import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State createState() => _State();
}

class _State extends State<MyApp> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    Center(child: Text('Page 1: Menu')),
    Center(child: Text('Page 2: Add')),
    Center(child: Text('Page 3: Assessment')),
    Center(child: Text('Page 4: Statistics')),
    Center(child: Text('Page 5: Settings')),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Hello ConvexAppBar')),
        body: _pages[_selectedIndex],
      ),
    );
  }
}
