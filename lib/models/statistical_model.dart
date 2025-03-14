class StatisticalModel {
  final String id;
  final String username;
  final String displayName;
  final String avatarImage;
  final String coverImage;
  final String companyName;
  final int rank;
  final int create;
  final int join;
  final int total;

  StatisticalModel({
    required this.id,
    required this.username,
    required this.displayName,
    required this.avatarImage,
    required this.coverImage,
    required this.companyName,
    required this.rank,
    required this.create,
    required this.join,
    required this.total,
  });

  factory StatisticalModel.fromJson(Map<String, dynamic> json) {
    return StatisticalModel(
      id: json['_id'],
      username: json['username'],
      displayName: json['displayName'],
      avatarImage: json['avatar_image'] ?? '',
      coverImage: json['cover_image'] ?? '',
      companyName: json['company_name'],
      rank: json['rank'],
      create: json['create'],
      join: json['join'],
      total: json['total'],
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
      'create': create,
      'join': join,
      'total': total,
    };
  }
}
