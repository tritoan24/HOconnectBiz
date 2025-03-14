class PostResponse {
  final String? token;
  final String? message;
  final bool isSuccess;
  final dynamic data;

  PostResponse({this.token, this.message, required this.isSuccess, this.data});

  factory PostResponse.fromJson(Map<String, dynamic> json) {
    return PostResponse(
      token: json['token'],
      message: json['message'],
      isSuccess: json['status'] == "success",
      data: json['data'],
    );
  }
}
