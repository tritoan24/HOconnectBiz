import 'auth_model.dart';

class CommentModel {
  String? id;
  String postId;
  Author? userId;
  String content;
  List<String>? album;
  DateTime? createdAt;

  CommentModel({
    this.id,
    required this.postId,
    this.userId,
    required this.content,
    this.album,
    this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['_id'],
      postId: json['postId'],
      userId: json['userId'] != null ? Author.fromJson(json['userId']) : null,
      content: json['content'],
      album: List<String>.from(json['album'] ?? []),
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'album': album,
    };
  }

  @override
  String toString() {
    return 'CommentModel{id: $id, postId: $postId, userId: $userId, content: $content, album: $album, createdAt: $createdAt}';
  }
}
