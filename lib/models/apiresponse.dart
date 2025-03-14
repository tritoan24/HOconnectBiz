class ApiResponse<T> {
  final String? token;
  final String? message;
  final bool isSuccess;
  final T? data;
  final int? total;
  final String? idUser;

  ApiResponse({
    this.token,
    this.message,
    required this.isSuccess,
    this.data,
    this.total,
    this.idUser,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      token: json['token'],
      message: json['message'],
      isSuccess: json['status'] == "success",
      data: json['data'],
      total: json['total'],
      idUser: json['userID'] ?? '',
    );
  }

  static ApiResponse<T> success<T>(T data,
      {String? message, String? token, String? idUser}) {
    return ApiResponse<T>(
      isSuccess: true,
      data: data,
      message: message,
      token: token,
      idUser: idUser,
    );
  }

  static ApiResponse<T> error<T>(String message,
      {T? data, String? token, String? idUser}) {
    return ApiResponse<T>(
      isSuccess: false,
      message: message,
      data: data,
      token: token,
      idUser: idUser,
    );
  }
}
