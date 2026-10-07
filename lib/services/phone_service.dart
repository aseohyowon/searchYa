import 'package:url_launcher/url_launcher.dart';

/// Opens the OS dialer; the app never places the call itself.
abstract class PhoneService {
  /// Returns false if the dialer could not be opened.
  Future<bool> call(String phoneNumber);
}

class UrlLauncherPhoneService implements PhoneService {
  @override
  Future<bool> call(String phoneNumber) async {
    final cleaned = phoneNumber.replaceAll(RegExp(r'[^0-9+*#]'), '');
    if (cleaned.isEmpty) return false;
    try {
      return await launchUrl(Uri(scheme: 'tel', path: cleaned));
    } catch (_) {
      return false;
    }
  }
}
