import '../models/location_data.dart';
import '../models/place.dart';

/// Map-provider-agnostic place search interface. Implement for Kakao/Naver/Google.
abstract class PlaceSearchService {
  Future<List<Place>> searchNearby(LocationData origin, {int radiusMeters = 2000});
  Future<List<Place>> searchByKeyword(String keyword, LocationData origin,
      {int radiusMeters = 2000});
  Future<Place> getPlaceDetail(String id);
}
