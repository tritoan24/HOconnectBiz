class Rank {
  final String id;
  final String username;
  final String displayName;
  final String avatarImage;
  final String coverImage;
  final String companyName;
  final int rank;

  Rank({
    required this.id,
    required this.username,
    required this.displayName,
    required this.avatarImage,
    required this.coverImage,
    required this.companyName,
    required this.rank,
  });

  // Đảm bảo kiểu Map<String, dynamic>
  factory Rank.fromJson(Map<String, dynamic> json) {
    return Rank(
      id: json['_id'] ?? '',
      username: json['username'] ?? '',
      displayName: json['displayName'] ?? '',
      avatarImage: json['avatar_image'] ?? '',
      coverImage: json['cover_image'] ?? '',
      companyName: json['company_name'] ?? '',
      rank: json['rank'] is int
          ? json['rank']
          : int.tryParse(json['rank'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'username': username,
      'displayName': displayName,
      'avatar_image': avatarImage,
      'cover_image': coverImage,
      'company_name': companyName,
      'rank': rank,
    };
  }
}
