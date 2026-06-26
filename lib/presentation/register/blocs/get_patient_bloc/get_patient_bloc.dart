import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rodzendai_form/core/constants/message_constant.dart';
import 'package:rodzendai_form/core/services/service_locator.dart';
import 'package:rodzendai_form/core/utils/env_helper.dart';
import 'package:rodzendai_form/models/patient_response_model.dart';
import 'package:rodzendai_form/repositories/patient_repository.dart';

part 'get_patient_event.dart';
part 'get_patient_state.dart';

class GetPatientBloc extends Bloc<GetPatientEvent, GetPatientState> {
  GetPatientBloc() : super(GetPatientInitial()) {
    on<GetPatientRequestEvent>((
      GetPatientRequestEvent event,
      Emitter<GetPatientState> emit,
    ) async {
      try {
        emit(GetPatientLoading());
        final response = await locator<PatientRepository>()
            .getPatientByIdCardNumber(idCardNumber: event.idCardNumber);
        log('GetPatientBloc Response: $response');
        if (response.code == '00' && response.data != null) {
          final status = response.data?.status?.toLowerCase();

          // เช็ค status ของผู้ป่วย
          if (status == 'pending') {
            return emit(
              GetPatientFailure(
                message:
                    'กำลังรอดำเนินการ\nสามารถติดต่อเจ้าหน้าที่เพื่อสอบถามข้อมูลเพิ่มเติม',
              ),
            );
          }
          //!ปิดการเช็คสถานะ waitting ชั่วคราว เนื่องจากมีผู้ป่วยบางรายที่สถานะยังคงเป็น waitting แต่สามารถใช้สิทธิ์จองรถได้ตามปกติ
          //  else if (status == 'waitting') {
          //   return emit(
          //     GetPatientFailure(
          //       message:
          //           'กำลังรออนุมัติสิทธิ์\nสามารถติดต่อเจ้าหน้าที่เพื่อสอบถามข้อมูลเพิ่มเติม',
          //     ),
          //   );
          // }
          else if (status == 'notapproved') {
            return emit(
              GetPatientFailure(
                message:
                    'สิทธิ์ของท่านไม่ได้รับการอนุมัติ\nสามารถติดต่อเจ้าหน้าที่เพื่อสอบถามข้อมูลเพิ่มเติม',
              ),
            );
          } else if (status == 'canceled') {
            return emit(
              GetPatientFailure(
                message:
                    'สิทธิ์ของท่านถูกยกเลิก\nสามารถติดต่อเจ้าหน้าที่เพื่อสอบถามข้อมูลเพิ่มเติม',
              ),
            );
          }

          //เช็คสิทธิ์คงเหลือ (สำหรับ status = 'approved')
          //เช็คเฉพาะโครงการที่มีการจำกัดจำนวนสิทธิ์เท่านั้น (maxUsage != 0)
          if (response.data?.remainingRights?.remainingRights == 0 &&
              EnvHelper.customerCode != 'samed' &&
              EnvHelper.customerCode != 'pattaya' &&
              EnvHelper.customerCode != 'tessaban_angsila' &&
              response.data?.projectInfo?.maxUsage != 0) {
            return emit(
              GetPatientFailure(
                message:
                    'ไม่สามารถใช้สิทธิ์จองรถได้ เนื่องจากใช้สิทธิ์ครบแล้ว\nสามารถติดต่อเจ้าหน้าที่เพื่อสอบถามข้อมูลเพิ่มเติม',
              ),
            );
          }
          // else {
          //   DateTime? endDate = response.data?.projectInfo?.endDate;
          //   log('endDate -> $endDate');
          //   if (endDate != null || status == 'completed') {
          //     final now = DateTime.now();
          //     if (endDate != null && now.isAfter(endDate) ||
          //         status == 'completed') {
          //       return emit(
          //         GetPatientFailure(
          //           message:
          //               'ไม่สามารถใช้สิทธิ์จองรถได้ เนื่องจากสิ้นสุดระยะเวลาของโครงการแล้ว\nสามารถติดต่อเจ้าหน้าที่เพื่อสอบถามข้อมูลเพิ่มเติม',
          //         ),
          //       );
          //     }
          //   }
          //   return emit(GetPatientSuccess(patientData: response.data!));
          // }
          DateTime? endDate = response.data?.projectInfo?.endDate;
          log('endDate -> $endDate');
          if (endDate != null || status == 'completed') {
            final now = DateTime.now();
            if (endDate != null && now.isAfter(endDate) ||
                status == 'completed') {
              return emit(
                GetPatientFailure(
                  message:
                      'ไม่สามารถใช้สิทธิ์จองรถได้ เนื่องจากสิ้นสุดระยะเวลาของโครงการแล้ว\nสามารถติดต่อเจ้าหน้าที่เพื่อสอบถามข้อมูลเพิ่มเติม',
                ),
              );
            }
          }

          log(
            'response.data?.addresses.registered.provinceCode -> ${response.data?.addresses?.registered?.provinceCode}',
          );
          String? allowedProvinceCode = EnvHelper.allowedProvinceCode;
          if (allowedProvinceCode != null &&
              response.data?.addresses?.registered?.provinceCode != null) {
            int? patientProvinceCode =
                response.data?.addresses?.registered?.provinceCode;
            log('patientProvinceCode -> $patientProvinceCode');
            if (patientProvinceCode.toString() != allowedProvinceCode) {
              return emit(
                GetPatientFailure(
                  message: 'จังหวัดที่ท่านอยู่ ไม่อยู่ในพื้นที่ให้บริการ',
                ),
              );
            }
          }

          return emit(GetPatientSuccess(patientData: response.data!));
        } else {
          return emit(
            GetPatientFailure(
              message:
                  'ไม่พบข้อมูลผู้ป่วยในระบบ กรุณาตรวจสอบหมายเลขบัตรประชาชนอีกครั้ง',
            ),
          );
        }
      } catch (e) {
        log('GetPatientBloc Error: $e');
        String errorMessage = MessageConstant.defaultError;
        if (e.toString().contains('connection error')) {
          //return emit(GetPatientFailure(message: errorMessage));
          errorMessage = MessageConstant.networkError;
        } else if (e.toString().contains('bad request')) {
          errorMessage = 'ข้อมูลไม่ถูกต้อง กรุณาตรวจสอบอีกครั้ง';
        }
        emit(GetPatientFailure(message: errorMessage));
      }
    });
  }
}
