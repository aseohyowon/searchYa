/// A store/place returned by a place search service.
class Place {
  final String id;
  final String name;
  final String address;
  final String? phone;
  final double latitude;
  final double longitude;
  final String? openingHours;

  /// Distance from the user in meters; filled in by the repository.
  final double? distanceMeters;

  const Place({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.phone,
    this.openingHours,
    this.distanceMeters,
  });

  bool get hasPhone => phone != null && phone!.trim().isNotEmpty;

  Place copyWith({double? distanceMeters}) => Place(
        id: id,
        name: name,
        address: address,
        latitude: latitude,
        longitude: longitude,
        phone: phone,
        openingHours: openingHours,
        distanceMeters: distanceMeters ?? this.distanceMeters,
      );
}
