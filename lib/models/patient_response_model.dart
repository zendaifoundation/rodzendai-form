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
  Companion? companion;
  Addresses? addresses;
  Documents? documents;
  String? phase;
  String? status;
  String? source;
  String? sourceDetail;
  DateTime? createdAt;
  DateTime? updatedAt;
  RemainingRights? remainingRights;
  ProjectInfo? projectInfo;
  Transportation? transportation;

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
    this.projectInfo,
    this.transportation,
  });

  factory PatientModel.fromRawJson(String str) =>
      PatientModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PatientModel.fromJson(Map<String, dynamic> json) => PatientModel(
    id: json["id"],
    patient: json["patient"] == null ? null : Patient.fromJson(json["patient"]),
    companion: json["companion"] == null
        ? null
        : Companion.fromJson(json["companion"]),
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
    remainingRights: json["remainingRights"] == null
        ? null
        : RemainingRights.fromJson(json["remainingRights"]),
    projectInfo: json["projectInfo"] == null
        ? null
        : ProjectInfo.fromJson(json["projectInfo"]),
    transportation: json["transportation"] == null
        ? null
        : Transportation.fromJson(json["transportation"]),
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
    "projectInfo": projectInfo,
    "transportation": transportation,
  };
}

class RemainingRights {
  int? totalRights;
  int? usedRights;
  int? remainingRights;

  RemainingRights({this.totalRights, this.usedRights, this.remainingRights});

  factory RemainingRights.fromRawJson(String str) =>
      RemainingRights.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory RemainingRights.fromJson(Map<String, dynamic> json) =>
      RemainingRights(
        totalRights: json["totalRights"],
        usedRights: json["usedRights"],
        remainingRights: json["remainingRights"],
      );

  Map<String, dynamic> toJson() => {
    "totalRights": totalRights,
    "usedRights": usedRights,
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
  int? provinceCode;
  String? district;
  int? districtCode;
  String? subDistrict;
  int? subDistrictCode;
  String? pickupPlusCode;

  Current({
    this.address,
    this.province,
    this.provinceCode,
    this.district,
    this.districtCode,
    this.subDistrict,
    this.subDistrictCode,
    this.pickupPlusCode,
  });

  factory Current.fromRawJson(String str) => Current.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Current.fromJson(Map<String, dynamic> json) => Current(
    address: json["address"],
    province: json["province"],
    provinceCode: json["provinceCode"],
    district: json["district"],
    districtCode: json["districtCode"],
    subDistrict: json["subDistrict"],
    subDistrictCode: json["subDistrictCode"],
    pickupPlusCode: json["pickupPlusCode"],
  );

  Map<String, dynamic> toJson() => {
    "address": address,
    "province": province,
    "provinceCode": provinceCode,
    "district": district,
    "districtCode": districtCode,
    "subDistrict": subDistrict,
    "subDistrictCode": subDistrictCode,
    "pickupPlusCode": pickupPlusCode,
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
  String? dateOfBirth;

  Patient({
    this.idCardNumber,
    this.firstName,
    this.lastName,
    this.phone,
    this.lineId,
    this.type,
    this.mobilityAbility,
    this.dateOfBirth,
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
    dateOfBirth: json["dateOfBirth"],
  );

  Map<String, dynamic> toJson() => {
    "idCardNumber": idCardNumber,
    "firstName": firstName,
    "lastName": lastName,
    "phone": phone,
    "lineId": lineId,
    "type": type,
    "mobilityAbility": mobilityAbility,
    "dateOfBirth": dateOfBirth,
  };
}

class ProjectInfo {
  String? id;
  String? name;
  String? description;
  String? status;
  DateTime? startDate;
  DateTime? endDate;
  int? maxUsage;

  ProjectInfo({
    this.id,
    this.name,
    this.description,
    this.status,
    this.startDate,
    this.endDate,
    this.maxUsage,
  });

  factory ProjectInfo.fromRawJson(String str) =>
      ProjectInfo.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ProjectInfo.fromJson(Map<String, dynamic> json) => ProjectInfo(
    id: json["id"],
    name: json["name"],
    description: json["description"],
    status: json["status"],
    startDate: json["startDate"] == null
        ? null
        : DateTime.parse(json["startDate"]),
    endDate: json["endDate"] == null ? null : DateTime.parse(json["endDate"]),
    maxUsage: json["maxUsage"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
    "status": status,
    "startDate": startDate?.toIso8601String(),
    "endDate": endDate?.toIso8601String(),
    "maxUsage": maxUsage,
  };
}

class Transportation {
  String? ability;

  Transportation({this.ability});

  factory Transportation.fromRawJson(String str) =>
      Transportation.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Transportation.fromJson(Map<String, dynamic> json) =>
      Transportation(ability: json["ability"]);

  Map<String, dynamic> toJson() => {"ability": ability};
}

class Companion {
  String? firstName;
  String? idCardNumber;
  String? lastName;
  String? phone;
  String? relation;

  Companion({
    this.firstName,
    this.idCardNumber,
    this.lastName,
    this.phone,
    this.relation,
  });

  factory Companion.fromRawJson(String str) =>
      Companion.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Companion.fromJson(Map<String, dynamic> json) => Companion(
    firstName: json["firstName"],
    idCardNumber: json["idCardNumber"],
    lastName: json["lastName"],
    phone: json["phone"],
    relation: json["relation"],
  );

  Map<String, dynamic> toJson() => {
    "firstName": firstName,
    "idCardNumber": idCardNumber,
    "lastName": lastName,
    "phone": phone,
    "relation": relation,
  };
}
