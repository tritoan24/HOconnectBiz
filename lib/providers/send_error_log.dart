import 'dart:convert';
import 'package:clbdoanhnhansg/core/network/api_endpoints.dart';
import 'package:http/http.dart' as http;

Future<void> sendErrorLog({
  int level = 1,
  required String message,
  String additionalInfo = "",
}) async {
  final Map<String, dynamic> errorData = {
    "level": level,
    "message": message,
    "additionalInfo": additionalInfo,
  };

  try {
    final response = await http.put(
      Uri.parse("${ApiEndpoints.baseUrl}/log/create"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(errorData),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Báo cáo lỗi thành công: ${response.body}");
    } else {
      print("Lỗi khi gửi báo cáo: ${response.body}");
    }
  } catch (e) {
    print("Lỗi kết nối API: $e");
  }
}

