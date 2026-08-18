import 'dart:convert';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:rodzendai_form/core/constants/message_constant.dart';
import 'package:rodzendai_form/core/services/service_locator.dart';
import 'package:rodzendai_form/core/utils/env_helper.dart';
import 'package:rodzendai_form/core/utils/mime_helper.dart';
import 'package:rodzendai_form/models/create_appointment_response_model.dart';
import 'package:rodzendai_form/presentation/register/widgets/box_upload_file_widget.dart';
import 'package:rodzendai_form/repositories/appointment_repository.dart';
import 'package:rodzendai_form/repositories/firebase_repository.dart';
import 'package:rodzendai_form/repositories/firebase_storeage_repository.dart';

part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final FirebaseRepository _firebaseRepository;
  final FirebaseStorageRepository _firebaseStorageRepository;
  RegisterBloc({
    required FirebaseRepository firebaseRepository,
    required FirebaseStorageRepository firebaseStorageRepository,
  }) : _firebaseRepository = firebaseRepository,
       _firebaseStorageRepository = firebaseStorageRepository,
       super(RegisterInitial()) {
    on<RegisterRequestEvent>(onRegisterRequestEvent);
  }

  onRegisterRequestEvent(
    RegisterRequestEvent event,
    Emitter<RegisterState> emit,
  ) async {
    try {
      emit(RegisterLoading());
      Map<String, dynamic> requestData = event.data;
      Map<String, dynamic> requestDataCaseCRM = event.dataCaseCRM;

      final AppointmentRepository patientRepository =
          locator<AppointmentRepository>();
      String? patientIdCardNumber = event.data['patientIdCard'];
      FormData formdata = FormData.fromMap({
        "data": {
          "data": json.encode(requestData),
          "dataCaseCRM": json.encode(requestDataCaseCRM),
        },
      });

      if (event.documentAppointmentFile != null) {
        final mime = MimeHelper.getMimeType(
          event.documentAppointmentFile!.extension,
        ); // เช่น "image/jpeg"
        final file = MultipartFile.fromBytes(
          event.documentAppointmentFile!.bytes,
          filename: event.documentAppointmentFile!.name,
          contentType: mime != null
              ? MediaType(mime.split('/').first, mime.split('/').last)
              : null,
        );
        formdata.files.add(MapEntry('appointmentDocument', file));
      }
      final response = await patientRepository.createAppointment(
        patientIdCardNumber: patientIdCardNumber,
        formdata: formdata,
      );
      if (response.success == false) {
        log('RegisterRequestEvent error -> ${response.message}');
        log('RegisterRequestEvent error -> ${response.data?.message}');

        emit(
          RegisterFailure(
            message: response.data?.message ?? MessageConstant.defaultError,
          ),
        );
        return;
      }
      log('Response from createAppointment: $response');

      emit(RegisterSuccess(appointmentDates: response.data?.list ?? []));
    } catch (e) {
      log('RegisterRequestEvent catch -> ${e.toString()}');
      emit(RegisterFailure(message: e.toString()));
    }

    //  on<RegisterRequestEvent>((
    //     RegisterRequestEvent event,
    //     Emitter<RegisterState> emit,
    //   ) async {
    //     try {
    //       emit(RegisterLoading());
    //       Map<String, dynamic> requestData = event.data;

    //       String? patientIdCardNumber = event.data['patientIdCard'];
    //       String? appointmentDate = event.data['appointmentDate'];

    //       log('patientIdCard: $patientIdCardNumber');
    //       log('appointmentDate: $appointmentDate');

    //       final bool isAlreadyRegistered = await _firebaseRepository
    //           .checkRegisterExits(
    //             patientIdCardNumber: patientIdCardNumber,
    //             appointmentDate: DateTime.parse(appointmentDate!),
    //           );
    //       log('isAlreadyRegistered: $isAlreadyRegistered');

    //       if (isAlreadyRegistered) {
    //         emit(RegisterFailure(message: 'already_registered'));
    //         return;
    //       }

    //       log('🔔 Register data: $requestData');

    //       log('documentAppointmentFile: ${event.documentAppointmentFile?.name}');
    //       log(
    //         'documentAppointmentFile: ${event.documentAppointmentFile?.bytes.lengthInBytes}',
    //       );
    //       log(
    //         'documentAppointmentFile: ${event.documentAppointmentFile?.extension}',
    //       );

    //       if (event.documentAppointmentFile?.bytes != null) {
    //         // สร้างชื่อไฟล์ที่ไม่ซ้ำกันโดยใช้ timestamp
    //         final timestamp = DateTime.now().millisecondsSinceEpoch;
    //         final originalFileName = event.documentAppointmentFile!.name;
    //         final fileExtension = originalFileName.split('.').last.toLowerCase();
    //         final fileName = '${timestamp}_$patientIdCardNumber.$fileExtension';

    //         // กำหนด Content-Type ตามนามสกุลไฟล์
    //         String? contentType;
    //         switch (fileExtension) {
    //           case 'pdf':
    //             contentType = 'application/pdf';
    //             break;
    //           case 'jpg':
    //           case 'jpeg':
    //             contentType = 'image/jpeg';
    //             break;
    //           case 'png':
    //             contentType = 'image/png';
    //             break;
    //           default:
    //             contentType = 'application/octet-stream';
    //         }

    //         // ใช้ EnvHelper.getStoragePath() เพื่อแยก path ระหว่าง sandbox และ production
    //         final basePath = 'appointment_docs/$patientIdCardNumber';
    //         final storagePath = EnvHelper.getStoragePath(basePath);

    //         log('📁 Environment: ${EnvHelper.environment}');
    //         log('📁 Storage path: $storagePath/$fileName');
    //         log('📄 Content-Type: $contentType');

    //         String? fileUrl = await _firebaseStorageRepository.uploadFile(
    //           fileBytes: event.documentAppointmentFile!.bytes,
    //           path: '$storagePath/$fileName',
    //           contentType: contentType,
    //         );

    //         log('✅ อัปโหลดไฟล์สำเร็จ: $fileUrl');

    //         if (fileUrl != null && fileUrl.isNotEmpty) {
    //           requestData['appointmentDocumentName'] = fileName;
    //           requestData['appointmentDocumentUrl'] = fileUrl;
    //           requestData['appointmentDocumentOriginalFileName'] =
    //               originalFileName;
    //         }
    //       }

    //       await _firebaseRepository.register(data: requestData);

    //       try {
    //         log('call api to case crm ');
    //         final dio = Dio();
    //         final response = await dio.post(
    //           EnvHelper.baseUrlCasesCRM,
    //           data: event.dataCaseCRM,
    //           options: Options(headers: {'Content-Type': 'application/json'}),
    //         );
    //         if (response.statusCode == 200) {
    //           log(
    //             '✅ CRM response: ${response.data} ${event.dataCaseCRM['case_id']}',
    //           );
    //         } else {
    //           log(
    //             '❌ CRM error: ${response.statusCode} - ${response.statusMessage}',
    //           );
    //         }

    //         log('✅ Sent notification to CRM system');
    //       } catch (e) {
    //         log('❌ Error sending notification: $e');
    //       }
    //       emit(RegisterSuccess());
    //     } catch (e) {
    //       emit(RegisterFailure());
    //     }
    //   });
    // }
  }
}
