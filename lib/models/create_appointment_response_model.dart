import 'dart:convert';

class CreateAppointmentResponseModel {
  String? code;
  bool? success;
  String? message;
  Data? data;

  CreateAppointmentResponseModel({
    this.code,
    this.success,
    this.message,
    this.data,
  });

  factory CreateAppointmentResponseModel.fromRawJson(String str) =>
      CreateAppointmentResponseModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CreateAppointmentResponseModel.fromJson(Map<String, dynamic> json) =>
      CreateAppointmentResponseModel(
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
  List<AppointmentDateModel>? list;
  String? message;

  Data({this.list, this.message});

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    list: json["list"] == null
        ? []
        : List<AppointmentDateModel>.from(
            json["list"]!.map((x) => AppointmentDateModel.fromJson(x)),
          ),
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "list": list == null
        ? []
        : List<dynamic>.from(list!.map((x) => x.toJson())),
    "message": message,
  };
}

class AppointmentDateModel {
  DateTime? date;
  String? time;

  AppointmentDateModel({this.date, this.time});

  factory AppointmentDateModel.fromRawJson(String str) =>
      AppointmentDateModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AppointmentDateModel.fromJson(Map<String, dynamic> json) => AppointmentDateModel(
    date: json["date"] == null ? null : DateTime.parse(json["date"]),
    time: json["time"],
  );

  Map<String, dynamic> toJson() => {
    "date":
        "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
    "time": time,
  };
}
