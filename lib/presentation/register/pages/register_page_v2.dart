import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rodzendai_form/core/constants/message_constant.dart';
import 'package:rodzendai_form/core/services/service_locator.dart';
import 'package:rodzendai_form/core/utils/date_helper.dart';
import 'package:rodzendai_form/core/utils/env_helper.dart';
import 'package:rodzendai_form/core/utils/toast_helper.dart';
import 'package:rodzendai_form/models/interfaces/service_type.dart';
import 'package:rodzendai_form/presentation/blocs/province_bloc/province_bloc.dart';
import 'package:rodzendai_form/presentation/register/blocs/get_patient_bloc/get_patient_bloc.dart';
import 'package:rodzendai_form/presentation/register/blocs/hospital_bloc/hospital_bloc.dart';
import 'package:rodzendai_form/presentation/register/blocs/id_card_reader/id_card_reader_bloc.dart';
import 'package:rodzendai_form/presentation/register/blocs/project_bloc/project_bloc.dart';
import 'package:rodzendai_form/presentation/register/blocs/register_bloc/register_bloc.dart';
import 'package:rodzendai_form/presentation/register/dialogs/already_register_dialog.dart';
import 'package:rodzendai_form/presentation/register/dialogs/id_card_request.dart';
import 'package:rodzendai_form/presentation/register/providers/register_provider.dart';
import 'package:rodzendai_form/presentation/register/providers/register_step_provider.dart';
import 'package:rodzendai_form/presentation/register/views/v2/step_appointment_view.dart';
import 'package:rodzendai_form/presentation/register/views/v2/step_contact_view.dart';
import 'package:rodzendai_form/presentation/register/views/v2/step_patient_view.dart';
import 'package:rodzendai_form/presentation/register_status/blocs/get_location_detail_bloc/get_location_detail_bloc.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/widgets/v2/reg_v2_dialogs.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/widgets/v2/reg_v2_step_scaffold.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/widgets/v2/register_v2_theme.dart';
import 'package:rodzendai_form/repositories/firebase_repository.dart';
import 'package:rodzendai_form/repositories/firebase_storeage_repository.dart';
import 'package:rodzendai_form/widgets/dialog/loading_dialog.dart';

/// หน้าจองคิวใช้บริการ v2 — ฟอร์มเดิม ([RegisterProvider] / [RegisterBloc])
/// แต่แบ่งเป็น 3 ขั้นตอนในสไตล์เดียวกับ [RegisterToClaimYourRightsV2Page]
///
/// 1. ตรวจเลขบัตร + ข้อมูลผู้ป่วย/ผู้ติดตามที่ลงทะเบียนไว้ → "เริ่มจองคิวรถ"
/// 2. การนัดหมาย (วินิจฉัย วันนัด หมายเหตุ การเดินทาง โรงพยาบาล ใบนัด)
/// 3. ผู้แจ้งและผู้ติดตาม → "จองคิวรถ"
class RegisterPageV2 extends StatefulWidget {
  const RegisterPageV2({super.key});

  @override
  State<RegisterPageV2> createState() => _RegisterPageV2State();
}

class _RegisterPageV2State extends State<RegisterPageV2> {
  late final RegisterProvider _registerProvider;
  late final RegisterStepProvider _stepProvider;
  late final RegisterBloc _registerBloc;
  late final GetPatientBloc _getPatientBloc;
  late final IdCardReaderBloc _idCardReaderBloc;

  /// กัน pop ซ้ำ: LoadingDialog.hide ใช้ Navigator.pop ถ้าไม่มี dialog เปิดอยู่
  /// จะไป pop หน้านี้ทิ้ง (เด้งกลับหน้าแรก)
  bool _isLoadingShown = false;

  void _showLoading() {
    if (_isLoadingShown) return;
    _isLoadingShown = true;
    LoadingDialog.show(context);
  }

  void _hideLoading() {
    if (!_isLoadingShown) return;
    _isLoadingShown = false;
    LoadingDialog.hide(context);
  }

  @override
  void initState() {
    super.initState();
    _registerProvider = RegisterProvider(
      getLocationDetailBloc: context.read<GetLocationDetailBloc>(),
    );
    _stepProvider = RegisterStepProvider(registerProvider: _registerProvider);
    _idCardReaderBloc = context.read<IdCardReaderBloc>();
    _registerBloc = RegisterBloc(
      firebaseRepository: locator<FirebaseRepository>(),
      firebaseStorageRepository: locator<FirebaseStorageRepository>(),
    );
    _getPatientBloc = GetPatientBloc();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) _idCardReaderBloc.add(IDCardConnectRequested());
    });
  }

  @override
  void dispose() {
    _stepProvider.dispose();
    _registerProvider.dispose();
    _registerBloc.close();
    _getPatientBloc.close();
    _idCardReaderBloc.add(IDCardResetRequested());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: registerV2Theme(Theme.of(context)),
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: _registerBloc),
          BlocProvider.value(value: _getPatientBloc),
          // ใช้โดย ProvinceDropdown ใน step การเดินทาง
          BlocProvider(create: (_) => ProvinceBloc()..add(ProvinceRequested())),
          // โหลดครั้งเดียวที่ระดับหน้า ไม่ต้องโหลดใหม่ทุกครั้งที่สลับ step
          BlocProvider(
            create: (_) => HospitalBloc()..add(LoadHospitalsEvent()),
          ),
          BlocProvider(create: (_) => ProjectBloc()..add(LoadProjectsEvent())),
        ],
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: _registerProvider),
            ChangeNotifierProvider.value(value: _stepProvider),
          ],
          child: MultiBlocListener(
            listeners: [
              BlocListener<RegisterBloc, RegisterState>(
                bloc: _registerBloc,
                listener: _onRegisterState,
              ),
              BlocListener<IdCardReaderBloc, IdCardReaderState>(
                listener: (context, state) async {
                  log('IdCardReaderBloc listener -> $state');
                  if (state is IDCardReaderReady) {
                    final payload = await IdCardRequestDialog.show(context);
                    if (payload != null) {
                      _registerProvider.setPatientInfoFromIDCard(payload);
                    }
                  }
                },
              ),
              BlocListener<GetPatientBloc, GetPatientState>(
                bloc: _getPatientBloc,
                listener: _onGetPatientState,
              ),
            ],
            child: const _RegisterV2View(),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ผลการตรวจสอบเลขบัตร
  // ---------------------------------------------------------------------------

  Future<void> _onGetPatientState(
    BuildContext context,
    GetPatientState state,
  ) async {
    switch (state) {
      case GetPatientInitial():
        break;
      case GetPatientLoading():
        _showLoading();
        _registerProvider.setPatientData(null);
        // ข้อมูลนัดหมาย/ผู้ติดตามถูกรีเซ็ต ต้องทำ step หลังจากนี้ใหม่
        _stepProvider.invalidateAfter(RegisterBookingStep.patient);
      case GetPatientSuccess():
        _hideLoading();
        await RegV2Dialogs.success(
          context,
          title: 'สามารถใช้บริการจองรถได้',
          message: _patientSuccessMessage(state),
        );
        _registerProvider.setPatientData(state.patientData);
      case GetPatientFailure():
        _hideLoading();
        if (state.message == MessageConstant.networkError) {
          ToastHelper.showError(
            context: context,
            title: 'เกิดข้อผิดพลาด',
            description: state.message,
          );
        } else {
          log('GetPatientFailure -> ${state.message}');
          await RegV2Dialogs.error(
            context,
            title: 'ไม่สามารถใช้บริการจองรถได้',
            message: state.message,
          );
        }
    }
  }

  /// ข้อความใน dialog หลังตรวจสอบสำเร็จ (เงื่อนไขเดิมของ [RegisterPage])
  String _patientSuccessMessage(GetPatientSuccess state) {
    final data = state.patientData;
    final projectName = data?.projectInfo?.name;
    final projectText = projectName != null
        ? 'โครงการ: $projectName'
        : 'ไม่มีข้อมูล';
    final remaining = data?.remainingRights?.remainingRights;
    if (remaining == null) return projectText;

    const projectOnlyCustomers = {
      'samed',
      'pattaya',
      'tessaban_angsila',
      'tessaban_saensuk',
      'kanchanaburi',
      'pathumthani',
      'tessaban_makhamkhu',
    };
    if (projectOnlyCustomers.contains(EnvHelper.customerCode)) {
      return projectText;
    }
    if (data?.projectInfo?.maxUsage != 0) {
      // กันไม่ให้แสดงค่าติดลบ (กรณี usedRights มากกว่า totalRights)
      final display = remaining < 0 ? 0 : remaining;
      return 'จำนวนสิทธิ์คงเหลือ: $display ครั้ง\n$projectText';
    }
    return projectText;
  }

  // ---------------------------------------------------------------------------
  // ผลการลงทะเบียน
  // ---------------------------------------------------------------------------

  Future<void> _onRegisterState(
    BuildContext context,
    RegisterState state,
  ) async {
    switch (state) {
      case RegisterInitial():
        break;
      case RegisterLoading():
        _showLoading();
        _registerProvider.setEnableTapGoogleMap(false);
      case RegisterSuccess():
        _hideLoading();
        log('RegisterSuccess: ${state.appointmentDates.length} dates');
        context.go(
          '/register-success',
          extra: {
            'patientIdCard': _registerProvider.requestData['patientIdCard'],
            'appointmentDate': _registerProvider.requestData['appointmentDate'],
            'appointmentDates': state.appointmentDates,
          },
        );
        _registerProvider.setEnableTapGoogleMap(true);
      case RegisterFailure():
        _hideLoading();
        log('RegisterFailure: ${state.message}');
        await _showRegisterFailure(context, state.message);
        await Future.delayed(const Duration(seconds: 1));
        _registerProvider.setEnableTapGoogleMap(true);
    }
  }

  Future<void> _showRegisterFailure(BuildContext context, String raw) async {
    if (raw.contains('มีการนัดหมายซ้ำในวันที่ ')) {
      final appointmentDate = DateTime.tryParse(
        raw.split('มีการนัดหมายซ้ำในวันที่ :').last.trim(),
      );
      final message =
          'ไม่สามารถลงทะเบียนได้\n'
          'เนื่องจากมีการนัดหมายซ้ำในวันที่ '
          '${DateHelper.dateThai(appointmentDate?.millisecondsSinceEpoch) ?? '-'} \n'
          'กรุณาตรวจสอบข้อมูลการนัดหมายของท่าน';
      await AlreadyRegisteredDialog.show(
        context,
        data: {
          'patientIdCard': _registerProvider.requestData['patientIdCard'],
          'appointmentDate': _registerProvider.requestData['appointmentDate'],
        },
        appointmentDate: message,
      );
      return;
    }

    if (raw.contains('จำนวนการจองเกิน 3 วันไม่สามารถสร้างนัดหมายใหม่ได้')) {
      await RegV2Dialogs.error(
        context,
        title: 'ไม่สามารถลงทะเบียนได้',
        message:
            'จำนวนการจองสูงสุดรอบละ 3 รายการ\nกรุณาตรวจสอบข้อมูลการนัดหมายของท่าน',
      );
      return;
    }

    // เกินเพดานจำนวนครั้งต่อวันของโครงการ (maxPerDay)
    // backend ส่งข้อความที่ระบุจำนวนมาแล้ว จึงแสดงต่อผู้ใช้ตรง ๆ
    if (raw.contains('จองได้ไม่เกิน')) {
      await RegV2Dialogs.error(
        context,
        title: 'ไม่สามารถลงทะเบียนได้',
        message: '$raw\nกรุณาตรวจสอบข้อมูลการนัดหมายของท่าน',
      );
      return;
    }

    await RegV2Dialogs.error(
      context,
      title: 'ไม่สามารถลงทะเบียนได้',
      message: 'เกิดข้อผิดพลาดบางอย่าง',
    );
  }
}

// -----------------------------------------------------------------------------
// โครงหน้า + เนื้อหาแต่ละ step
// -----------------------------------------------------------------------------

class _RegisterV2View extends StatelessWidget {
  const _RegisterV2View();

  @override
  Widget build(BuildContext context) {
    final steps = context.watch<RegisterStepProvider>();
    final current = steps.currentStep;

    return RegV2StepScaffold(
      appBarTitle: 'จองคิวใช้บริการ',
      sidebarTitle: 'จองคิวรถรับ–ส่งผู้ป่วย',
      stepTitles: [for (final s in steps.steps) s.title],
      currentIndex: steps.currentIndex,
      isStepCompleted: (i) => steps.isStepCompleted(steps.steps[i]),
      onStepTap: (i) => steps.goTo(steps.steps[i]),
      bottomBar: const _BottomActions(),
      child: Form(
        key: steps.formKeyOf(current),
        child: switch (current) {
          RegisterBookingStep.patient => const StepPatientView(),
          RegisterBookingStep.appointment => const StepAppointmentView(),
          RegisterBookingStep.contact => const StepContactView(),
        },
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// ปุ่มด้านล่าง
// -----------------------------------------------------------------------------

class _BottomActions extends StatelessWidget {
  const _BottomActions();

  Future<void> _onNext(BuildContext context) async {
    final steps = context.read<RegisterStepProvider>();
    final provider = context.read<RegisterProvider>();

    if (!steps.isLastStep) {
      if (!steps.next()) {
        ToastHelper.showValidationError(context: context);
        regV2ScrollToFirstError(steps.formKeyOf(steps.currentStep));
      }
      return;
    }

    // step สุดท้าย: validate ฟอร์ม step 3 → ถามยืนยัน → ตรวจเงื่อนไขสิทธิ์ก่อนส่ง
    // (ตรรกะเดิมของ RegisterPage)
    if (!steps.validateStep(steps.currentStep)) {
      ToastHelper.showValidationError(context: context);
      regV2ScrollToFirstError(steps.formKeyOf(steps.currentStep));
      return;
    }
    final appointmentsText = provider.appointmentsList
        .map((apt) {
          final date = apt['date'] as DateTime?;
          final time = apt['time'] as TimeOfDay?;
          if (date == null) return null;
          final dateText = DateHelper.dateTimeThaiDefault(
            date.millisecondsSinceEpoch,
          );
          final timeText = DateHelper.formatTime(time);
          return timeText == null ? '$dateText' : '$dateText $timeText น.';
        })
        .whereType<String>()
        .join('\n');
    final patient = provider.patientData?.patient;
    final isConfirm = await RegV2Dialogs.confirm(
      context,
      icon: Icons.event_available_rounded,
      title: 'ยืนยันการจองคิวรถ',
      message: 'กรุณาตรวจสอบข้อมูลก่อนยืนยัน',
      cancelText: 'ตรวจสอบอีกครั้ง',
      confirmText: 'ยืนยันจองคิว',
      details: [
        RegV2DialogDetail(
          'ผู้ป่วย',
          '${patient?.firstName ?? ''} ${patient?.lastName ?? ''}'.trim(),
        ),
        RegV2DialogDetail('วันนัดหมาย', appointmentsText),
        RegV2DialogDetail(
          'บริการ',
          provider.serviceTypeSelected?.displayName ?? '-',
        ),
        RegV2DialogDetail(
          'โรงพยาบาล',
          provider.selectedHospital?.displayName ?? '-',
        ),
      ],
    );
    if (isConfirm != true || !context.mounted) return;

    if (EnvHelper.customerCode != 'samed') {
      final remaining = provider.patientData?.remainingRights?.remainingRights;
      if (remaining == 1 &&
          provider.serviceTypeSelected == ServiceType.roundTrip) {
        await RegV2Dialogs.error(
          context,
          title: 'ไม่สามารถใช้บริการจองรถได้',
          message:
              'ไม่สามารถใช้สิทธิ์จองรถได้ เนื่องจากใช้สิทธิ์คงเหลือไม่พอ\n'
              'สามารถติดต่อเจ้าหน้าที่เพื่อสอบถามข้อมูลเพิ่มเติม',
        );
        return;
      }

      // เช็คจองแบบหลายวัน: ไป-กลับ = 2 สิทธิ์/วัน, เที่ยวเดียว = 1 สิทธิ์/วัน
      if (provider.appointmentsList.isNotEmpty) {
        final requiredRightsPerTrip =
            provider.serviceTypeSelected == ServiceType.roundTrip ? 2 : 1;
        final totalRequiredRights =
            requiredRightsPerTrip * provider.appointmentsList.length;
        final maxUsage = provider.patientData?.projectInfo?.maxUsage ?? 0;

        log(
          'จำนวนวันนัดหมาย: ${provider.appointmentsList.length}, '
          'สิทธิ์ต่อครั้ง: $requiredRightsPerTrip, '
          'สิทธิ์ที่ต้องใช้ทั้งหมด: $totalRequiredRights, '
          'สิทธิ์คงเหลือ: ${remaining ?? 0}',
        );

        if (maxUsage != 0 && totalRequiredRights > maxUsage) {
          await RegV2Dialogs.error(
            context,
            title: 'ไม่สามารถใช้บริการจองรถได้',
            message:
                'ไม่สามารถใช้สิทธิ์จองรถได้ เนื่องจากจำนวนสิทธิ์ที่ต้องใช้ '
                '($totalRequiredRights ครั้ง) เกินจำนวนสิทธิ์สูงสุดที่โครงการกำหนดไว้ '
                '($maxUsage ครั้ง)\nสามารถติดต่อเจ้าหน้าที่เพื่อสอบถามข้อมูลเพิ่มเติม',
          );
          return;
        }
      }
    }

    if (!context.mounted) return;
    context.read<RegisterBloc>().add(
      RegisterRequestEvent(
        data: provider.requestData,
        dataCaseCRM: provider.requestDataCaseCRM,
        documentAppointmentFile: provider.uploadedFile,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final steps = context.watch<RegisterStepProvider>();
    final isSubmitting = context.watch<RegisterBloc>().state is RegisterLoading;
    // step 1: ปุ่ม "เริ่มจองคิวรถ" กดได้หลังตรวจสอบเลขบัตรผ่านแล้ว
    final hasPatient = context.select<RegisterProvider, bool>(
      (p) => p.patientData != null,
    );
    final blocked = steps.isFirstStep && !hasPatient;

    return RegV2StepBottomBar(
      isSubmitting: isSubmitting,
      onBack: steps.isFirstStep ? null : steps.back,
      nextLabel: switch (steps.currentStep) {
        RegisterBookingStep.patient => 'เริ่มจองคิวรถ',
        RegisterBookingStep.appointment => 'ถัดไป',
        RegisterBookingStep.contact => 'จองคิวรถ',
      },
      onNext: blocked ? null : () => _onNext(context),
    );
  }
}
