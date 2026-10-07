import 'package:flutter/material.dart';

import '../core/utils/distance_utils.dart';
import '../models/place.dart';
import '../services/phone_service.dart';
import 'phone_button.dart';

/// One row in the store list: name, distance, address, phone, call button.
class PlaceListItem extends StatelessWidget {
  final Place place;
  final PhoneService phoneService;
  final VoidCallback? onTap;
  const PlaceListItem(
      {super.key, required this.place, required this.phoneService, this.onTap});

  @override
  Widget build(BuildContext context) {
    final d = place.distanceMeters;
    return ListTile(
      onTap: onTap,
      title: Row(children: [
        Expanded(child: Text(place.name)),
        if (d != null) Text(formatDistance(d)),
      ]),
      subtitle: Text([
        place.address,
        if (place.hasPhone) place.phone!,
      ].join('\n')),
      isThreeLine: place.hasPhone,
      trailing: PhoneButton(place: place, phoneService: phoneService),
    );
  }
}
