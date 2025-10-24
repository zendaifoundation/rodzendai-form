import 'dart:convert';

class ProvinceModel {
  int? id;
  int? provinceCode;
  String? provinceNameEn;
  String? provinceNameTh;

  ProvinceModel({
    this.id,
    this.provinceCode,
    this.provinceNameEn,
    this.provinceNameTh,
  });

  factory ProvinceModel.fromRawJson(String str) =>
      ProvinceModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ProvinceModel.fromJson(Map<String, dynamic> json) => ProvinceModel(
    id: json["id"],
    provinceCode: json["provinceCode"],
    provinceNameEn: json["provinceNameEn"],
    provinceNameTh: json["provinceNameTh"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "provinceCode": provinceCode,
    "provinceNameEn": provinceNameEn,
    "provinceNameTh": provinceNameTh,
  };
}
