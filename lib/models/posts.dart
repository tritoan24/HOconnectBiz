import 'package:clbdoanhnhansg/models/product_model.dart';
import 'package:clbdoanhnhansg/models/business_model.dart';

import 'auth_model.dart';
import 'is_join_model.dart';

class Posts {
  String? id;
  String? title;
  int? category;
  List<BusinessModel>? business;
  List<ProductModel>? product;
  String? content;
  String? thumbnail;
  List<String>? album;
  List<String>? like;
  Author? author;
  int? totalComment;
  DateTime? createdAt;
  DateTime? updatedAt;
  List<IsJoin>? isJoin;

  Posts({
    this.id,
    this.title,
    this.category,
    this.business,
    this.product,
    this.content,
    this.thumbnail,
    this.album,
    this.like,
    this.author,
    this.totalComment,
    this.createdAt,
    this.updatedAt,
    this.isJoin,
  });

  factory Posts.fromJson(Map<String, dynamic> json) {
    return Posts(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? 0,
      business: (json['business'] as List<dynamic>?)
              ?.map((b) => BusinessModel.fromJson(b as Map<String, dynamic>))
              .toList() ??
          [],
      product: (json['product'] as List<dynamic>?)
              ?.map((p) => ProductModel.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      content: json['content'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      album: List<String>.from(json['album'] ?? []),
      // Xử lý danh sách `like`
      like: (json['like'] as List<dynamic>?)
              ?.map((item) => item is Map<String, dynamic>
                  ? item['_id'].toString()
                  : item.toString())
              .toList() ??
          [],

      totalComment: json['totalComment'] ?? 0,

      author: json['author'] != null ? Author.fromJson(json['author']) : null,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      isJoin: (json['is_join'] as List<dynamic>?)?.map((item) {
            // Check if item is a string (ID) or a map
            if (item is String) {
              // Create IsJoin object from ID string
              return IsJoin(id: item);
            } else if (item is Map<String, dynamic>) {
              // If it's already a map, use the existing fromJson
              return IsJoin.fromJson(item);
            }
            // Return a default IsJoin if item is neither string nor map
            return IsJoin();
          }).toList() ??
          [],
    );
  }
  Map<String, dynamic> toCreateJson() {
    return {
      'title': title,
      'category': category,
      'product': product ?? [],
      'business': business ?? [],
      'content': content,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'category': category,
      'business': business ?? [],
      'product': product ?? [],
      'content': content,
      'thumbnail': thumbnail,
      'album': album ?? [],
      'like': like ?? [],
      'author': author?.toJson(),
      'totalComment': totalComment ?? 0,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'is_join': isJoin?.map((item) => item.toJson()) ?? [],
    };
  }
}
