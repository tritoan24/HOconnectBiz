class Rating {
  final String? id;
  final String postId;
  final String? userId;
  final List<Criteria>? picked;
  final int star;
  final String content;
  final String? createdAt;
  final String? updatedAt;

  Rating({
    this.id,
    required this.postId,
    this.userId,
    required this.picked,
    required this.star,
    required this.content,
    this.createdAt,
    this.updatedAt,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      id: json['_id']?.toString(), // Chuyển về String nếu null
      postId: json['post_id'] ?? '', // Nếu null thì dùng chuỗi rỗng
      userId: json['user']?.toString(),
      picked: (json['picked'] as List<dynamic>?)
              ?.map((item) => Criteria.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [], // Đảm bảo không bị null
      star: (json['star'] is int)
          ? json['star']
          : (json['star'] as num).toInt(), // Chuyển đổi nếu là double
      content: json['content'] ?? '',
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'picked': picked,
      'star': star,
      'content': content,
    };
  }
}

class Criteria {
  final String id;
  final String title;
  final String description;
  final bool? status;

  Criteria({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
  });

  factory Criteria.fromJson(Map<String, dynamic> json) {
    return Criteria(
      id: json['_id'].toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] is bool ? json['status'] : false,
    );
  }
}
