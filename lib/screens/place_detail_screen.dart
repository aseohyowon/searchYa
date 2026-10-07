import 'package:flutter/material.dart';

import '../core/utils/distance_utils.dart';
import '../models/place.dart';
import '../services/map_service.dart';
import '../services/phone_service.dart';

class PlaceDetailScreen extends StatelessWidget {
  final Place place;
  final PhoneService phoneService;
  final MapService mapService;
  const PlaceDetailScreen(
      {super.key,
      required this.place,
      required this.phoneService,
      required this.mapService});

  void _toast(BuildContext c, String m) =>
      ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    final d = place.distanceMeters;
    return Scaffold(
      appBar: AppBar(title: Text(place.name)),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Text(place.name, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        _row(Icons.place, place.address),
        _row(Icons.phone, place.hasPhone ? place.phone! : '전화번호 정보 없음'),
        if (d != null) _row(Icons.near_me, '현재 위치에서 ${formatDistance(d)}'),
        if (place.openingHours != null)
          _row(Icons.schedule, place.openingHours!),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          icon: const Icon(Icons.map),
          label: const Text('지도에서 위치 보기'),
          onPressed: () async {
            final ok = await mapService.openMap(
                place.latitude, place.longitude, place.name);
            if (!ok && context.mounted) _toast(context, '지도를 열 수 없습니다.');
          },
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          icon: const Icon(Icons.call),
          label: const Text('전화하기'),
          onPressed: place.hasPhone
              ? () async {
                  final ok = await phoneService.call(place.phone!);
                  if (!ok && context.mounted) {
                    _toast(context, '전화 앱을 열 수 없습니다.');
                  }
                }
              : null,
        ),
      ]),
    );
  }

  Widget _row(IconData icon, String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ]),
      );
}
