class BusinessModel {
  final String id;
  final String title;
  final bool isDisable;
  final int version;

  BusinessModel({
    required this.id,
    required this.title,
    required this.isDisable,
    required this.version,
  });

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    return BusinessModel(
      id: json['_id'] ?? '', // Nếu null, gán chuỗi rỗng để tránh lỗi
      title: json['title'] ?? 'Không có tên', // Nếu null, gán mặc định
      isDisable: json['is_disable'] ?? false, // Nếu null, mặc định là false
      version: json['__v'] ?? 0, // Nếu null, mặc định là 0
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'is_disable': isDisable,
      '__v': version,
    };
  }
}
