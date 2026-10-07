# searchYa
인근 가게 검색 전화가능

## 개발 진행 (STEP 1 완료)
Flutter 미설치 환경에서 수동 구성됨. 플랫폼 폴더 생성 후 실행:
```
flutter create . --org com.searchya --project-name search_ya
flutter pub get
flutter test
flutter run
```
API Key는 `.env.example`을 `.env`로 복사해 설정 (`.env`는 git 무시).

## STEP 2: 위치 권한
`flutter create .` 이후 플랫폼 설정을 추가하세요.
- Android `android/app/src/main/AndroidManifest.xml` (`<manifest>` 안):
  `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION` uses-permission
- iOS `ios/Runner/Info.plist`: `NSLocationWhenInUseUsageDescription` = "주변 매장을 찾기 위해 현재 위치 권한이 필요합니다."
- 에뮬레이터에서 위치 권한 허용/거부/GPS 끄기로 각 상태를 확인할 수 있고, `flutter test`로 위젯 테스트(허용/거부/영구거부/GPS 실패)를 실행합니다.
