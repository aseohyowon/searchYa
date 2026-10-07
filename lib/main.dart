import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'repositories/place_repository.dart';
import 'services/location_service.dart';
import 'services/mock_place_search_service.dart';

void main() => runApp(const SearchYaApp());

class SearchYaApp extends StatelessWidget {
  const SearchYaApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'SearchYa',
        theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
        home: HomeScreen(
          locationService: GeolocatorLocationService(),
          // STEP 5에서 실제 API 구현으로 교체
          repository: PlaceRepository(MockPlaceSearchService()),
        ),
      );
}
