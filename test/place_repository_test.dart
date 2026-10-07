import 'package:flutter_test/flutter_test.dart';
import 'package:search_ya/core/utils/distance_utils.dart';
import 'package:search_ya/models/location_data.dart';
import 'package:search_ya/repositories/place_repository.dart';
import 'package:search_ya/services/mock_place_search_service.dart';

void main() {
  test('formatDistance', () {
    expect(formatDistance(120), '120m');
    expect(formatDistance(1200), '1.2km');
  });

  test('results sorted by distance', () async {
    final repo = PlaceRepository(MockPlaceSearchService());
    final r = await repo.nearby(const LocationData(latitude: 37.5665, longitude: 126.9780));
    for (var i = 1; i < r.length; i++) {
      expect(r[i].distanceMeters! >= r[i - 1].distanceMeters!, isTrue);
    }
  });

  test('keyword search with no match is empty', () async {
    final repo = PlaceRepository(MockPlaceSearchService());
    final r = await repo.search('없음', const LocationData(latitude: 37.5665, longitude: 126.9780));
    expect(r, isEmpty);
  });
}
