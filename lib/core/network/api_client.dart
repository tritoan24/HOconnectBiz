import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';
import '../../providers/send_error_log.dart';
import 'api_endpoints.dart';
import 'package:clbdoanhnhansg/widgets/alert_widget_noti.dart';

class ApiClient {
  static final String baseUrl = ApiEndpoints.baseUrl;

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
    
    // Sử dụng SharedPreferences thay vì FlutterSecureStorage
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    final headers = {
      'Accept': 'application/json',
      if (token != null) 'Authorization': token,
    };

    debugPrint("🔹 [API REQUEST] $method: $url");
    debugPrint("🔹 Headers: $headers");
    if (body != null) {
      debugPrint("🔹 Body: $body");
    }

    try {
      late http.Response response;
      final Stopwatch stopwatch = Stopwatch()..start();

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
                  String errorMsg =
                      'Định dạng file không được hỗ trợ. Chỉ chấp nhận jpg, jpeg, png, gif, webp, bmp';
                  sendErrorLog(
                    level: 1,
                    message: errorMsg,
                    additionalInfo: "File: $fileName, Extension: $fileExt",
                  );
                  throw Exception(errorMsg);
              }

              var stream = http.ByteStream(file.openRead());
              var length = await file.length();

              debugPrint('📤 Uploading file: $fileName with type: $mimeType');

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
        try {
          final streamedResponse = await request.send();
          response = await http.Response.fromStream(streamedResponse);
        } catch (e, stack) {
          sendErrorLog(
            level: 2,
            message: "Lỗi khi gửi multipart request: $method $url",
            additionalInfo: "${e.toString()} - Stack: $stack",
          );
          rethrow;
        }
      } else {
        switch (method) {
          case 'POST':
            try {
              response = await http.post(
                Uri.parse(url),
                headers: {...headers, 'Content-Type': 'application/json'},
                body: jsonEncode(body),
              );
            } catch (e, stack) {
              sendErrorLog(
                level: 2,
                message: "Lỗi khi gửi POST request: $url",
                additionalInfo: "${e.toString()} - Stack: $stack - Body: $body",
              );
              rethrow;
            }
            break;
          case 'GET':
            try {
              final client = http.Client();
              var request = http.Request('GET', Uri.parse(url));
              request.headers.addAll(headers);
              request.followRedirects = false;
              
              final streamedResponse = await client.send(request);
              if (streamedResponse.statusCode == 301 || streamedResponse.statusCode == 302) {
                // Xử lý redirect thủ công
                final location = streamedResponse.headers['location'];
                if (location != null) {
                  final redirectResponse = await http.get(Uri.parse(location), headers: headers);
                  response = redirectResponse;
                } else {
                  throw Exception("Redirect URL không hợp lệ");
                }
              } else {
                response = await http.Response.fromStream(streamedResponse);
              }
              client.close();
            } catch (e, stack) {
              sendErrorLog(
                level: 2,
                message: "Lỗi khi gửi GET request: $url",
                additionalInfo: "${e.toString()} - Stack: $stack",
              );
              rethrow;
            }
            break;
          case 'DELETE':
            try {
              response = await http.delete(
                Uri.parse(url),
                headers: {...headers, 'Content-Type': 'application/json'},
                body: body != null ? jsonEncode(body) : null,
              );
            } catch (e, stack) {
              sendErrorLog(
                level: 2,
                message: "Lỗi khi gửi DELETE request: $url",
                additionalInfo: "${e.toString()} - Stack: $stack - Body: $body",
              );
              rethrow;
            }
            break;
          case 'PATCH':
            try {
              response = await http.patch(
                Uri.parse(url),
                headers: {...headers, 'Content-Type': 'application/json'},
                body: body != null ? jsonEncode(body) : null,
              );
            } catch (e, stack) {
              sendErrorLog(
                level: 2,
                message: "Lỗi khi gửi PATCH request: $url",
                additionalInfo: "${e.toString()} - Stack: $stack - Body: $body",
              );
              rethrow;
            }
            break;
          default:
            String errorMsg = "Phương thức HTTP không hợp lệ: $method";
            sendErrorLog(
              level: 1,
              message: errorMsg,
              additionalInfo: "URL: $url, Method: $method",
            );
            throw Exception(errorMsg);
        }
      }

      stopwatch.stop();

      // Log các request chậm
      if (stopwatch.elapsedMilliseconds > 3000) {
        // Hơn 3 giây
        sendErrorLog(
          level: 1,
          message: "API gọi chậm: $method $url",
          additionalInfo:
              "Thời gian: ${stopwatch.elapsedMilliseconds}ms, Status: ${response.statusCode}",
        );
      }

      debugPrint(" [API RESPONSE] Status Code: ${response.statusCode}");
      debugPrint(" Response Body: ${response.body}");

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        // Lỗi phía client (400-499)
        sendErrorLog(
          level: 2,
          message: "Lỗi client API: $method $url",
          additionalInfo:
              "Status: ${response.statusCode}, Body: ${response.body}",
        );
        throw HttpException(response.body);
      } else if (response.statusCode >= 500) {
        // Lỗi phía server (500+)
        sendErrorLog(
          level: 3, // Nghiêm trọng
          message: "Lỗi server API: $method $url",
          additionalInfo:
              "Status: ${response.statusCode}, Body: ${response.body}",
        );
        throw HttpException(response.body);
      } else {
        throw HttpException(response.body);
      }
    } catch (e, stackTrace) {
      debugPrint(" [API ERROR] Lỗi khi gọi API: $e");

      // Kiểm tra nếu là HttpException (lỗi từ API)
      if (e is HttpException) {
        try {
          final errorData = e.toString();
          final Map<String, dynamic> errorMap = Map<String, dynamic>.from(
            jsonDecode(errorData.replaceAll('HttpException: ', '')),
          );
          // final String errorMessage =
          //     errorMap['message'] as String? ?? "Lỗi không xác định";
          // _showErrorSnackbar(context, errorMessage);
        } catch (parseError) {
          _showErrorSnackbar(context, "Lỗi kết nối đến máy chủ!");
        }
      } else if (e is SocketException) {
        _showErrorSnackbar(context,
            "Không thể kết nối đến máy chủ.\n Kiểm tra kết nối internet!");
      } else if (e is TimeoutException) {
        _showErrorSnackbar(context, "Yêu cầu hết thời gian. Vui lòng thử lại!");
      } else {
        _showErrorSnackbar(context, "Lỗi kết nối đến máy chủ!");
      }

      // Phân loại và báo cáo lỗi chi tiết hơn
      if (e is SocketException) {
        sendErrorLog(
          level: 2,
          message: "Lỗi kết nối: $method $url",
          additionalInfo: "${e.toString()} - Stack: $stackTrace",
        );
      } else if (e is TimeoutException) {
        sendErrorLog(
          level: 2,
          message: "API timeout: $method $url",
          additionalInfo: "${e.toString()} - Stack: $stackTrace",
        );
      } else if (e is FormatException) {
        sendErrorLog(
          level: 2,
          message: "Lỗi định dạng JSON: $method $url",
          additionalInfo: "${e.toString()} - Stack: $stackTrace",
        );
      } else {
        sendErrorLog(
          level: 1,
          message: "Lỗi API không xác định: $method $url",
          additionalInfo: "${e.toString()} - Stack: $stackTrace",
        );
      }

      rethrow;
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
          String endpoint, BuildContext context) =>
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
    
    // Sử dụng SharedPreferences để lấy token
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': token,
    };

    debugPrint("🔹 [API REQUEST] PUT JSON: $url");
    debugPrint("🔹 Headers: $headers");
    if (body != null) {
      debugPrint("🔹 Body: $body");
      String jsonString = jsonEncode(body);
      debugPrint("🔹 JSON String: $jsonString");
    }

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );

      debugPrint(" [API RESPONSE] Status Code: ${response.statusCode}");
      debugPrint(" Response Body: ${response.body}");

      if (response.statusCode >= 200 && response.statusCode < 500) {
        return jsonDecode(response.body);
      } else {
        throw HttpException(response.body);
      }
    } catch (e) {
      debugPrint(" [API ERROR] Lỗi khi gọi API: $e");
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
    dynamic body,
  }) async {
    final String url =
        endpoint.startsWith('/') ? baseUrl + endpoint : '$baseUrl/$endpoint';
    
    // Sử dụng SharedPreferences để lấy token
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': token,
    };

    debugPrint("🔹 [API REQUEST] PATCH JSON: $url");
    debugPrint("🔹 Headers: $headers");
    if (body != null) {
      debugPrint("🔹 Body: $body");
      String jsonString = jsonEncode(body);
      debugPrint("🔹 JSON String: $jsonString");
    }

    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );

      debugPrint(" [API RESPONSE] Status Code: ${response.statusCode}");
      debugPrint(" Response Body: ${response.body}");

      if (response.statusCode >= 200 && response.statusCode < 500) {
        return jsonDecode(response.body);
      } else {
        throw HttpException(response.body);
      }
    } catch (e) {
      debugPrint(" [API ERROR] Lỗi khi gọi API: $e");
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
