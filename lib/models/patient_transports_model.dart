import 'dart:convert';

class PatientTransportsModel {
  String? id;
  String? appointmentTime;
  String? status;
  DateTime? timestamp;
  String? pickupLongitude;
  String? contactRelation;
  String? companionPhone;
  String? patientIdCard;
  String? appointmentDocumentUrl;
  String? companionRelation;
  DateTime? appointmentDate;
  String? pickupAddress;
  DateTime? submittedAt;
  dynamic patientLineId;
  String? pickupPlusCode;
  String? companionName;
  String? diagnosis;
  String? transportAbility;
  String? patientPhone;
  String? contactPhone;
  String? registeredAddress;
  String? appointmentDocumentName;
  String? patientType;
  String? hospital;
  String? patientName;
  String? pickupLatitude;
  String? serviceType;
  String? contactName;
  dynamic lineUserId;
  String? transportNotes;

  PatientTransportsModel({
    this.id,
    this.appointmentTime,
    this.status,
    this.timestamp,
    this.pickupLongitude,
    this.contactRelation,
    this.companionPhone,
    this.patientIdCard,
    this.appointmentDocumentUrl,
    this.companionRelation,
    this.appointmentDate,
    this.pickupAddress,
    this.submittedAt,
    this.patientLineId,
    this.pickupPlusCode,
    this.companionName,
    this.diagnosis,
    this.transportAbility,
    this.patientPhone,
    this.contactPhone,
    this.registeredAddress,
    this.appointmentDocumentName,
    this.patientType,
    this.hospital,
    this.patientName,
    this.pickupLatitude,
    this.serviceType,
    this.contactName,
    this.lineUserId,
    this.transportNotes,
  });

  factory PatientTransportsModel.fromRawJson(String str) =>
      PatientTransportsModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PatientTransportsModel.fromJson(Map<String, dynamic> json) =>
      PatientTransportsModel(
        id: json["id"],
        appointmentTime: json["appointmentTime"],
        status: json["status"],
        timestamp: json["timestamp"] == null
            ? null
            : DateTime.parse(json["timestamp"]),
        pickupLongitude: json["pickupLongitude"],
        contactRelation: json["contactRelation"],
        companionPhone: json["companionPhone"],
        patientIdCard: json["patientIdCard"],
        appointmentDocumentUrl: json["appointmentDocumentUrl"],
        companionRelation: json["companionRelation"],
        appointmentDate: json["appointmentDate"] == null
            ? null
            : DateTime.parse(json["appointmentDate"]),
        pickupAddress: json["pickupAddress"],
        submittedAt: json["submittedAt"] == null
            ? null
            : DateTime.parse(json["submittedAt"]),
        patientLineId: json["patientLineId"],
        pickupPlusCode: json["pickupPlusCode"],
        companionName: json["companionName"],
        diagnosis: json["diagnosis"],
        transportAbility: json["transportAbility"],
        patientPhone: json["patientPhone"],
        contactPhone: json["contactPhone"],
        registeredAddress: json["registeredAddress"],
        appointmentDocumentName: json["appointmentDocumentName"],
        patientType: json["patientType"],
        hospital: json["hospital"],
        patientName: json["patientName"],
        pickupLatitude: json["pickupLatitude"],
        serviceType: json["serviceType"],
        contactName: json["contactName"],
        lineUserId: json["lineUserId"],
        transportNotes: json["transportNotes"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "appointmentTime": appointmentTime,
    "status": status,
    "timestamp": timestamp?.toIso8601String(),
    "pickupLongitude": pickupLongitude,
    "contactRelation": contactRelation,
    "companionPhone": companionPhone,
    "patientIdCard": patientIdCard,
    "appointmentDocumentUrl": appointmentDocumentUrl,
    "companionRelation": companionRelation,
    "appointmentDate":
        "${appointmentDate!.year.toString().padLeft(4, '0')}-${appointmentDate!.month.toString().padLeft(2, '0')}-${appointmentDate!.day.toString().padLeft(2, '0')}",
    "pickupAddress": pickupAddress,
    "submittedAt": submittedAt?.toIso8601String(),
    "patientLineId": patientLineId,
    "pickupPlusCode": pickupPlusCode,
    "companionName": companionName,
    "diagnosis": diagnosis,
    "transportAbility": transportAbility,
    "patientPhone": patientPhone,
    "contactPhone": contactPhone,
    "registeredAddress": registeredAddress,
    "appointmentDocumentName": appointmentDocumentName,
    "patientType": patientType,
    "hospital": hospital,
    "patientName": patientName,
    "pickupLatitude": pickupLatitude,
    "serviceType": serviceType,
    "contactName": contactName,
    "lineUserId": lineUserId,
    "transportNotes": transportNotes,
  };
}
