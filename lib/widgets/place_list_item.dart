import 'package:flutter/material.dart';

import '../core/utils/distance_utils.dart';
import '../models/place.dart';

/// One row in the store list: name, distance, address, phone.
/// The phone button (STEP 7) is added later.
class PlaceListItem extends StatelessWidget {
  final Place place;
  const PlaceListItem({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    final d = place.distanceMeters;
    return ListTile(
      title: Text(place.name),
      subtitle: Text([
        place.address,
        if (place.hasPhone) place.phone!,
      ].join('\n')),
      isThreeLine: place.hasPhone,
      trailing: d == null ? null : Text(formatDistance(d)),
    );
  }
}
