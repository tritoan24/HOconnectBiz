import '../utils/router/router.name.dart';

class Author {
  final String id;
  final String username;
  final String displayName;
  final int level;
  final String registerType;
  final String avatarImage;
  final String coverImage;
  final String description;
  final List<String> business;
  final String companyName;
  final String address;
  final String companyDescription;
  final String email;
  final String gender;
  final String status;
  final String phone;
  final int roleCode;
  final String type;
  final String userId;
  final int? membershipPoints;
  final int? membershipPointsNeed;
  final int? membershipPointsMax;
  final int? boStar;
  final int? totalBo;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLogin;

  Author({
    required this.id,
    required this.username,
    required this.displayName,
    required this.level,
    required this.registerType,
    required this.avatarImage,
    required this.coverImage,
    required this.description,
    required this.business,
    required this.companyName,
    required this.address,
    required this.companyDescription,
    required this.email,
    required this.gender,
    required this.status,
    required this.phone,
    required this.roleCode,
    required this.type,
    required this.userId,
    this.membershipPoints,
    this.membershipPointsNeed,
    this.membershipPointsMax,
    this.boStar,
    this.totalBo,
    this.createdAt,
    this.updatedAt,
    this.lastLogin,
  });

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      id: json['_id'] ?? '',
      username: json['username'] ?? '',
      displayName: json['displayName'] ?? '',
      level: json['level'] is int
          ? json['level']
          : int.tryParse(json['level']?.toString() ?? '') ?? 0,
      registerType: json['register_type'] ?? '',
      avatarImage: json['avatar_image'] ?? '',
      coverImage: json['cover_image'] ?? '',
      description: json['description'] ?? '',
      business: List<String>.from(json['business'] ?? []),
      companyName: json['company_name'] ?? '',
      address: json['address'] ?? '',
      companyDescription: json['company_description'] ?? '',
      email: json['email'] ?? '',
      gender: json['gender'] ?? '',
      status: json['status'] ?? '',
      phone: json['phoneNumber'] ?? 'Chưa cập nhật',
      roleCode: json['roleCode'] is int
          ? json['roleCode']
          : int.tryParse(json['roleCode']?.toString() ?? '') ?? 0,
      type: json['type'] ?? '',
      userId: json['user_id'] ?? '',
      membershipPoints: json['membershipPoints'] is int
          ? json['membershipPoints']
          : int.tryParse(json['membershipPoints']?.toString() ?? ''),
      membershipPointsNeed: json['membershipPointsNeed'] is int
          ? json['membershipPointsNeed']
          : int.tryParse(json['membershipPointsNeed']?.toString() ?? ''),
      membershipPointsMax: json['membershipPointsMax'] is int
          ? json['membershipPointsMax']
          : int.tryParse(json['membershipPointsMax']?.toString() ?? ''),
      boStar: json['boStar'] is int
          ? json['boStar']
          : int.tryParse(json['boStar']?.toString() ?? '') ?? 0,
      totalBo: json['totalBo'] is int
          ? json['totalBo']
          : int.tryParse(json['totalBo']?.toString() ?? '') ?? 0,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      lastLogin:
          json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'username': username,
      'displayName': displayName,
      'level': level,
      'register_type': registerType,
      'avatar_image': avatarImage,
      'cover_image': coverImage,
      'description': description,
      'business': business,
      'company_name': companyName,
      'address': address,
      'company_description': companyDescription,
      'email': email,
      'gender': gender,
      'status': status,
      'phone': phone,
      'roleCode': roleCode,
      'type': type,
      'user_id': userId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
    };
  }
}

class AuthorBusiness {
  final String id;
  final String? displayName;
  final String? avatarImage;
  final String? companyName;
  final String? companyDescription;

  AuthorBusiness({
    required this.id,
    this.displayName,
    this.avatarImage,
    this.companyName,
    this.companyDescription,
  });

  /// 🟢 Chuyển đổi từ JSON sang `AuthorBusiness`
  factory AuthorBusiness.fromJson(Map<String, dynamic> json) {
    return AuthorBusiness(
      id: json['_id'] ?? '',
      displayName: json['displayName'] ?? 'Không có tên',
      avatarImage: json['avatar_image'] ?? UrlImage.defaultUserAvatar,
      companyName: json['company_name'] ?? 'Không có công ty',
      companyDescription: json['company_description'] ?? '',
    );
  }

  /// 🟢 Chuyển đổi từ `AuthorBusiness` sang JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'displayName': displayName,
      'avatar_image': avatarImage,
      'company_name': companyName,
      'company_description': companyDescription,
    };
  }

  /// 🟢 Tạo một `AuthorBusiness` mặc định nếu không có dữ liệu
  static AuthorBusiness defaultAuthor() {
    return AuthorBusiness(
      id: '',
      displayName: 'Không có tên',
      avatarImage: UrlImage.defaultUserAvatar,
      companyName: 'Không có công ty',
      companyDescription: '',
    );
  }
}
