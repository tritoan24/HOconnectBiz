class MemberShipModel {
  MemberShipModel({
    this.id,
    this.level,
    this.benefits,
    this.minPoints,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  String? id;
  String? level;
  String? benefits;
  int? minPoints;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  factory MemberShipModel.fromJson(Map<String, dynamic> json) =>
      MemberShipModel(
        id: json["_id"],
        level: json["level"],
        benefits: json["benefits"],
        minPoints: json["minPoints"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "level": level,
        "benefits": benefits,
        "minPoints": minPoints,
        "createdAt": createdAt!.toIso8601String(),
        "updatedAt": updatedAt!.toIso8601String(),
        "__v": v,
      };
}
