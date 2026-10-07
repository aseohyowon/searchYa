import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/location_data.dart';
import '../models/place.dart';
import 'place_search_exception.dart';
import 'place_search_service.dart';

/// Kakao Local API implementation (keyword search, sorted by distance).
/// Chosen for Korea: best local-business coverage, phone numbers included,
/// simple REST key auth and free quota.
class KakaoPlaceSearchService implements PlaceSearchService {
  static const _host = 'dapi.kakao.com';
  static const _path = '/v2/local/search/keyword.json';
  static const defaultNearbyKeyword = '매장';

  final String apiKey;
  final http.Client _client;
  final Map<String, Place> _cache = {};

  KakaoPlaceSearchService({required this.apiKey, http.Client? client})
      : _client = client ?? http.Client();

  @override
  Future<List<Place>> searchNearby(LocationData origin,
          {int radiusMeters = 2000}) =>
      searchByKeyword(defaultNearbyKeyword, origin, radiusMeters: radiusMeters);

  @override
  Future<List<Place>> searchByKeyword(String keyword, LocationData origin,
      {int radiusMeters = 2000}) async {
    final uri = Uri.https(_host, _path, {
      'query': keyword,
      'x': '${origin.longitude}',
      'y': '${origin.latitude}',
      'radius': '$radiusMeters',
      'sort': 'distance',
      'size': '15',
    });
    final http.Response res;
    try {
      res = await _client
          .get(uri, headers: {'Authorization': 'KakaoAK $apiKey'})
          .timeout(const Duration(seconds: 10));
    } catch (_) {
      throw const PlaceSearchException(
          '네트워크 연결을 확인한 후 다시 시도해 주세요.');
    }
    if (res.statusCode == 401 || res.statusCode == 403) {
      throw const PlaceSearchException('API 키가 올바르지 않습니다. 설정을 확인해 주세요.');
    }
    if (res.statusCode != 200) {
      throw const PlaceSearchException(
          '검색 서버에 문제가 발생했습니다. 잠시 후 다시 시도해 주세요.');
    }
    try {
      final docs = (jsonDecode(utf8.decode(res.bodyBytes))['documents'] as List)
          .cast<Map<String, dynamic>>();
      final places = docs.map(_parse).toList();
      for (final p in places) {
        _cache[p.id] = p;
      }
      return places;
    } catch (_) {
      throw const PlaceSearchException('검색 결과를 해석하지 못했습니다.');
    }
  }

  /// Kakao has no detail endpoint; details come from the search response.
  @override
  Future<Place> getPlaceDetail(String id) async {
    final p = _cache[id];
    if (p == null) throw const PlaceSearchException('매장 정보를 찾을 수 없습니다.');
    return p;
  }

  Place _parse(Map<String, dynamic> d) {
    final road = (d['road_address_name'] as String?) ?? '';
    final phone = (d['phone'] as String?)?.trim();
    return Place(
      id: d['id'] as String,
      name: d['place_name'] as String,
      address: road.isNotEmpty ? road : (d['address_name'] as String? ?? ''),
      phone: (phone == null || phone.isEmpty) ? null : phone,
      latitude: double.parse(d['y'] as String),
      longitude: double.parse(d['x'] as String),
    );
  }
}
