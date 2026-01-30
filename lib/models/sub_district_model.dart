import 'dart:convert';

class SubDistrictModel {
  int? id;
  int? provinceCode;
  int? districtCode;
  int? subdistrictCode;
  String? subdistrictNameEn;
  String? subdistrictNameTh;
  int? postalCode;

  SubDistrictModel({
    this.id,
    this.provinceCode,
    this.districtCode,
    this.subdistrictCode,
    this.subdistrictNameEn,
    this.subdistrictNameTh,
    this.postalCode,
  });

  factory SubDistrictModel.fromRawJson(String str) =>
      SubDistrictModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SubDistrictModel.fromJson(Map<String, dynamic> json) =>
      SubDistrictModel(
        id: json["id"],
        provinceCode: json["provinceCode"],
        districtCode: json["districtCode"],
        subdistrictCode: json["subdistrictCode"],
        subdistrictNameEn: json["subdistrictNameEn"],
        subdistrictNameTh: json["subdistrictNameTh"],
        postalCode: json["postalCode"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "provinceCode": provinceCode,
    "districtCode": districtCode,
    "subdistrictCode": subdistrictCode,
    "subdistrictNameEn": subdistrictNameEn,
    "subdistrictNameTh": subdistrictNameTh,
    "postalCode": postalCode,
  };
}
