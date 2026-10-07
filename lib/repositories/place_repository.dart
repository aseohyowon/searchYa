import '../core/utils/distance_utils.dart';
import '../models/location_data.dart';
import '../models/place.dart';
import '../services/place_search_service.dart';

/// Combines a [PlaceSearchService] with distance calculation and sorting.
class PlaceRepository {
  final PlaceSearchService _service;
  PlaceRepository(this._service);

  Future<List<Place>> nearby(LocationData origin) async =>
      _sort(origin, await _service.searchNearby(origin));

  Future<List<Place>> search(String keyword, LocationData origin) async {
    if (keyword.trim().isEmpty) return nearby(origin);
    return _sort(origin, await _service.searchByKeyword(keyword.trim(), origin));
  }

  List<Place> _sort(LocationData o, List<Place> places) {
    final result = places
        .map((p) => p.copyWith(
            distanceMeters: distanceMeters(o.latitude, o.longitude, p.latitude, p.longitude)))
        .toList();
    result.sort((a, b) => a.distanceMeters!.compareTo(b.distanceMeters!));
    return result;
  }
}
