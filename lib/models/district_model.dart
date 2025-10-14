import 'dart:convert';

class DistrictModel {
  int? id;
  String? nameTh;
  String? nameEn;
  int? provinceId;
  String? createdAt;
  String? updatedAt;
  dynamic deletedAt;

  DistrictModel({
    this.id,
    this.nameTh,
    this.nameEn,
    this.provinceId,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory DistrictModel.fromRawJson(String str) =>
      DistrictModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory DistrictModel.fromJson(Map<String, dynamic> json) => DistrictModel(
        id: json["id"],
        nameTh: json["name_th"],
        nameEn: json["name_en"],
        provinceId: json["province_id"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        deletedAt: json["deleted_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name_th": nameTh,
        "name_en": nameEn,
        "province_id": provinceId,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "deleted_at": deletedAt,
      };
}
