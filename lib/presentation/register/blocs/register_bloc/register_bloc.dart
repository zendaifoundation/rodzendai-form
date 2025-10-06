import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rodzendai_form/core/constants/message_constant.dart';
import 'package:rodzendai_form/core/utils/env_helper.dart';
import 'package:rodzendai_form/presentation/register/widgets/box_upload_file_widget.dart';
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
    on<RegisterRequestEvent>((
      RegisterRequestEvent event,
      Emitter<RegisterState> emit,
    ) async {
      try {
        emit(RegisterLoading());
        Map<String, dynamic> requestData = event.data;
        String? patientIdCardNumber = event.data['patientIdCard'];
        String? appointmentDate = event.data['appointmentDate'];

        log('patientIdCard: $patientIdCardNumber');
        log('appointmentDate: $appointmentDate');

        final bool isAlreadyRegistered = await _firebaseRepository
            .checkRegisterExits(
              patientIdCardNumber: patientIdCardNumber,
              appointmentDate: DateTime.parse(appointmentDate!),
            );
        log('isAlreadyRegistered: $isAlreadyRegistered');

        if (isAlreadyRegistered) {
          emit(RegisterFailure(message: 'already_registered'));
          return;
        }

        log('🔔 Register data: $requestData');

        log('documentAppointmentFile: ${event.documentAppointmentFile?.name}');
        log(
          'documentAppointmentFile: ${event.documentAppointmentFile?.bytes.lengthInBytes}',
        );
        log(
          'documentAppointmentFile: ${event.documentAppointmentFile?.extension}',
        );

        if (event.documentAppointmentFile?.bytes != null) {
          // สร้างชื่อไฟล์ที่ไม่ซ้ำกันโดยใช้ timestamp
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final originalFileName = event.documentAppointmentFile!.name;
          final fileExtension = originalFileName.split('.').last.toLowerCase();
          final fileName = '${timestamp}_$patientIdCardNumber.$fileExtension';

          // กำหนด Content-Type ตามนามสกุลไฟล์
          String? contentType;
          switch (fileExtension) {
            case 'pdf':
              contentType = 'application/pdf';
              break;
            case 'jpg':
            case 'jpeg':
              contentType = 'image/jpeg';
              break;
            case 'png':
              contentType = 'image/png';
              break;
            default:
              contentType = 'application/octet-stream';
          }

          // ใช้ EnvHelper.getStoragePath() เพื่อแยก path ระหว่าง sandbox และ production
          final basePath = 'appointment_docs/$patientIdCardNumber';
          final storagePath = EnvHelper.getStoragePath(basePath);

          log('📁 Environment: ${EnvHelper.environment}');
          log('📁 Storage path: $storagePath/$fileName');
          log('📄 Content-Type: $contentType');

          String? fileUrl = await _firebaseStorageRepository.uploadFile(
            fileBytes: event.documentAppointmentFile!.bytes,
            path: '$storagePath/$fileName',
            contentType: contentType,
          );

          log('✅ อัปโหลดไฟล์สำเร็จ: $fileUrl');

          if (fileUrl != null && fileUrl.isNotEmpty) {
            requestData['appointmentDocumentName'] = fileName;
            requestData['appointmentDocumentUrl'] = fileUrl;
          }
        }

        await _firebaseRepository.register(data: requestData);
        emit(RegisterSuccess());
      } catch (e) {
        emit(RegisterFailure());
      }
    });
  }
}
