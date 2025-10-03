import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rodzendai_form/models/patient_transports_model.dart';
import 'package:rodzendai_form/models/patient_transports_case_crm_model.dart';

class FirebaseRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

      final docRef = _firestore.collection('patient_transports').doc();
      log('Document reference created with ID: ${docRef.id}');

      //check ว่ามีกี่ document
      // await _firestore.collection('patient_transports').count().get().then((
      //   value,
      // ) {
      //   log('Total documents in patient_transports: ${value.count}');
      // });

      final querySnapshot = await _firestore
          .collection('patient_transports')
          .where('patientIdCard', isEqualTo: idCardNumber)
          .where('appointmentDate', isEqualTo: appointmentDate)
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
        // log('Document processed: ${json.encode(result)}');
        // return result;
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

      final docRef = _firestore.collection('patient_transports').doc();
      log('Document reference created with ID: ${docRef.id}');

      //check ว่ามีกี่ document
      // await _firestore.collection('patient_transports').count().get().then((
      //   value,
      // ) {
      //   log('Total documents in patient_transports: ${value.count}');
      // });

      final querySnapshot = await _firestore
          .collection('casefromCRM')
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
      log('Error checking registration status: ${e.toString()}');
      //throw Exception('ไม่สามารถดึงข้อมูลได้: ${e.toString()}');
      return [];
    }
  }

  Future<List<PatientTransportsCaseCrmModel>> checkRegisterExits({
    required String patientIdCardNumber,
    required DateTime appointmentDate,
  }) async {
    try {
      log(
        'Checking registration for ID: $patientIdCardNumber on Date: $appointmentDate',
      );

      String formattedAppointmentDate =
          '${appointmentDate.year}-${appointmentDate.month.toString().padLeft(2, '0')}-${appointmentDate.day.toString().padLeft(2, '0')}';
      log('Formatted appointmentDate: $formattedAppointmentDate');

      final docRef = _firestore.collection('patient_transports').doc();
      log('Document reference created with ID: ${docRef.id}');

      //check ว่ามีกี่ document
      // await _firestore.collection('patient_transports').count().get().then((
      //   value,
      // ) {
      //   log('Total documents in patient_transports: ${value.count}');
      // });

      final querySnapshot = await _firestore
          .collection('casefromCRM')
          .where('patient_info.national_id', isEqualTo: patientIdCardNumber)
          .where(
            'appointment_info.appointment_date',
            isEqualTo: formattedAppointmentDate,
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
      log('Error checking registration status: ${e.toString()}');
      //throw Exception('ไม่สามารถดึงข้อมูลได้: ${e.toString()}');
      return [];
    }
  }
}
