import 'auth_model.dart';

import 'auth_model.dart';

class IsJoin {
  String? id;
  String? postId;
  Author? user;
  String? author;
  bool? isJoin;
  Review? review;
  bool? isAccept;
  int? status;
  int? revenue;
  int? deduction;
  String? statusMessage;
  DateTime? createdAt;
  DateTime? updatedAt;

  IsJoin({
    this.id,
    this.postId,
    this.user,
    this.author,
    this.isJoin,
    this.review,
    this.isAccept,
    this.status,
    this.revenue,
    this.deduction,
    this.statusMessage,
    this.createdAt,
    this.updatedAt,
  });

  factory IsJoin.fromJson(Map<String, dynamic> json) {
    return IsJoin(
      id: json['_id'] ?? '',
      postId: json['post_id'] ?? '',
      user: json['user'] != null ? Author.fromJson(json['user']) : null,
      author: json['author'] ?? '',
      isJoin: json['is_join'] ?? false,
      review: json['review'] != null
          ? Review.fromJson(json['review'])
          : null, // Sửa lỗi kiểu dữ liệu
      isAccept: json['is_accept'] ?? false,
      status: json['status'] ?? 0,
      revenue: json['revenue'] ?? 0,
      deduction: json['deduction'] ?? 0,
      statusMessage: json['statusMessage'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'post_id': postId,
      'user': user?.toJson(),
      'author': author,
      'is_join': isJoin,
      'review': review?.toJson(), // Chuyển đổi `review` thành JSON đúng
      'is_accept': isAccept,
      'status': status,
      'revenue': revenue,
      'deduction': deduction,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'IsJoin(id: $id, postId: $postId, author: $author, isJoin: $isJoin, status: $status, statusMessage: $statusMessage)';
  }
}

class Review {
  final String id;
  final String content;
  final List<String> picked;
  final double star;

  Review({
    required this.id,
    required this.content,
    required this.picked,
    required this.star,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['_id'] ?? '',
      content: json['content'] ?? '',
      picked: (json['picked'] is List) ? List<String>.from(json['picked']) : [],
      star: (json['star'] is num) ? (json['star'] as num).toDouble() : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'content': content,
      'picked': picked,
      'star': star,
    };
  }
}
