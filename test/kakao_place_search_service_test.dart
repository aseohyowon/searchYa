import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:search_ya/models/location_data.dart';
import 'package:search_ya/services/kakao_place_search_service.dart';
import 'package:search_ya/services/place_search_exception.dart';

const origin = LocationData(latitude: 37.5, longitude: 127.0);

void main() {
  test('parses documents and sends auth header', () async {
    late http.Request captured;
    final svc = KakaoPlaceSearchService(
      apiKey: 'k',
      client: MockClient((req) async {
        captured = req;
        return http.Response(
            jsonEncode({
              'documents': [
                {'id': '1', 'place_name': 'A', 'address_name': 'addr', 'road_address_name': '', 'phone': '', 'x': '127.1', 'y': '37.6'}
              ]
            }),
            200);
      }),
    );
    final r = await svc.searchByKeyword('철물점', origin);
    expect(captured.headers['Authorization'], 'KakaoAK k');
    expect(r.single.phone, isNull);
    expect(r.single.address, 'addr');
    expect((await svc.getPlaceDetail('1')).name, 'A');
  });

  test('network error maps to PlaceSearchException', () async {
    final svc = KakaoPlaceSearchService(
        apiKey: 'k', client: MockClient((_) async => throw Exception('x')));
    expect(svc.searchNearby(origin), throwsA(isA<PlaceSearchException>()));
  });

  test('401 maps to PlaceSearchException', () async {
    final svc = KakaoPlaceSearchService(
        apiKey: 'k', client: MockClient((_) async => http.Response('', 401)));
    expect(svc.searchNearby(origin), throwsA(isA<PlaceSearchException>()));
  });
}
