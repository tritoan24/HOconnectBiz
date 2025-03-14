class Bo {
  final String id;
  final String title;
  final int category;
  final String content;
  final String thumbnail;
  final String authorName;
  final String authorAvatar;
  final String companyName;
  final double revenue;
  final double avgStar;
  final int totalReview;
  final int totalCompany;
  final List<String> album;
  final bool? isBo;
  final bool? isFeatured;
  final DateTime? createdAt;

  Bo({
    required this.id,
    required this.title,
    required this.category,
    required this.content,
    required this.thumbnail,
    required this.authorName,
    required this.authorAvatar,
    required this.companyName,
    required this.revenue,
    required this.avgStar,
    required this.totalReview,
    required this.totalCompany,
    required this.album,
    this.isBo,
    this.isFeatured,
    this.createdAt,
  });

  factory Bo.fromJson(Map<String, dynamic> json) {
    return Bo(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] is int
          ? json['category']
          : int.tryParse(json['category'].toString()) ?? 0,
      content: json['content'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      authorName: json['author'] is Map<String, dynamic>
          ? json['author']['displayName'] ?? ''
          : '',
      authorAvatar: json['author'] is Map<String, dynamic>
          ? json['author']['avatar_image'] ?? ''
          : '',
      companyName: json['author'] is Map<String, dynamic>
          ? json['author']['company_name'] ?? ''
          : '',
      revenue:
          json['revenue'] is num ? (json['revenue'] as num).toDouble() : 0.0,
      avgStar:
          json['avgStar'] is num ? (json['avgStar'] as num).toDouble() : 0.0,
      totalReview: json['total_review'] is int
          ? json['total_review']
          : int.tryParse(json['total_review'].toString()) ?? 0,
      totalCompany: json['total_company'] is int
          ? json['total_company']
          : int.tryParse(json['total_company'].toString()) ?? 0,
      album: json['album'] is List
          ? (json['album'] as List<dynamic>).whereType<String>().toList()
          : [],
      isBo: json['is_bo'] is bool ? json['is_bo'] : false,
      isFeatured: json['is_featured'] is bool ? json['is_featured'] : false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }
}
