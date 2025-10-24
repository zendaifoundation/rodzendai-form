import 'dart:convert';

class CheckRegisterPatientResponseModel {
    String? code;
    bool? success;
    String? message;
    CheckRegisterPatientResponseModelData? data;

    CheckRegisterPatientResponseModel({
        this.code,
        this.success,
        this.message,
        this.data,
    });

    factory CheckRegisterPatientResponseModel.fromRawJson(String str) => CheckRegisterPatientResponseModel.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory CheckRegisterPatientResponseModel.fromJson(Map<String, dynamic> json) => CheckRegisterPatientResponseModel(
        code: json["code"],
        success: json["success"],
        message: json["message"],
        data: json["data"] == null ? null : CheckRegisterPatientResponseModelData.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "code": code,
        "success": success,
        "message": message,
        "data": data?.toJson(),
    };
}

class CheckRegisterPatientResponseModelData {
    bool? exists;
    String? status;
    dynamic source;
    String? reason;
    String? messageTh;
    String? messageEn;
    DataData? data;

    CheckRegisterPatientResponseModelData({
        this.exists,
        this.status,
        this.source,
        this.reason,
        this.messageTh,
        this.messageEn,
        this.data,
    });

    factory CheckRegisterPatientResponseModelData.fromRawJson(String str) => CheckRegisterPatientResponseModelData.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory CheckRegisterPatientResponseModelData.fromJson(Map<String, dynamic> json) => CheckRegisterPatientResponseModelData(
        exists: json["exists"],
        status: json["status"],
        source: json["source"],
        reason: json["reason"],
        messageTh: json["messageTh"],
        messageEn: json["messageEn"],
        data: json["data"] == null ? null : DataData.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "exists": exists,
        "status": status,
        "source": source,
        "reason": reason,
        "messageTh": messageTh,
        "messageEn": messageEn,
        "data": data?.toJson(),
    };
}

class DataData {
    String? idCardNumber;

    DataData({
        this.idCardNumber,
    });

    factory DataData.fromRawJson(String str) => DataData.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory DataData.fromJson(Map<String, dynamic> json) => DataData(
        idCardNumber: json["idCardNumber"],
    );

    Map<String, dynamic> toJson() => {
        "idCardNumber": idCardNumber,
    };
}
