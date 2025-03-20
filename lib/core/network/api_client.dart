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
    
    // Lấy token từ SharedPreferences và kiểm tra token
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');
    
    if (token != null && token.isEmpty) {
      debugPrint("⚠️ Token rỗng được phát hiện, xóa token");
      await prefs.remove('auth_token');
      token = null;
    }

    final headers = {
      'Accept': 'application/json',
      if (token != null) 'Authorization': token,
    };

    debugPrint("🔹 [API REQUEST] $method: $url");
    debugPrint("🔹 Headers: $headers");
    if (body != null) {
      debugPrint("🔹 Body: $body");
    }

    // Số lần thử lại tối đa khi gặp lỗi mạng
    const int maxRetries = 2;
    int retryCount = 0;
    
    while (true) {
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
            // Chuyển đổi giá trị numerics thành chuỗi
            body.forEach((key, value) {
              request.fields[key] = value?.toString() ?? '';
            });
          }

          // Thêm các file
          if (files != null) {
            for (final entry in files.entries) {
              final fieldName = entry.key;
              final fileList = entry.value;

              for (final file in fileList) {
                final fileStream = http.ByteStream(file.openRead());
                final fileLength = await file.length();
                // Xác định MediaType dựa trên đuôi file
                final extension = file.path.split('.').last.toLowerCase();
                final fileType = _getFileType(extension);

                final multipartFile = http.MultipartFile(
                  fieldName,
                  fileStream,
                  fileLength,
                  filename: file.path.split('/').last,
                  contentType: MediaType(fileType.item1, fileType.item2),
                );
                request.files.add(multipartFile);
              }
            }
          }

          // Gửi request
          final streamedResponse = await request.send();
          response = await http.Response.fromStream(streamedResponse);
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
                    debugPrint("🔄 Đang xử lý chuyển hướng đến: $location");
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
                  additionalInfo: "${e.toString()} - Stack: $stack",
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
                  additionalInfo: "${e.toString()} - Stack: $stack",
                );
                rethrow;
              }
              break;
            default:
              throw UnsupportedError('$method không được hỗ trợ');
          }
        }

        stopwatch.stop();
        debugPrint("⏱️ Thời gian request: ${stopwatch.elapsedMilliseconds}ms");
        debugPrint("📊 [API RESPONSE] Status Code: ${response.statusCode}");
        
        // Kiểm tra xem response body có phải là JSON hợp lệ không
        if (response.body.isNotEmpty) {
          try {
            final jsonBody = jsonDecode(response.body);
            debugPrint("📄 Response Body: $jsonBody");
            
            if (response.statusCode >= 200 && response.statusCode < 300) {
              return jsonBody;
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
          } catch (e) {
            debugPrint("⚠️ Lỗi xử lý JSON response: $e");
            throw Exception("Lỗi xử lý dữ liệu từ server: ${response.body}");
          }
        } else {
          debugPrint("⚠️ Response body rỗng");
          if (response.statusCode >= 200 && response.statusCode < 300) {
            // Trả về đối tượng trống nếu body rỗng nhưng status code OK
            return {};
          } else {
            throw Exception("Server trả về dữ liệu rỗng với mã ${response.statusCode}");
          }
        }
      } catch (e, stackTrace) {
        // Kiểm tra xem lỗi có phải là lỗi kết nối không
        if (e is SocketException && retryCount < maxRetries) {
          retryCount++;
          debugPrint("🔄 Thử lại kết nối lần $retryCount sau lỗi: $e");
          // Đợi một chút trước khi thử lại
          await Future.delayed(Duration(seconds: 1 * retryCount));
          continue; // Tiếp tục vòng lặp để thử lại
        }
        
        debugPrint("❌ [API ERROR] Lỗi khi gọi API: $e");
        _showErrorSnackbar(context, "Lỗi kết nối đến máy chủ!");
        sendErrorLog(
          level: 1,
          message: "Doanh Nghiệp Lỗi: Lỗi khi gọi API: " + e.toString(),
          additionalInfo: "${e.toString()}\n${stackTrace.toString()}",
        );
        rethrow;
      }
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

  // Lấy loại file dựa trên phần mở rộng
  Tuple<String, String> _getFileType(String extension) {
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return Tuple('image', 'jpeg');
      case 'png':
        return Tuple('image', 'png');
      case 'gif':
        return Tuple('image', 'gif');
      case 'webp':
        return Tuple('image', 'webp');
      case 'bmp':
        return Tuple('image', 'bmp');
      case 'pdf':
        return Tuple('application', 'pdf');
      case 'doc':
      case 'docx':
        return Tuple('application', 'msword');
      case 'xls':
      case 'xlsx':
        return Tuple('application', 'vnd.ms-excel');
      default:
        return Tuple('application', 'octet-stream');
    }
  }
}

// Lớp đơn giản cho cặp giá trị
class Tuple<T1, T2> {
  final T1 item1;
  final T2 item2;
  
  Tuple(this.item1, this.item2);
}
