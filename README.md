# searchYa
인근 가게 검색 전화가능

# SearchYa — 위치 기반 매장 검색 앱 (Flutter, iOS/Android)

앱을 열면 위치 권한 → 주변 매장을 거리순 표시 → 매장명 검색 → 상세 → 전화 앱 실행.

## 구조
`lib/core`(상수/유틸) · `models` · `services`(Location/PlaceSearch/Phone/Map, 인터페이스+구현) · `repositories`(거리 계산·정렬) · `screens` · `widgets`

## 실행 방법
```
flutter create . --org com.searchya --project-name search_ya   # 최초 1회: android/ ios/ 생성 (기존 lib/ 유지)
flutter pub get
flutter test
flutter run                                          # API Key 없으면 Mock 데이터
flutter run --dart-define=KAKAO_REST_API_KEY=발급키    # Kakao Local API 사용
flutter build apk --dart-define=KAKAO_REST_API_KEY=... # Android
flutter build ios --dart-define=KAKAO_REST_API_KEY=... # iOS (Xcode 필요)
```
API Key는 코드에 넣지 않고 `--dart-define`으로 주입합니다(`.env.example` 참고, `.env`는 git 제외). Kakao REST API 키는 https://developers.kakao.com 에서 발급합니다.

## API 선택: Kakao Local API
국내 상점 데이터·전화번호 제공, 거리순 정렬(`sort=distance`) 지원, REST 키만으로 간단히 사용 가능. Google Places는 한국 로컬 데이터가 상대적으로 약하고 과금이 있으며, Naver는 장소 검색의 전화번호/좌표 제공이 제한적입니다. `PlaceSearchService` 인터페이스 덕분에 다른 API로 교체 가능합니다. (Kakao는 별도 상세 API가 없어 검색 응답을 상세로 사용합니다.)

## 플랫폼 설정 (`flutter create .` 이후 반영)
**Android** `android/app/src/main/AndroidManifest.xml`의 `<manifest>` 안:
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.INTERNET"/>
<queries>
  <intent><action android:name="android.intent.action.DIAL"/><data android:scheme="tel"/></intent>
  <intent><action android:name="android.intent.action.VIEW"/><data android:scheme="https"/></intent>
</queries>
```
**iOS** `ios/Runner/Info.plist`:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>주변 매장을 찾기 위해 현재 위치 권한이 필요합니다.</string>
<key>LSApplicationQueriesSchemes</key>
<array><string>tel</string><string>https</string></array>
```
iOS 시뮬레이터는 전화 앱이 없어 `tel:`이 열리지 않을 수 있으므로 실기기에서 확인하세요.

## 테스트 시나리오
`flutter test`가 위치 허용/거부/영구 거부/GPS 실패, 기본 목록, 키워드 검색, 결과 없음, 네트워크 오류, 전화번호 없음, 전화 버튼, 상세 화면, Kakao 응답 파싱을 검증합니다. iOS/Android 동작은 각 실기기/에뮬레이터에서 수동 확인합니다.
