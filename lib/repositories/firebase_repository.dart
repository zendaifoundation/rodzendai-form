import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rodzendai_form/core/utils/env_helper.dart';
import 'package:rodzendai_form/models/patient_transports_model.dart';
import 'package:rodzendai_form/models/patient_transports_case_crm_model.dart';

class FirebaseRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get patientTransportsCollection {
    if (EnvHelper.isProduction) {
      return _firestore.collection('patient_transports');
    }
    return _firestore.collection('sandbox/patient_transports/lists');
  }

  CollectionReference<Map<String, dynamic>> get casefromCRMCollection {
    if (EnvHelper.isProduction) {
      return _firestore.collection('casefromCRM');
    }
    return _firestore.collection('sandbox/casefromCRM/lists');
  }

  CollectionReference<Map<String, dynamic>> get patientCollection {
    if (EnvHelper.isProduction) {
      return _firestore.collection('patients');
    }
    return _firestore.collection('sandbox/patients/lists');
  }

  /// ตรวจสอบสถานะการจองจากเลขบัตรประชาชนและวันที่เดินทาง
  Future<List<PatientTransportsModel>> checkRegisterStatus({
    required String idCardNumber,
    required DateTime travelDate,
  }) async {
    try {
      log('Checking registration for ID: $idCardNumber on Date: $travelDate');

      String appointmentDate =
          '${travelDate.year}-${travelDate.month.toString().padLeft(2, '0')}-${travelDate.day.toString().padLeft(2, '0')}';
      log('Formatted appointmentDate: $appointmentDate');

      final querySnapshot = await patientTransportsCollection
          .where('patientIdCard', isEqualTo: idCardNumber)
          .where('appointmentDate', isEqualTo: appointmentDate)
          .get();

      log('Query executed, found ${querySnapshot.docs.length} documents');

      if (querySnapshot.docs.isEmpty) {
        return [];
      }

      final data = querySnapshot.docs.map((doc) {
        final docData = doc.data();

        // แปลง Timestamp เป็น String ที่อ่านได้
        final Map<String, dynamic> processedData = {};
        docData.forEach((key, value) {
          if (value is Timestamp) {
            // กรณีที่เป็น Timestamp object จาก Firestore
            processedData[key] = value.toDate().toIso8601String();
          } else if (value is Map && value.containsKey('_seconds')) {
            // กรณีที่เป็น Map {_seconds: ..., _nanoseconds: ...}
            final seconds = value['_seconds'] as int;
            final nanoseconds = value['_nanoseconds'] as int;
            final dateTime = DateTime.fromMillisecondsSinceEpoch(
              seconds * 1000 + nanoseconds ~/ 1000000,
            );
            processedData[key] = dateTime.toIso8601String();
          } else {
            processedData[key] = value;
          }
        });

        final result = {'id': doc.id, ...processedData};
        var model = PatientTransportsModel.fromJson(result);

        return model;
      }).toList();

      log('Total documents processed: ${data.length}');
      return data;
    } catch (e) {
      log('Error checking registration status: ${e.toString()}');
      //throw Exception('ไม่สามารถดึงข้อมูลได้: ${e.toString()}');
      return [];
    }
  }

  /// ตรวจสอบสถานะการจองจากเลขบัตรประชาชนและวันที่เดินทาง
  Future<List<PatientTransportsCaseCrmModel>> checkRegisterStatusCasefromCRM({
    required String idCardNumber,
    required DateTime travelDate,
  }) async {
    try {
      log(
        'Checking registration case from crm for ID: $idCardNumber on Date: $travelDate',
      );

      String appointmentDate =
          '${travelDate.year}-${travelDate.month.toString().padLeft(2, '0')}-${travelDate.day.toString().padLeft(2, '0')}';
      log('Formatted appointmentDate: $appointmentDate');

      final querySnapshot = await casefromCRMCollection
          .where('patient_info.national_id', isEqualTo: idCardNumber)
          .where(
            'appointment_info.appointment_date',
            isEqualTo: appointmentDate,
          )
          .get();

      log('Query executed, found ${querySnapshot.docs.length} documents');

      if (querySnapshot.docs.isEmpty) {
        return [];
      }

      final data = querySnapshot.docs.map((doc) {
        final docData = doc.data();

        // // แปลง Timestamp เป็น String ที่อ่านได้
        final Map<String, dynamic> processedData = {};
        docData.forEach((key, value) {
          if (value is Timestamp) {
            processedData[key] = value.toDate().toIso8601String();
          } else {
            processedData[key] = value;
          }
        });

        final result = {'id': doc.id, ...processedData};
        //log('Document processed: ${json.encode(result)}');
        var model = PatientTransportsCaseCrmModel.fromJson(result);

        return model;
      }).toList();

      log('Total documents processed: ${data.length}');
      return data;
    } catch (e) {
      log(
        ' Error checking registration  status case from crm: ${e.toString()}',
      );
      //throw Exception('ไม่สามารถดึงข้อมูลได้: ${e.toString()}');
      return [];
    }
  }

  Future<bool> checkRegisterExits({
    required String? patientIdCardNumber,
    required DateTime? appointmentDate,
  }) async {
    try {
      log(
        'Checking registration for ID: $patientIdCardNumber on Date: $appointmentDate',
      );

      String formattedAppointmentDate =
          '${appointmentDate?.year}-${appointmentDate?.month.toString().padLeft(2, '0')}-${appointmentDate?.day.toString().padLeft(2, '0')}';
      log('Formatted appointmentDate: $formattedAppointmentDate');

      final queryCasefromCRMSnapshot = await casefromCRMCollection
          .where('patient_info.national_id', isEqualTo: patientIdCardNumber)
          .where(
            'appointment_info.appointment_date',
            isEqualTo: formattedAppointmentDate,
          )
          .limit(1)
          .get();

      log(
        'Query casefromCRM , found ${queryCasefromCRMSnapshot.docs.length} documents',
      );

      if (queryCasefromCRMSnapshot.docs.isNotEmpty) {
        return true;
      }

      final queryPatientTransportsSnapshot = await patientTransportsCollection
          .where('patientIdCard', isEqualTo: patientIdCardNumber)
          .where('appointmentDate', isEqualTo: formattedAppointmentDate)
          .limit(1)
          .get();

      log(
        'Query patientTransports  , found ${queryPatientTransportsSnapshot.docs.length} documents',
      );

      if (queryPatientTransportsSnapshot.docs.isNotEmpty) {
        return true;
      }
      return false;
    } catch (e) {
      log('Error checking registration exists status: ${e.toString()}');
      throw Exception('ไม่สามารถดึงข้อมูลได้: ${e.toString()}');
    }
  }

  Future<void> register({required Map<String, dynamic> data}) async {
    try {
      final docRef = patientTransportsCollection.doc();
      log('Document reference created with ID: ${docRef.id}');

      final now = DateTime.now();
      // เพิ่ม server timestamp ตอนบันทึกจริง
      final Map<String, dynamic> dataWithId = {
        'id': docRef.id,
        ...data,
        'timestamp': {
          '_seconds': now.millisecondsSinceEpoch ~/ 1000,
          '_nanoseconds': (now.millisecondsSinceEpoch % 1000) * 1000000,
        },
      };

      await patientTransportsCollection.add(dataWithId);

      log('Registration successful');
    } catch (e) {
      log('Error register status: ${e.toString()}');
      throw Exception(e);
    }
  }

  //เช็คสิทธิ์
  Future<bool> checkRegisterClaimExits({
    required String? patientIdCardNumber,
  }) async {
    try {
      log('Checking registration for ID: $patientIdCardNumber ');

      final patientSnapshot = await patientCollection
          .where('patientIdCard', isEqualTo: patientIdCardNumber)
          .limit(1)
          .get();

      log('Query casefromCRM , found ${patientSnapshot.docs.length} documents');

      if (patientSnapshot.docs.isNotEmpty) {
        return true;
      }

      return false;
    } catch (e) {
      log('Error checking registration exists status: ${e.toString()}');
      throw Exception('ไม่สามารถดึงข้อมูลได้: ${e.toString()}');
    }
  }

  Future<void> registerPatient({required Map<String, dynamic> data}) async {
    try {
      final docRef = patientCollection.doc();
      log('Document reference created with ID: ${docRef.id}');

      final now = DateTime.now();
      // เพิ่ม server timestamp ตอนบันทึกจริง
      final Map<String, dynamic> dataWithId = {
        'id': docRef.id,
        ...data,
        'timestamp': {
          '_seconds': now.millisecondsSinceEpoch ~/ 1000,
          '_nanoseconds': (now.millisecondsSinceEpoch % 1000) * 1000000,
        },
      };

      await docRef.set(dataWithId);

      log('Registration successful');
    } catch (e) {
      log('Error register status: ${e.toString()}');
      throw Exception(e);
    }
  }
}
