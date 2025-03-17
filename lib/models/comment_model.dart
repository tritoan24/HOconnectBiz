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
    try {
      DateTime? parseCreatedAt(dynamic dateStr) {
        if (dateStr == null) return null;

        try {
          // Thử parse trực tiếp nếu là ISO format
          return DateTime.parse(dateStr);
        } catch (e) {
          try {
            // Nếu là format "dd/MM/yyyy"
            final parts = dateStr.toString().split('/');
            if (parts.length == 3) {
              return DateTime(
                int.parse(parts[2]), // year
                int.parse(parts[1]), // month
                int.parse(parts[0]), // day
              );
            }
          } catch (e) {
            print('Error parsing date: $e');
          }
        }
        return null;
      }

      return CommentModel(
        id: json['_id'],
        postId: json['postId'],
        userId: json['userId'] != null ? Author.fromJson(json['userId']) : null,
        content: json['content'],
        album: List<String>.from(json['album'] ?? []),
        createdAt: parseCreatedAt(json['createdAt']),
      );
    } catch (e) {
      print('Error creating CommentModel: $e');
      rethrow;
    }
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