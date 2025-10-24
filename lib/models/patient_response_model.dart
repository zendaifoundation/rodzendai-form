import 'dart:convert';

class PatientResponseModel {
  String? code;
  bool? success;
  String? message;
  PatientModel? data;

  PatientResponseModel({this.code, this.success, this.message, this.data});

  factory PatientResponseModel.fromRawJson(String str) =>
      PatientResponseModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PatientResponseModel.fromJson(Map<String, dynamic> json) =>
      PatientResponseModel(
        code: json["code"],
        success: json["success"],
        message: json["message"],
        data: json["data"] == null ? null : PatientModel.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
    "code": code,
    "success": success,
    "message": message,
    "data": data?.toJson(),
  };
}

class PatientModel {
  String? id;
  Patient? patient;
  dynamic companion;
  Addresses? addresses;
  Documents? documents;
  int? phase;
  dynamic status;
  String? source;
  String? sourceDetail;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? remainingRights;

  PatientModel({
    this.id,
    this.patient,
    this.companion,
    this.addresses,
    this.documents,
    this.phase,
    this.status,
    this.source,
    this.sourceDetail,
    this.createdAt,
    this.updatedAt,
    this.remainingRights,
  });

  factory PatientModel.fromRawJson(String str) =>
      PatientModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PatientModel.fromJson(Map<String, dynamic> json) => PatientModel(
    id: json["id"],
    patient: json["patient"] == null ? null : Patient.fromJson(json["patient"]),
    companion: json["companion"],
    addresses: json["addresses"] == null
        ? null
        : Addresses.fromJson(json["addresses"]),
    documents: json["documents"] == null
        ? null
        : Documents.fromJson(json["documents"]),
    phase: json["phase"],
    status: json["status"],
    source: json["source"],
    sourceDetail: json["sourceDetail"],
    createdAt: json["createdAt"] == null
        ? null
        : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null
        ? null
        : DateTime.parse(json["updatedAt"]),
    remainingRights: json["remainingRights"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "patient": patient?.toJson(),
    "companion": companion,
    "addresses": addresses?.toJson(),
    "documents": documents?.toJson(),
    "phase": phase,
    "status": status,
    "source": source,
    "sourceDetail": sourceDetail,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "remainingRights": remainingRights,
  };
}

class Addresses {
  Current? registered;
  Current? current;

  Addresses({this.registered, this.current});

  factory Addresses.fromRawJson(String str) =>
      Addresses.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Addresses.fromJson(Map<String, dynamic> json) => Addresses(
    registered: json["registered"] == null
        ? null
        : Current.fromJson(json["registered"]),
    current: json["current"] == null ? null : Current.fromJson(json["current"]),
  );

  Map<String, dynamic> toJson() => {
    "registered": registered?.toJson(),
    "current": current?.toJson(),
  };
}

class Current {
  String? address;
  String? province;
  String? provinceId;
  String? district;
  String? districtId;
  String? subDistrict;
  String? subDistrictId;

  Current({
    this.address,
    this.province,
    this.provinceId,
    this.district,
    this.districtId,
    this.subDistrict,
    this.subDistrictId,
  });

  factory Current.fromRawJson(String str) => Current.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Current.fromJson(Map<String, dynamic> json) => Current(
    address: json["address"],
    province: json["province"],
    provinceId: json["provinceId"],
    district: json["district"],
    districtId: json["districtId"],
    subDistrict: json["subDistrict"],
    subDistrictId: json["subDistrictId"],
  );

  Map<String, dynamic> toJson() => {
    "address": address,
    "province": province,
    "provinceId": provinceId,
    "district": district,
    "districtId": districtId,
    "subDistrict": subDistrict,
    "subDistrictId": subDistrictId,
  };
}

class Documents {
  dynamic idCard;
  dynamic thaiStateWelfareCard;
  List<dynamic>? others;

  Documents({this.idCard, this.thaiStateWelfareCard, this.others});

  factory Documents.fromRawJson(String str) =>
      Documents.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Documents.fromJson(Map<String, dynamic> json) => Documents(
    idCard: json["idCard"],
    thaiStateWelfareCard: json["thaiStateWelfareCard"],
    others: json["others"] == null
        ? []
        : List<dynamic>.from(json["others"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "idCard": idCard,
    "thaiStateWelfareCard": thaiStateWelfareCard,
    "others": others == null ? [] : List<dynamic>.from(others!.map((x) => x)),
  };
}

class Patient {
  String? idCardNumber;
  String? firstName;
  String? lastName;
  String? phone;
  dynamic lineId;
  String? type;
  String? mobilityAbility;

  Patient({
    this.idCardNumber,
    this.firstName,
    this.lastName,
    this.phone,
    this.lineId,
    this.type,
    this.mobilityAbility,
  });

  factory Patient.fromRawJson(String str) => Patient.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Patient.fromJson(Map<String, dynamic> json) => Patient(
    idCardNumber: json["idCardNumber"],
    firstName: json["firstName"],
    lastName: json["lastName"],
    phone: json["phone"],
    lineId: json["lineId"],
    type: json["type"],
    mobilityAbility: json["mobilityAbility"],
  );

  Map<String, dynamic> toJson() => {
    "idCardNumber": idCardNumber,
    "firstName": firstName,
    "lastName": lastName,
    "phone": phone,
    "lineId": lineId,
    "type": type,
    "mobilityAbility": mobilityAbility,
  };
}
