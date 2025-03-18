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

## Hệ thống báo cáo lỗi

Ứng dụng tích hợp hệ thống theo dõi và báo cáo lỗi tự động, giúp phát hiện sớm các vấn đề và báo cáo qua Telegram để đội phát triển phản ứng nhanh chóng.

### Cài đặt

```bash
flutter pub add device_info_plus:^9.1.1 package_info_plus:^8.3.0 sentry_flutter:^7.15.0 flutter_logs:^2.1.11
```

### Tính năng chính

- **Ghi log tự động**: Theo dõi và lưu thông tin lỗi, yêu cầu API, hiệu suất
- **Thu thập thông tin thiết bị**: Tự động thu thập thông tin thiết bị và phiên bản ứng dụng
- **Phân loại mức độ lỗi**: 3 cấp độ từ thấp đến cao
- **Thông báo Telegram**: Gửi thông báo tức thời khi có lỗi nghiêm trọng
- **Lưu log cục bộ**: Hỗ trợ xuất file log để kiểm tra

### Sử dụng hệ thống báo cáo lỗi

#### 1. Báo cáo lỗi cơ bản:

```dart
import 'package:clbdoanhnhansg/providers/send_error_log.dart';

sendErrorLog(
  level: 2, // Mức độ: 1=Thông thường, 2=Quan trọng, 3=Nghiêm trọng
  message: "Mô tả lỗi",
  additionalInfo: "Thông tin chi tiết",
);
```

#### 2. Sử dụng ErrorReporter (Khuyến nghị):

```dart
import 'package:clbdoanhnhansg/core/utils/error_reporter.dart';

// Báo cáo lỗi API
ErrorReporter.reportApiError(
  'api/endpoint', 
  exception, 
  stackTrace
);

// Báo cáo lỗi dữ liệu
ErrorReporter.reportDataError(
  'DataSource', 
  'Lỗi phân tích dữ liệu', 
  exception, 
  stackTrace
);

// Báo cáo lỗi nghiêm trọng
ErrorReporter.reportCritical(
  'AuthService', 
  'Lỗi xác thực', 
  exception, 
  stackTrace
);

// Báo cáo vấn đề hiệu suất
ErrorReporter.reportPerformanceIssue(
  'LoadData', 
  4500, // Thời gian (ms)
  details: 'Chi tiết'
);
```

#### 3. Ghi log với AppLogger:

```dart
import 'package:clbdoanhnhansg/core/utils/app_logger.dart';

// Ghi log thông tin
AppLogger().info("Tag", "SubTag", "Thông điệp");

// Ghi log cảnh báo
AppLogger().warn("Tag", "SubTag", "Cảnh báo");

// Ghi log lỗi
AppLogger().error(
  "Tag", 
  "SubTag", 
  "Lỗi", 
  error: exception, 
  stackTrace: stackTrace
);

// Ghi log lỗi nghiêm trọng
AppLogger().fatal(
  "Tag", 
  "SubTag", 
  "Lỗi nghiêm trọng", 
  error: exception, 
  stackTrace: stackTrace
);
```

#### 4. Công cụ gỡ lỗi (Chỉ dùng trong môi trường phát triển):

```dart
import 'package:clbdoanhnhansg/widgets/error_reporting_panel.dart';

// Thêm vào Stack trong màn hình
Stack(
  children: [
    // UI chính
    // ...
    
    // Công cụ gỡ lỗi (chỉ hiển thị trong debug)
    ErrorReportingPanel(),
  ],
)
```

### Cấu hình

Tệp cấu hình `lib/core/utils/error_reporting_config.dart` cho phép tùy chỉnh các thiết lập báo cáo lỗi:

- Kích hoạt/vô hiệu hóa báo cáo theo loại
- Đặt ngưỡng hiệu suất
- Cấu hình mức lọc lỗi
- Giới hạn số lượng báo cáo

### Khắc phục sự cố

Nếu việc báo cáo lỗi không hoạt động:

1. Kiểm tra kết nối mạng
2. Đảm bảo endpoint `/log/create` đang hoạt động
3. Kiểm tra các package đã được cài đặt đúng cách
4. Dùng `ErrorReportingPanel` để kiểm tra hệ thống