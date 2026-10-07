import 'package:flutter/material.dart';

void main() => runApp(const SearchYaApp());

class SearchYaApp extends StatelessWidget {
  const SearchYaApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'SearchYa',
        theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
        home: const Scaffold(body: Center(child: Text('SearchYa'))),
      );
}
