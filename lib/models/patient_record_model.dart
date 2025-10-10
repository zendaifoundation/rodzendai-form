class PatientRecordModel {
  PatientRecordModel({
    this.idCardNumber,
    this.patientName,
    this.phoneNumber,
    this.patientType,
    this.hospitalName,
  });
  final String? idCardNumber;
  final String? patientName;
  final String? phoneNumber;
  final String? patientType;
  final String? hospitalName;

  Map<String, dynamic> toJson() {
    return {
      'idCardNumber': idCardNumber,
      'patientName': patientName,
      'phoneNumber': phoneNumber,
      'patientType': patientType,
      'hospitalName': hospitalName,
    };
  }

  factory PatientRecordModel.fromJson(Map<String, dynamic> json) {
    return PatientRecordModel(
      idCardNumber: json['idCardNumber'] as String?,
      patientName: json['patientName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      patientType: json['patientType'] as String?,
      hospitalName: json['hospitalName'] as String?,
    );
  }
}
