import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:search_ya/models/location_data.dart';
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
  await t.pumpWidget(MaterialApp(home: HomeScreen(locationService: FakeLocation(r))));
  await t.pumpAndSettle();
}

void main() {
  testWidgets('granted shows location', (t) async {
    await pump(t, const LocationResult(LocationStatus.ok, LocationData(latitude: 1, longitude: 2)));
    expect(find.textContaining('현재 위치: 1.0, 2.0'), findsOneWidget);
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
