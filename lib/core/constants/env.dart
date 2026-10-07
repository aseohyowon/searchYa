/// API keys are injected at build time, never hard-coded:
///   flutter run --dart-define=KAKAO_REST_API_KEY=xxxx
/// (see .env.example and README). Empty => the app falls back to mock data.
class Env {
  static const kakaoRestApiKey =
      String.fromEnvironment('KAKAO_REST_API_KEY', defaultValue: '');
  static bool get hasKakaoKey => kakaoRestApiKey.isNotEmpty;
}
