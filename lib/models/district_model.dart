import 'dart:convert';

class DistrictModel {
    int? id;
    int? provinceCode;
    int? districtCode;
    String? districtNameEn;
    String? districtNameTh;
    int? postalCode;

    DistrictModel({
        this.id,
        this.provinceCode,
        this.districtCode,
        this.districtNameEn,
        this.districtNameTh,
        this.postalCode,
    });

    factory DistrictModel.fromRawJson(String str) => DistrictModel.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory DistrictModel.fromJson(Map<String, dynamic> json) => DistrictModel(
        id: json["id"],
        provinceCode: json["provinceCode"],
        districtCode: json["districtCode"],
        districtNameEn: json["districtNameEn"],
        districtNameTh: json["districtNameTh"],
        postalCode: json["postalCode"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "provinceCode": provinceCode,
        "districtCode": districtCode,
        "districtNameEn": districtNameEn,
        "districtNameTh": districtNameTh,
        "postalCode": postalCode,
    };
}
