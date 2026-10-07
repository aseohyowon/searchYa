import 'package:flutter/material.dart';

import '../models/place.dart';
import '../services/phone_service.dart';

/// Call button; disabled when the place has no phone number.
class PhoneButton extends StatelessWidget {
  final Place place;
  final PhoneService phoneService;
  const PhoneButton({super.key, required this.place, required this.phoneService});

  Future<void> _call(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await phoneService.call(place.phone!);
    if (!ok) {
      messenger.showSnackBar(
          const SnackBar(content: Text('전화 앱을 열 수 없습니다.')));
    }
  }

  @override
  Widget build(BuildContext context) => IconButton(
        icon: const Icon(Icons.call),
        tooltip: place.hasPhone ? '전화하기' : '전화번호 없음',
        onPressed: place.hasPhone ? () => _call(context) : null,
      );
}
