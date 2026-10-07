/// User-presentable failure from a place search service.
class PlaceSearchException implements Exception {
  final String message;
  const PlaceSearchException(this.message);
  @override
  String toString() => message;
}
