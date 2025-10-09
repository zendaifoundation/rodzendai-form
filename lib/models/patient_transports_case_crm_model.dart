import 'dart:convert';

class PatientTransportsCaseCrmModel {
  String? id;
  String? recordedBy;
  List<TransportRequest>? transportRequest;
  Status? status;
  List<Driver>? driver;
  DateTime? createdAt;
  AppointmentInfo? appointmentInfo;
  dynamic caseEvaluation;
  String? transportationTypes;
  String? caseId;
  TravelMode? travelMode;
  PatientInfo? patientInfo;
  List<Companion>? reporterInfo;
  DateTime? recordedDate;
  List<Companion>? companions;
  DateTime? updatedAt;

  PatientTransportsCaseCrmModel({
    this.id,
    this.recordedBy,
    this.transportRequest,
    this.status,
    this.driver,
    this.createdAt,
    this.appointmentInfo,
    this.caseEvaluation,
    this.transportationTypes,
    this.caseId,
    this.travelMode,
    this.patientInfo,
    this.reporterInfo,
    this.recordedDate,
    this.companions,
    this.updatedAt,
  });

  factory PatientTransportsCaseCrmModel.fromRawJson(String str) =>
      PatientTransportsCaseCrmModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PatientTransportsCaseCrmModel.fromJson(Map<String, dynamic> json) =>
      PatientTransportsCaseCrmModel(
        id: json["id"],
        recordedBy: json["recorded_by"],
        transportRequest: json["transport_request"] == null
            ? []
            : List<TransportRequest>.from(
                json["transport_request"]!.map(
                  (x) => TransportRequest.fromJson(x),
                ),
              ),
        status: json["status"] == null ? null : Status.fromJson(json["status"]),
        driver: json["driver"] == null
            ? []
            : List<Driver>.from(json["driver"]!.map((x) => Driver.fromJson(x))),
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        appointmentInfo: json["appointment_info"] == null
            ? null
            : AppointmentInfo.fromJson(json["appointment_info"]),
        caseEvaluation: json["case_evaluation"],
        transportationTypes: json["transportationTypes"],
        caseId: json["case_id"],
        travelMode: json["travel_mode"] == null
            ? null
            : TravelMode.fromJson(json["travel_mode"]),
        patientInfo: json["patient_info"] == null
            ? null
            : PatientInfo.fromJson(json["patient_info"]),
        reporterInfo: json["reporter_info"] == null
            ? []
            : List<Companion>.from(
                json["reporter_info"]!.map((x) => Companion.fromJson(x)),
              ),
        recordedDate: json["recorded_date"] == null
            ? null
            : DateTime.parse(json["recorded_date"]),
        companions: json["companions"] == null
            ? []
            : List<Companion>.from(
                json["companions"]!.map((x) => Companion.fromJson(x)),
              ),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "recorded_by": recordedBy,
    "transport_request": transportRequest == null
        ? []
        : List<dynamic>.from(transportRequest!.map((x) => x.toJson())),
    "status": status?.toJson(),
    "driver": driver == null
        ? []
        : List<dynamic>.from(driver!.map((x) => x.toJson())),
    "createdAt": createdAt?.toIso8601String(),
    "appointment_info": appointmentInfo?.toJson(),
    "case_evaluation": caseEvaluation,
    "transportationTypes": transportationTypes,
    "case_id": caseId,
    "travel_mode": travelMode?.toJson(),
    "patient_info": patientInfo?.toJson(),
    "reporter_info": reporterInfo == null
        ? []
        : List<dynamic>.from(reporterInfo!.map((x) => x.toJson())),
    "recorded_date":
        "${recordedDate!.year.toString().padLeft(4, '0')}-${recordedDate!.month.toString().padLeft(2, '0')}-${recordedDate!.day.toString().padLeft(2, '0')}",
    "companions": companions == null
        ? []
        : List<dynamic>.from(companions!.map((x) => x.toJson())),
    "updatedAt": updatedAt?.toIso8601String(),
  };
}

class AppointmentInfo {
  List<PhotoDocument>? photoDocument;
  DateTime? appointmentDate;
  String? appointmentTime;
  String? hospitalName;
  String? hospitalCode;

  AppointmentInfo({
    this.photoDocument,
    this.appointmentDate,
    this.appointmentTime,
    this.hospitalName,
    this.hospitalCode,
  });

  factory AppointmentInfo.fromRawJson(String str) =>
      AppointmentInfo.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AppointmentInfo.fromJson(Map<String, dynamic> json) =>
      AppointmentInfo(
        photoDocument: json["photo_document"] == null
            ? []
            : List<PhotoDocument>.from(
                json["photo_document"]!.map((x) => PhotoDocument.fromJson(x)),
              ),
        appointmentDate: json["appointment_date"] == null
            ? null
            : DateTime.parse(json["appointment_date"]),
        appointmentTime: json["appointment_time"],
        hospitalName: json["hospital_name"],
        hospitalCode: json["hospital_code"],
      );

  Map<String, dynamic> toJson() => {
    "photo_document": photoDocument == null
        ? []
        : List<dynamic>.from(photoDocument!.map((x) => x.toJson())),
    "appointment_date":
        "${appointmentDate!.year.toString().padLeft(4, '0')}-${appointmentDate!.month.toString().padLeft(2, '0')}-${appointmentDate!.day.toString().padLeft(2, '0')}",
    "appointment_time": appointmentTime,
    "hospital_name": hospitalName,
    "hospital_code": hospitalCode,
  };
}

class PhotoDocument {
  String? typeDocument;
  int? order;
  String? file;

  PhotoDocument({this.typeDocument, this.order, this.file});

  factory PhotoDocument.fromRawJson(String str) =>
      PhotoDocument.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PhotoDocument.fromJson(Map<String, dynamic> json) => PhotoDocument(
    typeDocument: json["type_document"],
    order: json["order"],
    file: json["file"],
  );

  Map<String, dynamic> toJson() => {
    "type_document": typeDocument,
    "order": order,
    "file": file,
  };
}

class Companion {
  String? fullName;
  String? companionNumId;
  String? phoneNumber;
  String? relationToPatient;

  Companion({
    this.fullName,
    this.companionNumId,
    this.phoneNumber,
    this.relationToPatient,
  });

  factory Companion.fromRawJson(String str) =>
      Companion.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Companion.fromJson(Map<String, dynamic> json) => Companion(
    fullName: json["full_name"],
    companionNumId: json["companion_num_id"],
    phoneNumber: json["phone_number"],
    relationToPatient: json["relation_to_patient"],
  );

  Map<String, dynamic> toJson() => {
    "full_name": fullName,
    "companion_num_id": companionNumId,
    "phone_number": phoneNumber,
    "relation_to_patient": relationToPatient,
  };
}

class Driver {
  String? photoInfo;
  String? driverPhone;
  String? carType;
  String? driverName;
  String? carserviceType;
  String? idTransport;
  String? dropoffTime;
  DateTime? serviceDate;
  DateTime? submissionTime;
  String? expenses;
  String? carLicense;
  String? pickupTime;
  String? officialName;

  Driver({
    this.photoInfo,
    this.driverPhone,
    this.carType,
    this.driverName,
    this.carserviceType,
    this.idTransport,
    this.dropoffTime,
    this.serviceDate,
    this.submissionTime,
    this.expenses,
    this.carLicense,
    this.pickupTime,
    this.officialName,
  });

  factory Driver.fromRawJson(String str) => Driver.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Driver.fromJson(Map<String, dynamic> json) => Driver(
    photoInfo: json["photo_info"],
    driverPhone: json["driver_phone"],
    carType: json["car_type"],
    driverName: json["driver_name"],
    carserviceType: json["carservice_type"],
    idTransport: json["id_transport"],
    dropoffTime: json["dropoff_time"],
    serviceDate: json["service_date"] == null
        ? null
        : DateTime.parse(json["service_date"]),
    submissionTime: json["submission_time"] == null
        ? null
        : DateTime.parse(json["submission_time"]),
    expenses: json["expenses"],
    carLicense: json["car_license"],
    pickupTime: json["pickup_time"],
    officialName: json["official_name"],
  );

  Map<String, dynamic> toJson() => {
    "photo_info": photoInfo,
    "driver_phone": driverPhone,
    "car_type": carType,
    "driver_name": driverName,
    "carservice_type": carserviceType,
    "id_transport": idTransport,
    "dropoff_time": dropoffTime,
    "service_date":
        "${serviceDate!.year.toString().padLeft(4, '0')}-${serviceDate!.month.toString().padLeft(2, '0')}-${serviceDate!.day.toString().padLeft(2, '0')}",
    "submission_time": submissionTime?.toIso8601String(),
    "expenses": expenses,
    "car_license": carLicense,
    "pickup_time": pickupTime,
    "official_name": officialName,
  };
}

class PatientInfo {
  String? patientType;
  String? mobilityAbility;
  String? phoneNumber;
  String? districtName;
  String? provinceName;
  String? nationalId;
  String? serviceType;
  String? serviceStep;
  String? subdistrictName;
  String? photoDocument;
  String? dateOfBirth;
  String? fullName;
  String? medicalDiagnosis;
  String? noted;

  PatientInfo({
    this.patientType,
    this.mobilityAbility,
    this.phoneNumber,
    this.districtName,
    this.provinceName,
    this.nationalId,
    this.serviceType,
    this.serviceStep,
    this.subdistrictName,
    this.photoDocument,
    this.dateOfBirth,
    this.fullName,
    this.medicalDiagnosis,
    this.noted,
  });

  factory PatientInfo.fromRawJson(String str) =>
      PatientInfo.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PatientInfo.fromJson(Map<String, dynamic> json) => PatientInfo(
    patientType: json["patient_type"],
    mobilityAbility: json["mobility_ability"],
    phoneNumber: json["phone_number"],
    districtName: json["district_name"],
    provinceName: json["province_name"],
    nationalId: json["national_id"],
    serviceType: json["service_type"],
    serviceStep: json["service_step"],
    subdistrictName: json["subdistrict_name"],
    photoDocument: json["photo_document"],
    dateOfBirth: json["date_of_birth"],
    fullName: json["full_name"],
    medicalDiagnosis: json["medical_diagnosis"],
    noted: json["noted"],
  );

  Map<String, dynamic> toJson() => {
    "patient_type": patientType,
    "mobility_ability": mobilityAbility,
    "phone_number": phoneNumber,
    "district_name": districtName,
    "province_name": provinceName,
    "national_id": nationalId,
    "service_type": serviceType,
    "service_step": serviceStep,
    "subdistrict_name": subdistrictName,
    "photo_document": photoDocument,
    "date_of_birth": dateOfBirth,
    "full_name": fullName,
    "medical_diagnosis": medicalDiagnosis,
    "noted": noted,
  };
}

class Status {
  String? noted;
  String? recordedByBookrod;
  String? contactInfo;
  String? reason;
  String? timeDone;
  String? satisfactionPoint;
  String? status;
  String? resultAppoint;
  String? proof;
  DateTime? dateDone;
  String? recordedByConfirm;

  Status({
    this.noted,
    this.recordedByBookrod,
    this.contactInfo,
    this.reason,
    this.timeDone,
    this.satisfactionPoint,
    this.status,
    this.resultAppoint,
    this.proof,
    this.dateDone,
    this.recordedByConfirm,
  });

  factory Status.fromRawJson(String str) => Status.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Status.fromJson(Map<String, dynamic> json) => Status(
    noted: json["noted"],
    recordedByBookrod: json["recorded_by_bookrod"],
    contactInfo: json["contact_info"],
    reason: json["reason"],
    timeDone: json["time_done"],
    satisfactionPoint: json["satisfaction_point"],
    status: json["status"],
    resultAppoint: json["result_appoint"],
    proof: json["proof"],
    dateDone: json["date_done"] == null
        ? null
        : DateTime.parse(json["date_done"]),
    recordedByConfirm: json["recorded_by_confirm"],
  );

  Map<String, dynamic> toJson() => {
    "noted": noted,
    "recorded_by_bookrod": recordedByBookrod,
    "contact_info": contactInfo,
    "reason": reason,
    "time_done": timeDone,
    "satisfaction_point": satisfactionPoint,
    "status": status,
    "result_appoint": resultAppoint,
    "proof": proof,
    "date_done":
        "${dateDone!.year.toString().padLeft(4, '0')}-${dateDone!.month.toString().padLeft(2, '0')}-${dateDone!.day.toString().padLeft(2, '0')}",
    "recorded_by_confirm": recordedByConfirm,
  };
}

class TransportRequest {
  bool? departureSchedule;
  Location? dropoffLocation;
  Location? pickupLocation;
  String? id;

  TransportRequest({
    this.departureSchedule,
    this.dropoffLocation,
    this.pickupLocation,
    this.id,
  });

  factory TransportRequest.fromRawJson(String str) =>
      TransportRequest.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory TransportRequest.fromJson(Map<String, dynamic> json) =>
      TransportRequest(
        departureSchedule: json["departure_schedule"],
        dropoffLocation: json["dropoff_location"] == null
            ? null
            : Location.fromJson(json["dropoff_location"]),
        pickupLocation: json["pickup_location"] == null
            ? null
            : Location.fromJson(json["pickup_location"]),
        id: json["id"],
      );

  Map<String, dynamic> toJson() => {
    "departure_schedule": departureSchedule,
    "dropoff_location": dropoffLocation?.toJson(),
    "pickup_location": pickupLocation?.toJson(),
    "id": id,
  };
}

class Location {
  String? province;
  String? district;
  String? landmark;
  String? subdistrict;
  String? dropoffPlace;
  String? pickupPlace;

  Location({
    this.province,
    this.district,
    this.landmark,
    this.subdistrict,
    this.dropoffPlace,
    this.pickupPlace,
  });

  factory Location.fromRawJson(String str) =>
      Location.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Location.fromJson(Map<String, dynamic> json) => Location(
    province: json["province"],
    district: json["district"],
    landmark: json["landmark"],
    subdistrict: json["subdistrict"],
    dropoffPlace: json["dropoff_place"],
    pickupPlace: json["pickup_place"],
  );

  Map<String, dynamic> toJson() => {
    "province": province,
    "district": district,
    "landmark": landmark,
    "subdistrict": subdistrict,
    "dropoff_place": dropoffPlace,
    "pickup_place": pickupPlace,
  };
}

class TravelMode {
  String? pickupTime2;
  DateTime? serviceDate2;
  String? dropoffTime2;
  String? pickupPlaceMap;
  String? distanceKm2;
  String? dropoffPlaceMap;
  String? distanceKm;
  String? pickupTime;
  DateTime? serviceDate;
  String? shuttleServiceName;
  String? dropoffTime;
  String? shuttleType;

  TravelMode({
    this.pickupTime2,
    this.serviceDate2,
    this.dropoffTime2,
    this.pickupPlaceMap,
    this.distanceKm2,
    this.dropoffPlaceMap,
    this.distanceKm,
    this.pickupTime,
    this.serviceDate,
    this.shuttleServiceName,
    this.dropoffTime,
    this.shuttleType,
  });

  factory TravelMode.fromRawJson(String str) =>
      TravelMode.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory TravelMode.fromJson(Map<String, dynamic> json) => TravelMode(
    pickupTime2: json["pickup_time2"],
    serviceDate2: json["service_date2"] == null
        ? null
        : DateTime.parse(json["service_date2"]),
    dropoffTime2: json["dropoff_time2"],
    pickupPlaceMap: json["pickup_place_map"],
    distanceKm2: json["distance_km2"],
    dropoffPlaceMap: json["dropoff_place_map"],
    distanceKm: json["distance_km"],
    pickupTime: json["pickup_time"],
    serviceDate: json["service_date"] == null
        ? null
        : DateTime.parse(json["service_date"]),
    shuttleServiceName: json["shuttle_service_name"],
    dropoffTime: json["dropoff_time"],
    shuttleType: json["shuttle_type"],
  );

  Map<String, dynamic> toJson() => {
    "pickup_time2": pickupTime2,
    "service_date2":
        "${serviceDate2!.year.toString().padLeft(4, '0')}-${serviceDate2!.month.toString().padLeft(2, '0')}-${serviceDate2!.day.toString().padLeft(2, '0')}",
    "dropoff_time2": dropoffTime2,
    "pickup_place_map": pickupPlaceMap,
    "distance_km2": distanceKm2,
    "dropoff_place_map": dropoffPlaceMap,
    "distance_km": distanceKm,
    "pickup_time": pickupTime,
    "service_date":
        "${serviceDate!.year.toString().padLeft(4, '0')}-${serviceDate!.month.toString().padLeft(2, '0')}-${serviceDate!.day.toString().padLeft(2, '0')}",
    "shuttle_service_name": shuttleServiceName,
    "dropoff_time": dropoffTime,
    "shuttle_type": shuttleType,
  };
}
