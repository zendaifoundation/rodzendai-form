import 'dart:convert';

class ProvinceModel {
  int? id;
  String? nameTh;
  String? nameEn;
  int? geographyId;
  String? createdAt;
  String? updatedAt;
  dynamic deletedAt;

  ProvinceModel({
    this.id,
    this.nameTh,
    this.nameEn,
    this.geographyId,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory ProvinceModel.fromRawJson(String str) =>
      ProvinceModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ProvinceModel.fromJson(Map<String, dynamic> json) => ProvinceModel(
        id: json["id"],
        nameTh: json["name_th"],
        nameEn: json["name_en"],
        geographyId: json["geography_id"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        deletedAt: json["deleted_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name_th": nameTh,
        "name_en": nameEn,
        "geography_id": geographyId,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "deleted_at": deletedAt,
      };
}
