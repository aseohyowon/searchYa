import 'package:url_launcher/url_launcher.dart';

/// Shows a coordinate in an external map app / browser.
abstract class MapService {
  Future<bool> openMap(double lat, double lng, String label);
}

class UrlLauncherMapService implements MapService {
  @override
  Future<bool> openMap(double lat, double lng, String label) async {
    final uri = Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': '$lat,$lng',
    });
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
