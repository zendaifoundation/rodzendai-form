import 'dart:convert';

class SubDistrictModel {
  int? id;
  int? zipCode;
  String? nameTh;
  String? nameEn;
  int? amphureId;
  String? createdAt;
  String? updatedAt;
  dynamic deletedAt;

  SubDistrictModel({
    this.id,
    this.zipCode,
    this.nameTh,
    this.nameEn,
    this.amphureId,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory SubDistrictModel.fromRawJson(String str) =>
      SubDistrictModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SubDistrictModel.fromJson(Map<String, dynamic> json) =>
      SubDistrictModel(
        id: json["id"],
        zipCode: json["zip_code"],
        nameTh: json["name_th"],
        nameEn: json["name_en"],
        amphureId: json["amphure_id"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        deletedAt: json["deleted_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "zip_code": zipCode,
        "name_th": nameTh,
        "name_en": nameEn,
        "amphure_id": amphureId,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "deleted_at": deletedAt,
      };
}
