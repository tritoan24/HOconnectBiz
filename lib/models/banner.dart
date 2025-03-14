class BannerModel {
  BannerModel({
    this.id,
    this.title,
    this.imageUrl,
    this.link,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  String? id;
  String? title;
  String? imageUrl;
  String? link;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  factory BannerModel.fromJson(Map<String, dynamic> json) => BannerModel(
        id: json["_id"],
        title: json["title"],
        imageUrl: json["imageUrl"],
        link: json["link"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "title": title,
        "imageUrl": imageUrl,
        "link": link,
        "createdAt": createdAt!.toIso8601String(),
        "updatedAt": updatedAt!.toIso8601String(),
        "__v": v,
      };
}
