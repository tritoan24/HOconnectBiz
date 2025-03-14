class CreatePost {
  String? title;
  int? category;
  List<String>? product;
  List<String>? business;
  String? content;
  List<String>? album;

  CreatePost({
    this.title,
    this.category,
    this.product,
    this.business,
    this.content,
    this.album,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'category': category,
      'product': product ?? [],
      'business': business ?? [],
      'content': content,
      'album': album ?? [],
    };
  }

  factory CreatePost.fromJson(Map<String, dynamic> json) {
    return CreatePost(
      title: json['title'] ?? '',
      category: json['category'] ?? 0, // Đảm bảo category có giá trị mặc định
      business: List<String>.from(json['business'] ?? []),
      product: List<String>.from(json['product'] ?? []),
      content:
          json['content'] ?? '', // Nếu không có content, gán giá trị mặc định
    );
  }
}
