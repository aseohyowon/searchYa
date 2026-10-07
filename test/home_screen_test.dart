import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:search_ya/models/location_data.dart';
import 'package:search_ya/models/place.dart';
import 'package:search_ya/repositories/place_repository.dart';
import 'package:search_ya/screens/home_screen.dart';
import 'package:search_ya/services/location_service.dart';
import 'package:search_ya/services/map_service.dart';
import 'package:search_ya/services/mock_place_search_service.dart';
import 'package:search_ya/services/phone_service.dart';
import 'package:search_ya/services/place_search_exception.dart';
import 'package:search_ya/services/place_search_service.dart';

class FakeLocation implements LocationService {
  final LocationResult result;
  FakeLocation(this.result);
  @override
  Future<LocationResult> getCurrentLocation() async => result;
  @override
  Future<void> openSettings() async {}
}

class FakePhone implements PhoneService {
  final calls = <String>[];
  @override
  Future<bool> call(String n) async {
    calls.add(n);
    return true;
  }
}

class FakeMap implements MapService {
  @override
  Future<bool> openMap(double lat, double lng, String label) async => true;
}

class FailingSearch extends MockPlaceSearchService {
  @override
  Future<List<Place>> searchNearby(LocationData o, {int radiusMeters = 2000}) =>
      throw const PlaceSearchException('네트워크 연결을 확인한 후 다시 시도해 주세요.');
}

const ok = LocationResult(LocationStatus.ok,
    LocationData(latitude: 37.5665, longitude: 126.9780));

Future<FakePhone> pump(WidgetTester t, LocationResult r,
    {PlaceSearchService? search}) async {
  final phone = FakePhone();
  await t.pumpWidget(MaterialApp(
      home: HomeScreen(
          locationService: FakeLocation(r),
          repository: PlaceRepository(search ?? MockPlaceSearchService()),
          phoneService: phone,
          mapService: FakeMap())));
  await t.pumpAndSettle();
  return phone;
}

void main() {
  testWidgets('granted shows list sorted by distance', (t) async {
    await pump(t, ok);
    expect(find.text('A철물점'), findsOneWidget);
    expect(t.getTopLeft(find.text('A철물점')).dy <
        t.getTopLeft(find.text('C철물점')).dy, isTrue);
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
  testWidgets('keyword search filters results', (t) async {
    await pump(t, ok);
    await t.enterText(find.byType(TextField), 'C철물');
    await t.testTextInput.receiveAction(TextInputAction.search);
    await t.pumpAndSettle();
    expect(find.text('C철물점'), findsOneWidget);
    expect(find.text('A철물점'), findsNothing);
  });
  testWidgets('no results message', (t) async {
    await pump(t, ok);
    await t.enterText(find.byType(TextField), '없는가게');
    await t.testTextInput.receiveAction(TextInputAction.search);
    await t.pumpAndSettle();
    expect(find.text('주변에서 검색 결과를 찾을 수 없습니다.'), findsOneWidget);
  });
  testWidgets('network error shows message and retry', (t) async {
    await pump(t, ok, search: FailingSearch());
    expect(find.textContaining('네트워크 연결'), findsOneWidget);
    expect(find.text('다시 시도'), findsOneWidget);
  });
  testWidgets('place without phone has disabled call button', (t) async {
    await pump(t, ok);
    final buttons = t.widgetList<IconButton>(find.widgetWithIcon(IconButton, Icons.call));
    expect(buttons.where((b) => b.onPressed == null).length, 1);
  });
  testWidgets('call button invokes phone service', (t) async {
    final phone = await pump(t, ok);
    await t.tap(find.widgetWithIcon(IconButton, Icons.call).first);
    expect(phone.calls, ['02-1111-1111']);
  });
  testWidgets('tapping a place opens detail with call button', (t) async {
    final phone = await pump(t, ok);
    await t.tap(find.text('A철물점'));
    await t.pumpAndSettle();
    expect(find.text('지도에서 위치 보기'), findsOneWidget);
    await t.tap(find.text('전화하기'));
    expect(phone.calls, ['02-1111-1111']);
  });
}
