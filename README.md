# CLB Doanh Nhân SG

Ứng dụng di động cho CLB Doanh Nhân SG được phát triển bằng Flutter.

## Yêu cầu hệ thống

- Flutter SDK: ^3.5.1
- Dart SDK: ^3.5.1
- Android Studio / VS Code với Flutter plugin
- Git
- JDK 17 trở lên (cho Android development)
- Xcode (cho iOS development, chỉ macOS)

## Cài đặt

### 1. Clone dự án

```bash
git clone https://github.com/your-username/clbdoanhnhansg.git
cd clbdoanhnhansg
```

### 2. Cài đặt dependencies

```bash
flutter pub get
```

### 3. Cấu hình môi trường

1. Tạo file `.env` từ file mẫu:
```bash
cp .env.example .env
```

2. Cập nhật các biến môi trường trong file `.env`:
```env
CLIENT_ID_IOS=your_ios_client_id
GOOGLE_CLIENT_ID=your_google_client_id
FACEBOOK_APP_ID=your_facebook_app_id
API_BASE_URL=your_api_base_url
ONESIGNAL_APP_ID=your_onesignal_app_id
SOCKET_SERVER_URL=your_socket_server_url
APP_NAME=CLB Doanh Nhân SG
APP_VERSION=1.0.0
DEBUG_MODE=true
```

### 4. Cấu hình Firebase (nếu cần)

1. Tải file `google-services.json` từ Firebase Console và đặt vào thư mục `android/app/`
2. Tải file `GoogleService-Info.plist` từ Firebase Console và đặt vào thư mục `ios/Runner/`

### 5. Cấu hình Android

1. Tạo file `android/key.properties` với nội dung:
```properties
storePassword=<your_keystore_password>
keyPassword=<your_key_password>
keyAlias=<your_key_alias>
storeFile=<location_of_your_keystore_file>
```

2. Tạo keystore cho signing (nếu chưa có):
```bash
keytool -genkey -v -keystore android/app/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

## Build ứng dụng

### Build cho Android

1. Build debug:
```bash
flutter build apk --debug
```

2. Build release:
```bash
flutter build apk --release
```

3. Build app bundle cho Google Play:
```bash
flutter build appbundle
```

File APK sẽ được tạo tại:
- Debug: `build/app/outputs/flutter-apk/app-debug.apk`
- Release: `build/app/outputs/flutter-apk/app-release.apk`
- App Bundle: `build/app/outputs/bundle/release/app-release.aab`

### Build cho iOS (chỉ macOS)

1. Build debug:
```bash
flutter build ios --debug
```

2. Build release:
```bash
flutter build ios --release
```

## Chạy ứng dụng

### Chạy trên máy ảo hoặc thiết bị thật

```bash
flutter run
```

### Chạy với các tùy chọn

- Chạy với hot reload:
```bash
flutter run --hot
```

- Chạy với hot restart:
```bash
flutter run --hot-restart
```

- Chạy với profile mode:
```bash
flutter run --profile
```

## Cấu trúc dự án

```
lib/
├── config/           # Các file cấu hình
├── core/            # Core functionality
├── features/        # Các tính năng của ứng dụng
├── shared/          # Shared components
└── main.dart        # Entry point
```

## Xử lý lỗi thường gặp

1. **Lỗi Gradle sync**
   - Chạy `flutter clean`
   - Xóa thư mục `.gradle` trong `android/`
   - Chạy lại `flutter pub get`

2. **Lỗi Pod install (iOS)**
   - Chạy `cd ios && pod install && cd ..`

3. **Lỗi build**
   - Chạy `flutter clean`
   - Xóa thư mục `build/`
   - Chạy lại `flutter pub get`
   - Thử build lại

## Liên hệ

Nếu bạn gặp bất kỳ vấn đề nào, vui lòng tạo issue trong repository hoặc liên hệ với team phát triển.
