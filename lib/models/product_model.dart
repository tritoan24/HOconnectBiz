class ProductModel {
  final String? id;
  final String? author;
  final String title;
  final int price;
  final int discount;
  final String? description;
  final List<String> album;
  final bool? isPin;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? quantity;

  ProductModel({
    this.id,
    this.author,
    required this.title,
    required this.price,
    required this.discount,
    this.description,
    required this.album,
    this.isPin,
    this.createdAt,
    this.updatedAt,
    this.quantity,
  });

  /// 🛠 **Sửa lại `copyWith` đầy đủ các thuộc tính**
  ProductModel copyWith({
    String? id,
    String? author,
    String? title,
    int? price,
    int? discount,
    String? description,
    List<String>? album,
    bool? isPin,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      author: author ?? this.author,
      title: title ?? this.title,
      price: price ?? this.price,
      discount: discount ?? this.discount,
      description: description ?? this.description,
      album: album ?? List.from(this.album), // Tránh lỗi danh sách bị null
      isPin: isPin ?? this.isPin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 🛠 **Chuyển đổi từ JSON sang đối tượng**
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['_id'],
      author: json['author'],
      title: json['title'] ?? '',
      price: json['price'] ?? 0,
      discount: json['discount'] ?? 0,
      description: json['description'],
      album: json['album'] != null ? List<String>.from(json['album']) : [],
      isPin: json['is_pin'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  // Chuyển đổi từ đối tượng SanPham sang JSON cho việc tạo mới
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'title': title,
      'price': price,
      'discount': discount,
      'album': album,
    };

    // Chỉ thêm các trường không null vào JSON
    if (description != null) data['description'] = description;
    if (id != null) data['_id'] = id;
    if (author != null) data['author'] = author;
    if (isPin != null) data['is_pin'] = isPin;

    return data;
  }

  Map<String, dynamic> toJsonEditPin() {
    if (id == null) {
      throw Exception("Product ID cannot be null");
    }

    return {
      '_id': id, // Must be a valid ObjectId
      'is_pin': isPin ?? false, // Default to false if null
    };
  }
}

class BuyProductModel {
  final String id;
  final int price;
  final int quantity;
  final int discount;

  BuyProductModel({
    required this.id,
    required this.price,
    required this.quantity,
    required this.discount,
  });
  Map<String, dynamic> toJsonBuy() {
    final Map<String, dynamic> data = {
      'productId': id,
      'price': price,
      'quantity': quantity,
      'discount': discount,
    };
    return data;
  }
}
