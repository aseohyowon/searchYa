import 'package:flutter/material.dart';

import 'core/constants/env.dart';
import 'repositories/place_repository.dart';
import 'screens/home_screen.dart';
import 'services/kakao_place_search_service.dart';
import 'services/location_service.dart';
import 'services/map_service.dart';
import 'services/mock_place_search_service.dart';
import 'services/phone_service.dart';
import 'services/place_search_service.dart';

void main() => runApp(const SearchYaApp());

class SearchYaApp extends StatelessWidget {
  const SearchYaApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Real Kakao API when a key is supplied via --dart-define, else mock data.
    final PlaceSearchService search = Env.hasKakaoKey
        ? KakaoPlaceSearchService(apiKey: Env.kakaoRestApiKey)
        : MockPlaceSearchService();
    return MaterialApp(
      title: 'SearchYa',
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: HomeScreen(
        locationService: GeolocatorLocationService(),
        repository: PlaceRepository(search),
        phoneService: UrlLauncherPhoneService(),
        mapService: UrlLauncherMapService(),
      ),
    );
  }
}
