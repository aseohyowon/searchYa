import 'package:geolocator/geolocator.dart';

import '../models/location_data.dart';

/// Result states for obtaining the current location.
enum LocationStatus {
  ok,
  denied,
  deniedForever,
  serviceDisabled,
  unavailable,
}

class LocationResult {
  final LocationStatus status;
  final LocationData? location;
  const LocationResult(this.status, [this.location]);
}

abstract class LocationService {
  /// Requests permission if needed and returns the current position.
  Future<LocationResult> getCurrentLocation();

  /// Opens the OS app settings so the user can grant permission.
  Future<void> openSettings();
}

class GeolocatorLocationService implements LocationService {
  @override
  Future<LocationResult> getCurrentLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return const LocationResult(LocationStatus.serviceDisabled);
      }
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied) {
        return const LocationResult(LocationStatus.denied);
      }
      if (perm == LocationPermission.deniedForever) {
        return const LocationResult(LocationStatus.deniedForever);
      }
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      return LocationResult(LocationStatus.ok,
          LocationData(latitude: pos.latitude, longitude: pos.longitude));
    } catch (_) {
      return const LocationResult(LocationStatus.unavailable);
    }
  }

  @override
  Future<void> openSettings() async {
    await Geolocator.openAppSettings();
    await Geolocator.openLocationSettings();
  }
}
