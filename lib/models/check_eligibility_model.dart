import 'dart:convert';

class CheckEligibilityModel {
  String? code;
  bool? success;
  String? message;
  Data? data;

  CheckEligibilityModel({this.code, this.success, this.message, this.data});

  factory CheckEligibilityModel.fromRawJson(String str) =>
      CheckEligibilityModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CheckEligibilityModel.fromJson(Map<String, dynamic> json) =>
      CheckEligibilityModel(
        code: json["code"],
        success: json["success"],
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
    "code": code,
    "success": success,
    "message": message,
    "data": data?.toJson(),
  };
}

class Data {
  bool? isEligible;
  Patient? patient;
  String? reason;

  Data({this.isEligible, this.patient, this.reason});

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    isEligible: json["isEligible"],
    patient: json["patient"] == null ? null : Patient.fromJson(json["patient"]),
    reason: json["reason"],
  );

  Map<String, dynamic> toJson() => {
    "isEligible": isEligible,
    "patient": patient?.toJson(),
    "reason": reason,
  };
}

class Patient {
  String? no;
  String? idCardNumber;
  String? name;
  String? phone;
  String? type;
  String? hospital;

  Patient({
    this.no,
    this.idCardNumber,
    this.name,
    this.phone,
    this.type,
    this.hospital,
  });

  factory Patient.fromRawJson(String str) => Patient.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Patient.fromJson(Map<String, dynamic> json) => Patient(
    no: json["no"],
    idCardNumber: json["idCardNumber"],
    name: json["name"],
    phone: json["phone"],
    type: json["type"],
    hospital: json["hospital"],
  );

  Map<String, dynamic> toJson() => {
    "no": no,
    "idCardNumber": idCardNumber,
    "name": name,
    "phone": phone,
    "type": type,
    "hospital": hospital,
  };
}
