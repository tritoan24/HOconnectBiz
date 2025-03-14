import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http_parser/http_parser.dart';
import '../../providers/send_error_log.dart';
import 'api_endpoints.dart';
import 'package:clbdoanhnhansg/widgets/alert_widget_noti.dart';

class ApiClient {
  static final String baseUrl = ApiEndpoints.baseUrl;
  final storage = FlutterSecureStorage();

  void _showErrorSnackbar(BuildContext context, String message) {
    CustomAlertNoti.show(
      context,
      message,
      backgroundColor: Colors.red,
    );
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String endpoint,
    BuildContext context, {
    Map<String, dynamic>? body,
    Map<String, List<File>>? files,
  }) async {
    final String url =
        endpoint.startsWith('/') ? baseUrl + endpoint : '$baseUrl/$endpoint';
    String? token = await storage.read(key: 'auth_token');

    final headers = {
      'Accept': 'application/json',
      if (token != null) 'Authorization': token,
    };

    print("🔹 [API REQUEST] $method: $url");
    print("🔹 Headers: $headers");
    if (body != null) {
      print("🔹 Body: $body");
    }

    try {
      late http.Response response;

      if (method == 'PUT' ||
          method == 'PATCH' && (files != null || body != null)) {
        // Tạo multipart request
        var request = http.MultipartRequest(method, Uri.parse(url));
        request.headers.addAll(headers);

        // Thêm các trường dữ liệu
        if (body != null) {
          body.forEach((key, value) {
            if (value != null) {
              if (value is List) {
                // Xử lý array như product
                request.fields[key] = jsonEncode(value);
              } else {
                request.fields[key] = value.toString();
              }
            }
          });
        }

        // Thêm files
        if (files != null) {
          files.forEach((fieldName, fileList) async {
            for (var file in fileList) {
              String fileName = file.path.split('/').last;
              String mimeType = '';
              String fileExt = fileName.split('.').last.toLowerCase();

              // Xác định MIME type dựa vào phần mở rộng
              switch (fileExt) {
                case 'jpg':
                case 'jpeg':
                  mimeType = 'image/jpeg';
                  break;
                case 'png':
                  mimeType = 'image/png';
                  break;
                case 'gif':
                  mimeType = 'image/gif';
                  break;
                case 'webp':
                  mimeType = 'image/webp';
                  break;
                case 'bmp':
                  mimeType = 'image/bmp';
                  break;
                default:
                  throw Exception(
                      'Định dạng file không được hỗ trợ. Chỉ chấp nhận jpg, jpeg, png, gif, webp, bmp');
              }

              var stream = http.ByteStream(file.openRead());
              var length = await file.length();

              print('📤 Uploading file: $fileName with type: $mimeType');

              var multipartFile = http.MultipartFile(
                fieldName.isEmpty || fieldName == null ? "album" : fieldName,
                stream,
                length,
                filename: fileName,
                contentType: MediaType.parse(mimeType),
              );

              request.files.add(multipartFile);
            }
          });
        }
        // Gửi request và chuyển đổi response
        final streamedResponse = await request.send();
        response = await http.Response.fromStream(streamedResponse);
      } else {
        switch (method) {
          case 'POST':
            response = await http.post(
              Uri.parse(url),
              headers: {...headers, 'Content-Type': 'application/json'},
              body: jsonEncode(body),
            );
            break;
          case 'GET':
            response = await http.get(Uri.parse(url), headers: headers);
            break;
          case 'DELETE':
            response = await http.delete(
              Uri.parse(url),
              headers: {...headers, 'Content-Type': 'application/json'},
              body: body != null ? jsonEncode(body) : null,
            );
            break;
          case 'PATCH':
            response = await http.patch(
              Uri.parse(url),
              headers: {...headers, 'Content-Type': 'application/json'},
              body: body != null ? jsonEncode(body) : null,
            );
            break;
          default:
            throw Exception("Phương thức HTTP không hợp lệ");
        }
      }

      print(" [API RESPONSE] Status Code: ${response.statusCode}");
      print(" Response Body: ${response.body}");

      if (response.statusCode >= 200 && response.statusCode < 500) {
        return jsonDecode(response.body);
      } else {
        throw HttpException(response.body);
      }
    } catch (e) {
      print(" [API ERROR] Lỗi khi gọi API: $e");
      _showErrorSnackbar(context, "Lỗi kết nối đến máy chủ!");
      sendErrorLog(
        level: 1,
        message: "Doanh Nghiệp Lỗi: Lỗi khi gọi API: " + e.toString(),
        additionalInfo: e.toString(),
      );
      rethrow; // Ném lỗi để xử lý ở tầng trên
    }
  }

  Future<Map<String, dynamic>> postRequest(
    String endpoint,
    Map<String, dynamic> body,
    BuildContext context,
  ) =>
      _request('POST', endpoint, context, body: body);

  Future<Map<String, dynamic>> putRequest(
    String endpoint,
    BuildContext context, {
    Map<String, dynamic>? body,
    Map<String, List<File>>? files,
  }) =>
      _request('PUT', endpoint, context, body: body, files: files);

  Future<Map<String, dynamic>> getRequest(
    String endpoint,
    BuildContext context,
  ) =>
      _request('GET', endpoint, context);

  Future<Map<String, dynamic>> deleteRequest(
    String endpoint,
    BuildContext context, {
    Map<String, dynamic>? body,
  }) =>
      _request('DELETE', endpoint, context, body: body);

  Future<Map<String, dynamic>> patchRequest(
    String endpoint,
    BuildContext context, {
    Map<String, dynamic>? body,
    Map<String, List<File>>? files,
  }) =>
      _request('PATCH', endpoint, context, body: body, files: files);

  Future<Map<String, dynamic>> putJsonRequest(
    String endpoint,
    BuildContext context, {
    Map<String, dynamic>? body,
  }) async {
    final String url =
        endpoint.startsWith('/') ? baseUrl + endpoint : '$baseUrl/$endpoint';
    String? token = await storage.read(key: 'auth_token');

    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': token,
    };

    print("🔹 [API REQUEST] PUT JSON: $url");
    print("🔹 Headers: $headers");
    if (body != null) {
      print("🔹 Body: $body");
      String jsonString = jsonEncode(body);
      print("🔹 JSON String: $jsonString");
    }

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );

      print(" [API RESPONSE] Status Code: ${response.statusCode}");
      print(" Response Body: ${response.body}");

      if (response.statusCode >= 200 && response.statusCode < 500) {
        return jsonDecode(response.body);
      } else {
        throw HttpException(response.body);
      }
    } catch (e) {
      print(" [API ERROR] Lỗi khi gọi API: $e");
      _showErrorSnackbar(context, "Lỗi kết nối đến máy chủ!");
      sendErrorLog(
        level: 1,
        message: "Doanh Nghiệp Lỗi: Lỗi khi gọi API: " + e.toString(),
        additionalInfo: e.toString(),
      );
      rethrow;
    }
  }

  Future<Map<String, dynamic>> pacthJsonRequest(
    String endpoint,
    BuildContext context, {
    Map<String, dynamic>? body,
  }) async {
    final String url =
        endpoint.startsWith('/') ? baseUrl + endpoint : '$baseUrl/$endpoint';
    String? token = await storage.read(key: 'auth_token');

    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': token,
    };

    print("🔹 [API REQUEST] PATCH JSON: $url");
    print("🔹 Headers: $headers");
    if (body != null) {
      print("🔹 Body: $body");
      String jsonString = jsonEncode(body);
      print("🔹 JSON String: $jsonString");
    }

    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );

      print(" [API RESPONSE] Status Code: ${response.statusCode}");
      print(" Response Body: ${response.body}");

      if (response.statusCode >= 200 && response.statusCode < 500) {
        return jsonDecode(response.body);
      } else {
        throw HttpException(response.body);
      }
    } catch (e) {
      print(" [API ERROR] Lỗi khi gọi API: $e");
      _showErrorSnackbar(context, "Lỗi kết nối đến máy chủ!");
      sendErrorLog(
        level: 1,
        message: "Doanh Nghiệp Lỗi: Lỗi khi gọi API: " + e.toString(),
        additionalInfo: e.toString(),
      );
      rethrow;
    }
  }
}

