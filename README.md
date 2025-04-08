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
[git clone https://github.com/your-username/clbdoanhnhansg.git](https://github.com/tritoan24/HOconnectBiz.git)
cd clbdoanhnhansg
```

### 2. Cài đặt dependencies

```bash
flutter pub get
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

