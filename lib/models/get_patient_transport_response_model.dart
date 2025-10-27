import 'dart:convert';

class GetPatientTransportResponseModel {
    String? code;
    bool? success;
    String? message;
    List<PatientTransport>? data;

    GetPatientTransportResponseModel({
        this.code,
        this.success,
        this.message,
        this.data,
    });

    factory GetPatientTransportResponseModel.fromRawJson(String str) => GetPatientTransportResponseModel.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory GetPatientTransportResponseModel.fromJson(Map<String, dynamic> json) => GetPatientTransportResponseModel(
        code: json["code"],
        success: json["success"],
        message: json["message"],
        data: json["data"] == null ? [] : List<PatientTransport>.from(json["data"]!.map((x) => PatientTransport.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "code": code,
        "success": success,
        "message": message,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    };
}

class PatientTransport {
    String? id;
    String? caseId;
    PatientInfo? patientInfo;
    AppointmentInfo? appointmentInfo;
    dynamic caseEvaluation;
    List<Companion>? reporterInfo;
    List<Companion>? companions;
    List<TransportRequest>? transportRequest;
    AtedAt? createdAt;
    String? transportationTypes;
    TravelMode? travelMode;
    String? recordedBy;
    DateTime? recordedDate;
    List<Driver>? driver;
    Status? status;
    AtedAt? updatedAt;

    PatientTransport({
        this.id,
        this.caseId,
        this.patientInfo,
        this.appointmentInfo,
        this.caseEvaluation,
        this.reporterInfo,
        this.companions,
        this.transportRequest,
        this.createdAt,
        this.transportationTypes,
        this.travelMode,
        this.recordedBy,
        this.recordedDate,
        this.driver,
        this.status,
        this.updatedAt,
    });

    factory PatientTransport.fromRawJson(String str) => PatientTransport.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory PatientTransport.fromJson(Map<String, dynamic> json) => PatientTransport(
        id: json["id"],
        caseId: json["case_id"],
        patientInfo: json["patient_info"] == null ? null : PatientInfo.fromJson(json["patient_info"]),
        appointmentInfo: json["appointment_info"] == null ? null : AppointmentInfo.fromJson(json["appointment_info"]),
        caseEvaluation: json["case_evaluation"],
        reporterInfo: json["reporter_info"] == null ? [] : List<Companion>.from(json["reporter_info"]!.map((x) => Companion.fromJson(x))),
        companions: json["companions"] == null ? [] : List<Companion>.from(json["companions"]!.map((x) => Companion.fromJson(x))),
        transportRequest: json["transport_request"] == null ? [] : List<TransportRequest>.from(json["transport_request"]!.map((x) => TransportRequest.fromJson(x))),
        createdAt: json["createdAt"] == null ? null : AtedAt.fromJson(json["createdAt"]),
        transportationTypes: json["transportationTypes"],
        travelMode: json["travel_mode"] == null ? null : TravelMode.fromJson(json["travel_mode"]),
        recordedBy: json["recorded_by"],
        recordedDate: json["recorded_date"] == null ? null : DateTime.parse(json["recorded_date"]),
        driver: json["driver"] == null ? [] : List<Driver>.from(json["driver"]!.map((x) => Driver.fromJson(x))),
        status: json["status"] == null ? null : Status.fromJson(json["status"]),
        updatedAt: json["updatedAt"] == null ? null : AtedAt.fromJson(json["updatedAt"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "case_id": caseId,
        "patient_info": patientInfo?.toJson(),
        "appointment_info": appointmentInfo?.toJson(),
        "case_evaluation": caseEvaluation,
        "reporter_info": reporterInfo == null ? [] : List<dynamic>.from(reporterInfo!.map((x) => x.toJson())),
        "companions": companions == null ? [] : List<dynamic>.from(companions!.map((x) => x.toJson())),
        "transport_request": transportRequest == null ? [] : List<dynamic>.from(transportRequest!.map((x) => x.toJson())),
        "createdAt": createdAt?.toJson(),
        "transportationTypes": transportationTypes,
        "travel_mode": travelMode?.toJson(),
        "recorded_by": recordedBy,
        "recorded_date": "${recordedDate!.year.toString().padLeft(4, '0')}-${recordedDate!.month.toString().padLeft(2, '0')}-${recordedDate!.day.toString().padLeft(2, '0')}",
        "driver": driver == null ? [] : List<dynamic>.from(driver!.map((x) => x.toJson())),
        "status": status?.toJson(),
        "updatedAt": updatedAt?.toJson(),
    };
}

class AppointmentInfo {
    DateTime? appointmentDate;
    String? appointmentTime;
    String? hospitalName;
    String? hospitalCode;
    List<PhotoDocument>? photoDocument;

    AppointmentInfo({
        this.appointmentDate,
        this.appointmentTime,
        this.hospitalName,
        this.hospitalCode,
        this.photoDocument,
    });

    factory AppointmentInfo.fromRawJson(String str) => AppointmentInfo.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory AppointmentInfo.fromJson(Map<String, dynamic> json) => AppointmentInfo(
        appointmentDate: json["appointment_date"] == null ? null : DateTime.parse(json["appointment_date"]),
        appointmentTime: json["appointment_time"],
        hospitalName: json["hospital_name"],
        hospitalCode: json["hospital_code"],
        photoDocument: json["photo_document"] == null ? [] : List<PhotoDocument>.from(json["photo_document"]!.map((x) => PhotoDocument.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "appointment_date": "${appointmentDate!.year.toString().padLeft(4, '0')}-${appointmentDate!.month.toString().padLeft(2, '0')}-${appointmentDate!.day.toString().padLeft(2, '0')}",
        "appointment_time": appointmentTime,
        "hospital_name": hospitalName,
        "hospital_code": hospitalCode,
        "photo_document": photoDocument == null ? [] : List<dynamic>.from(photoDocument!.map((x) => x.toJson())),
    };
}

class PhotoDocument {
    String? file;
    String? typeDocument;
    int? order;

    PhotoDocument({
        this.file,
        this.typeDocument,
        this.order,
    });

    factory PhotoDocument.fromRawJson(String str) => PhotoDocument.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory PhotoDocument.fromJson(Map<String, dynamic> json) => PhotoDocument(
        file: json["file"],
        typeDocument: json["type_document"],
        order: json["order"],
    );

    Map<String, dynamic> toJson() => {
        "file": file,
        "type_document": typeDocument,
        "order": order,
    };
}

class Companion {
    String? fullName;
    String? relationToPatient;
    String? phoneNumber;
    String? companionNumId;

    Companion({
        this.fullName,
        this.relationToPatient,
        this.phoneNumber,
        this.companionNumId,
    });

    factory Companion.fromRawJson(String str) => Companion.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Companion.fromJson(Map<String, dynamic> json) => Companion(
        fullName: json["full_name"],
        relationToPatient: json["relation_to_patient"],
        phoneNumber: json["phone_number"],
        companionNumId: json["companion_num_id"],
    );

    Map<String, dynamic> toJson() => {
        "full_name": fullName,
        "relation_to_patient": relationToPatient,
        "phone_number": phoneNumber,
        "companion_num_id": companionNumId,
    };
}

class AtedAt {
    int? seconds;
    int? nanoseconds;

    AtedAt({
        this.seconds,
        this.nanoseconds,
    });

    factory AtedAt.fromRawJson(String str) => AtedAt.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory AtedAt.fromJson(Map<String, dynamic> json) => AtedAt(
        seconds: json["_seconds"],
        nanoseconds: json["_nanoseconds"],
    );

    Map<String, dynamic> toJson() => {
        "_seconds": seconds,
        "_nanoseconds": nanoseconds,
    };
}

class Driver {
    String? idTransport;
    String? carType;
    String? carserviceType;
    String? carLicense;
    String? officialName;
    String? driverName;
    String? driverPhone;
    String? photoInfo;
    String? pickupTime;
    String? dropoffTime;
    DateTime? serviceDate;
    DateTime? submissionTime;
    String? expenses;

    Driver({
        this.idTransport,
        this.carType,
        this.carserviceType,
        this.carLicense,
        this.officialName,
        this.driverName,
        this.driverPhone,
        this.photoInfo,
        this.pickupTime,
        this.dropoffTime,
        this.serviceDate,
        this.submissionTime,
        this.expenses,
    });

    factory Driver.fromRawJson(String str) => Driver.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Driver.fromJson(Map<String, dynamic> json) => Driver(
        idTransport: json["id_transport"],
        carType: json["car_type"],
        carserviceType: json["carservice_type"],
        carLicense: json["car_license"],
        officialName: json["official_name"],
        driverName: json["driver_name"],
        driverPhone: json["driver_phone"],
        photoInfo: json["photo_info"],
        pickupTime: json["pickup_time"],
        dropoffTime: json["dropoff_time"],
        serviceDate: json["service_date"] == null ? null : DateTime.parse(json["service_date"]),
        submissionTime: json["submission_time"] == null ? null : DateTime.parse(json["submission_time"]),
        expenses: json["expenses"],
    );

    Map<String, dynamic> toJson() => {
        "id_transport": idTransport,
        "car_type": carType,
        "carservice_type": carserviceType,
        "car_license": carLicense,
        "official_name": officialName,
        "driver_name": driverName,
        "driver_phone": driverPhone,
        "photo_info": photoInfo,
        "pickup_time": pickupTime,
        "dropoff_time": dropoffTime,
        "service_date": "${serviceDate!.year.toString().padLeft(4, '0')}-${serviceDate!.month.toString().padLeft(2, '0')}-${serviceDate!.day.toString().padLeft(2, '0')}",
        "submission_time": submissionTime?.toIso8601String(),
        "expenses": expenses,
    };
}

class PatientInfo {
    String? fullName;
    String? patientType;
    String? serviceType;
    String? serviceStep;
    String? nationalId;
    String? dateOfBirth;
    String? phoneNumber;
    String? photoDocument;
    String? mobilityAbility;
    String? medicalDiagnosis;
    String? noted;
    String? provinceName;
    String? districtName;
    String? subdistrictName;

    PatientInfo({
        this.fullName,
        this.patientType,
        this.serviceType,
        this.serviceStep,
        this.nationalId,
        this.dateOfBirth,
        this.phoneNumber,
        this.photoDocument,
        this.mobilityAbility,
        this.medicalDiagnosis,
        this.noted,
        this.provinceName,
        this.districtName,
        this.subdistrictName,
    });

    factory PatientInfo.fromRawJson(String str) => PatientInfo.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory PatientInfo.fromJson(Map<String, dynamic> json) => PatientInfo(
        fullName: json["full_name"],
        patientType: json["patient_type"],
        serviceType: json["service_type"],
        serviceStep: json["service_step"],
        nationalId: json["national_id"],
        dateOfBirth: json["date_of_birth"],
        phoneNumber: json["phone_number"],
        photoDocument: json["photo_document"],
        mobilityAbility: json["mobility_ability"],
        medicalDiagnosis: json["medical_diagnosis"],
        noted: json["noted"],
        provinceName: json["province_name"],
        districtName: json["district_name"],
        subdistrictName: json["subdistrict_name"],
    );

    Map<String, dynamic> toJson() => {
        "full_name": fullName,
        "patient_type": patientType,
        "service_type": serviceType,
        "service_step": serviceStep,
        "national_id": nationalId,
        "date_of_birth": dateOfBirth,
        "phone_number": phoneNumber,
        "photo_document": photoDocument,
        "mobility_ability": mobilityAbility,
        "medical_diagnosis": medicalDiagnosis,
        "noted": noted,
        "province_name": provinceName,
        "district_name": districtName,
        "subdistrict_name": subdistrictName,
    };
}

class Status {
    String? status;
    String? contactInfo;
    String? resultAppoint;
    String? recordedByBookrod;
    String? recordedByConfirm;
    DateTime? dateDone;
    String? timeDone;
    String? reason;
    String? noted;
    String? satisfactionPoint;
    String? proof;

    Status({
        this.status,
        this.contactInfo,
        this.resultAppoint,
        this.recordedByBookrod,
        this.recordedByConfirm,
        this.dateDone,
        this.timeDone,
        this.reason,
        this.noted,
        this.satisfactionPoint,
        this.proof,
    });

    factory Status.fromRawJson(String str) => Status.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Status.fromJson(Map<String, dynamic> json) => Status(
        status: json["status"],
        contactInfo: json["contact_info"],
        resultAppoint: json["result_appoint"],
        recordedByBookrod: json["recorded_by_bookrod"],
        recordedByConfirm: json["recorded_by_confirm"],
        dateDone: json["date_done"] == null ? null : DateTime.parse(json["date_done"]),
        timeDone: json["time_done"],
        reason: json["reason"],
        noted: json["noted"],
        satisfactionPoint: json["satisfaction_point"],
        proof: json["proof"],
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "contact_info": contactInfo,
        "result_appoint": resultAppoint,
        "recorded_by_bookrod": recordedByBookrod,
        "recorded_by_confirm": recordedByConfirm,
        "date_done": "${dateDone!.year.toString().padLeft(4, '0')}-${dateDone!.month.toString().padLeft(2, '0')}-${dateDone!.day.toString().padLeft(2, '0')}",
        "time_done": timeDone,
        "reason": reason,
        "noted": noted,
        "satisfaction_point": satisfactionPoint,
        "proof": proof,
    };
}

class TransportRequest {
    String? id;
    bool? returnSchedule;
    Location? pickupLocation;
    Location? dropoffLocation;

    TransportRequest({
        this.id,
        this.returnSchedule,
        this.pickupLocation,
        this.dropoffLocation,
    });

    factory TransportRequest.fromRawJson(String str) => TransportRequest.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory TransportRequest.fromJson(Map<String, dynamic> json) => TransportRequest(
        id: json["id"],
        returnSchedule: json["return_schedule"],
        pickupLocation: json["pickup_location"] == null ? null : Location.fromJson(json["pickup_location"]),
        dropoffLocation: json["dropoff_location"] == null ? null : Location.fromJson(json["dropoff_location"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "return_schedule": returnSchedule,
        "pickup_location": pickupLocation?.toJson(),
        "dropoff_location": dropoffLocation?.toJson(),
    };
}

class Location {
    String? dropoffPlace;
    String? province;
    String? district;
    String? subdistrict;
    String? landmark;
    String? pickupPlace;

    Location({
        this.dropoffPlace,
        this.province,
        this.district,
        this.subdistrict,
        this.landmark,
        this.pickupPlace,
    });

    factory Location.fromRawJson(String str) => Location.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Location.fromJson(Map<String, dynamic> json) => Location(
        dropoffPlace: json["dropoff_place"],
        province: json["province"],
        district: json["district"],
        subdistrict: json["subdistrict"],
        landmark: json["landmark"],
        pickupPlace: json["pickup_place"],
    );

    Map<String, dynamic> toJson() => {
        "dropoff_place": dropoffPlace,
        "province": province,
        "district": district,
        "subdistrict": subdistrict,
        "landmark": landmark,
        "pickup_place": pickupPlace,
    };
}

class TravelMode {
    String? pickupPlaceMap;
    String? dropoffPlaceMap;
    String? shuttleType;
    String? shuttleServiceName;
    DateTime? serviceDate;
    String? distanceKm;
    String? pickupTime;
    String? dropoffTime;
    DateTime? serviceDate2;
    String? distanceKm2;
    String? pickupTime2;
    String? dropoffTime2;

    TravelMode({
        this.pickupPlaceMap,
        this.dropoffPlaceMap,
        this.shuttleType,
        this.shuttleServiceName,
        this.serviceDate,
        this.distanceKm,
        this.pickupTime,
        this.dropoffTime,
        this.serviceDate2,
        this.distanceKm2,
        this.pickupTime2,
        this.dropoffTime2,
    });

    factory TravelMode.fromRawJson(String str) => TravelMode.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory TravelMode.fromJson(Map<String, dynamic> json) => TravelMode(
        pickupPlaceMap: json["pickup_place_map"],
        dropoffPlaceMap: json["dropoff_place_map"],
        shuttleType: json["shuttle_type"],
        shuttleServiceName: json["shuttle_service_name"],
        serviceDate: json["service_date"] == null ? null : DateTime.parse(json["service_date"]),
        distanceKm: json["distance_km"],
        pickupTime: json["pickup_time"],
        dropoffTime: json["dropoff_time"],
        serviceDate2: json["service_date2"] == null ? null : DateTime.parse(json["service_date2"]),
        distanceKm2: json["distance_km2"],
        pickupTime2: json["pickup_time2"],
        dropoffTime2: json["dropoff_time2"],
    );

    Map<String, dynamic> toJson() => {
        "pickup_place_map": pickupPlaceMap,
        "dropoff_place_map": dropoffPlaceMap,
        "shuttle_type": shuttleType,
        "shuttle_service_name": shuttleServiceName,
        "service_date": "${serviceDate!.year.toString().padLeft(4, '0')}-${serviceDate!.month.toString().padLeft(2, '0')}-${serviceDate!.day.toString().padLeft(2, '0')}",
        "distance_km": distanceKm,
        "pickup_time": pickupTime,
        "dropoff_time": dropoffTime,
        "service_date2": "${serviceDate2!.year.toString().padLeft(4, '0')}-${serviceDate2!.month.toString().padLeft(2, '0')}-${serviceDate2!.day.toString().padLeft(2, '0')}",
        "distance_km2": distanceKm2,
        "pickup_time2": pickupTime2,
        "dropoff_time2": dropoffTime2,
    };
}
