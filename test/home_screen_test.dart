import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:search_ya/models/location_data.dart';
import 'package:search_ya/repositories/place_repository.dart';
import 'package:search_ya/services/mock_place_search_service.dart';
import 'package:search_ya/screens/home_screen.dart';
import 'package:search_ya/services/location_service.dart';

class FakeLocation implements LocationService {
  final LocationResult result;
  FakeLocation(this.result);
  @override
  Future<LocationResult> getCurrentLocation() async => result;
  @override
  Future<void> openSettings() async {}
}

Future<void> pump(WidgetTester t, LocationResult r) async {
  await t.pumpWidget(MaterialApp(home: HomeScreen(
      locationService: FakeLocation(r),
      repository: PlaceRepository(MockPlaceSearchService()))));
  await t.pumpAndSettle();
}

void main() {
  testWidgets('granted shows location', (t) async {
    await pump(t, const LocationResult(LocationStatus.ok, LocationData(latitude: 37.5665, longitude: 126.9780)));
    expect(find.text('A철물점'), findsOneWidget);
    expect(find.textContaining('m'), findsWidgets);
    // nearest first
    expect(t.getTopLeft(find.text('A철물점')).dy < t.getTopLeft(find.text('C철물점')).dy, isTrue);
  });
  testWidgets('denied shows message', (t) async {
    await pump(t, const LocationResult(LocationStatus.denied));
    expect(find.textContaining('현재 위치를 사용할 수 없습니다'), findsOneWidget);
  });
  testWidgets('denied forever shows settings button', (t) async {
    await pump(t, const LocationResult(LocationStatus.deniedForever));
    expect(find.text('설정으로 이동'), findsOneWidget);
  });
  testWidgets('GPS failure shows message', (t) async {
    await pump(t, const LocationResult(LocationStatus.unavailable));
    expect(find.textContaining('가져오지 못했습니다'), findsOneWidget);
  });
}
