import '../models/location_data.dart';
import '../models/place.dart';
import 'place_search_service.dart';

/// Mock data around Seoul City Hall for developing UI/logic without an API key.
class MockPlaceSearchService implements PlaceSearchService {
  static const _places = [
    Place(id: '1', name: 'A철물점', address: '서울 중구 세종대로 110', phone: '02-1111-1111', latitude: 37.5668, longitude: 126.9785),
    Place(id: '2', name: 'B공구', address: '서울 중구 태평로 1가', phone: null, latitude: 37.5700, longitude: 126.9800),
    Place(id: '3', name: 'C철물점', address: '서울 종로구 종로 1', phone: '02-3333-3333', latitude: 37.5700, longitude: 126.9830),
  ];

  @override
  Future<List<Place>> searchNearby(LocationData origin, {int radiusMeters = 2000}) async =>
      _places;

  @override
  Future<List<Place>> searchByKeyword(String keyword, LocationData origin,
          {int radiusMeters = 2000}) async =>
      _places.where((p) => p.name.contains(keyword)).toList();

  @override
  Future<Place> getPlaceDetail(String id) async =>
      _places.firstWhere((p) => p.id == id);
}
