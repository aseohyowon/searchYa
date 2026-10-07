import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'services/location_service.dart';

void main() => runApp(const SearchYaApp());

class SearchYaApp extends StatelessWidget {
  const SearchYaApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'SearchYa',
        theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
        home: HomeScreen(locationService: GeolocatorLocationService()),
      );
}
