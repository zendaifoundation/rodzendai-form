import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:rodzendai_form/core/constants/message_constant.dart';
import 'package:rodzendai_form/core/extensions/text_editing_controller_extension.dart';
import 'package:rodzendai_form/core/utils/mime_helper.dart';
import 'package:rodzendai_form/core/network/api_result.dart';
import 'package:rodzendai_form/core/services/auth_service.dart';
import 'package:rodzendai_form/core/services/liff_service.dart';
import 'package:rodzendai_form/core/services/population_policy_service.dart';
import 'package:rodzendai_form/core/services/service_locator.dart';
import 'package:rodzendai_form/core/utils/date_helper.dart';
import 'package:rodzendai_form/core/utils/env_helper.dart';
import 'package:rodzendai_form/presentation/blocs/district_bloc/district_bloc.dart';
import 'package:rodzendai_form/presentation/blocs/province_bloc/province_bloc.dart';
import 'package:rodzendai_form/presentation/blocs/sub_district_bloc/sub_district_bloc.dart';
import 'package:rodzendai_form/presentation/register/interfaces/contact_relatio_type.dart';
import 'package:rodzendai_form/presentation/register/interfaces/patient_type.dart';
import 'package:rodzendai_form/presentation/register/interfaces/transport_ability.dart';
import 'package:rodzendai_form/presentation/register/widgets/box_upload_file_widget.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/interfaces/register_v2_options.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/views/form_barthel_activity_adl.dart';
import 'package:rodzendai_form/models/id_card_ocr_result_model.dart';
import 'package:rodzendai_form/repositories/ocr_repository.dart';
import 'package:rodzendai_form/repositories/patient_repository.dart';

/// ขั้นตอนของฟอร์มลงทะเบียนรับสิทธิ์ v2 (8 step) ส่งคำขอผ่าน dialog ยืนยันท้าย step สุดท้าย
enum RegisterV2Step {
  identity('ยืนยันตัวตน'),
  category('ประเภทผู้ป่วย'),
  transport('การเดินทาง'),
  patientInfo('ผู้ป่วยและผู้ติดตาม'),
  address('ที่อยู่อาศัย'),
  pickupLocation('สถานที่รับผู้ป่วย'),
  documents('เอกสาร'),
  confirm('ยืนยันข้อมูล');

  const RegisterV2Step(this.title);
  final String title;
}

enum RegisterV2SubmitStatus { idle, submitting, success, failure }

/// สถานะการอ่านบัตรด้วย OCR ใน step ยืนยันตัวตน
enum OcrStatus { idle, loading, success, failure }

/// จัดการ state ของหน้า [RegisterToClaimYourRightsV2Page]
///
/// - การเดินหน้า/ย้อนกลับระหว่าง step และ validate ทีละ step
/// - ข้อมูลในฟอร์ม โดยข้อมูลที่ไม่อยู่ในสาขาที่เลือกจะไม่ถูกส่ง
/// - สร้าง payload ที่ยังเข้ากันได้กับ backend/admin เดิม และเพิ่ม field ใหม่ตามสเปก
class RegisterToClaimYourRightsV2Provider extends ChangeNotifier {
  RegisterToClaimYourRightsV2Provider() {
    for (final step in RegisterV2Step.values) {
      _formKeys[step] = GlobalKey<FormState>();
    }
    _patientIdCardController.addListener(() {
      // แก้เลขบัตรแล้วต้องตรวจสอบใหม่
      final idCard = _patientIdCardController.text.trim();
      if (_isIdCardChecked && idCard != _checkedIdCard) {
        _isIdCardChecked = false;
        _checkedIdCard = null;
        notifyListeners();
      }
    });
    _loadPopulationPolicy();
  }

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    for (final controller in [
      _healthDetailsController,
      _transportDetailsController,
      _monthlyIncomeController,
      _monthlyExpensesController,
      _specialOtherDetailsController,
      _patientIdCardController,
      _patientTitleController,
      _patientFirstNameController,
      _patientLastNameController,
      _patientPhoneController,
      _patientLineIdController,
      _patientHealthNoteController,
      _companionIdCardController,
      _companionFirstNameController,
      _companionLastNameController,
      _companionPhoneController,
      _referrerNameController,
      _registeredAddressController,
      _registeredPostalCodeController,
      _currentAddressController,
      _currentPostalCodeController,
      _pickupDescriptionController,
      _pickupLandmarkController,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Step navigation
  // ---------------------------------------------------------------------------

  final Map<RegisterV2Step, GlobalKey<FormState>> _formKeys = {};
  GlobalKey<FormState> formKeyOf(RegisterV2Step step) => _formKeys[step]!;

  List<RegisterV2Step> get steps => RegisterV2Step.values;

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;
  RegisterV2Step get currentStep => steps[_currentIndex];

  bool get isFirstStep => _currentIndex == 0;
  bool get isLastStep => _currentIndex == steps.length - 1;

  /// step ที่ผ่าน validate แล้ว ใช้แสดงเครื่องหมายใน step indicator
  final Set<RegisterV2Step> _completedSteps = {};
  bool isStepCompleted(RegisterV2Step step) => _completedSteps.contains(step);

  /// validate step ปัจจุบัน ถ้าผ่านให้ไป step ถัดไป คืนค่า false ถ้าไม่ผ่าน
  bool next() {
    if (!validateStep(currentStep)) return false;
    _completedSteps.add(currentStep);
    if (!isLastStep) {
      _currentIndex++;
      notifyListeners();
    }
    return true;
  }

  void back() {
    if (isFirstStep) return;
    _currentIndex--;
    notifyListeners();
  }

  /// กระโดดไป step ที่ต้องการ อนุญาตเฉพาะ step ก่อนหน้า หรือ step ที่ทุก step ก่อนหน้าผ่านแล้ว
  void goTo(RegisterV2Step step) {
    final index = steps.indexOf(step);
    if (index < 0 || index == _currentIndex) return;
    final canJump =
        index < _currentIndex ||
        steps.take(index).every(_completedSteps.contains);
    if (!canJump) return;
    _currentIndex = index;
    notifyListeners();
  }

  bool validateStep(RegisterV2Step step) {
    final formValid = _formKeys[step]?.currentState?.validate() ?? true;
    return switch (step) {
      // บังคับรูปบัตรเสมอ (OCR ล้มเหลวก็ไปต่อได้ ขอแค่มีรูป)
      RegisterV2Step.identity =>
        formValid && !isOcrLoading && isIdentityStepCompleted,
      RegisterV2Step.category => formValid && isCategoryCompleted,
      RegisterV2Step.patientInfo => formValid && _isIdCardChecked,
      RegisterV2Step.address => formValid && isAddressInServiceArea,
      RegisterV2Step.pickupLocation => formValid && hasPickupPin,
      RegisterV2Step.confirm =>
        formValid && isAdlCompleted && isConfirmationCompleted,
      _ => formValid,
    };
  }

  // ---------------------------------------------------------------------------
  // Step 1 — ยืนยันตัวตน (รูปบัตรประชาชน + OCR เติมข้อมูลให้)
  // ---------------------------------------------------------------------------

  /// วิธียืนยันตัวตนตอนสมัคร เก็บใน `identityVerification.method`
  /// `smartCard` สำรองไว้สำหรับ agent อ่านบัตรบนเครื่องเจ้าหน้าที่ (ยังไม่เปิดใช้)
  static const identityMethodOcr = 'ocr';
  static const identityMethodSmartCard = 'smart_card';
  static const identityMethodManual = 'manual';

  /// รูปบัตรบังคับใน step 1 เสมอ
  bool get isIdentityStepCompleted => _idCardFile != null;

  OcrStatus _ocrStatus = OcrStatus.idle;
  OcrStatus get ocrStatus => _ocrStatus;
  bool get isOcrLoading => _ocrStatus == OcrStatus.loading;

  IdCardOcrResultModel? _ocrResult;
  IdCardOcrResultModel? get ocrResult => _ocrResult;

  String? _ocrError;
  String? get ocrError => _ocrError;

  DateTime? _ocrReadAt;

  /// ค่าที่ OCR เติมลงช่องต่าง ๆ (key = ชื่อ field ใน payload) ใช้เทียบว่าผู้ใช้แก้ช่องไหนภายหลัง
  final Map<String, String> _ocrFilledValues = {};

  /// true เมื่อ OCR เพิ่งเติมเลขบัตรให้ และยังไม่ได้ยิง "ตรวจสอบข้อมูล"
  /// step ผู้ป่วยจะอ่านค่านี้แล้วตรวจสอบให้อัตโนมัติ
  bool _autoCheckIdCardPending = false;
  bool get shouldAutoCheckIdCard =>
      _autoCheckIdCardPending &&
      !_isIdCardChecked &&
      RegExp(r'^\d{13}$').hasMatch(_patientIdCardController.text.trim());

  void consumeAutoCheckIdCard() {
    _autoCheckIdCardPending = false;
  }

  /// ตั้งรูปบัตรจาก step 1 แล้วอ่าน OCR ทันที (null = ลบรูป ล้างผล OCR แต่คงค่าที่เติมไว้)
  Future<void> readIdCard(UploadedFile? file) async {
    _idCardFile = file;
    _ocrResult = null;
    _ocrError = null;
    if (file == null) {
      _ocrStatus = OcrStatus.idle;
      notifyListeners();
      return;
    }
    if (!EnvHelper.isOcrConfigured) {
      _ocrStatus = OcrStatus.failure;
      _ocrError =
          'ระบบอ่านบัตรยังไม่พร้อมใช้งาน กรอกข้อมูลในขั้นตอนถัดไปได้ตามปกติ';
      notifyListeners();
      return;
    }

    _ocrStatus = OcrStatus.loading;
    notifyListeners();

    final result = await locator<OcrRepository>().readThaiIdCard(
      file: file,
      provider: OcrProvider.google,
    );
    if (_disposed || _idCardFile != file) return; // ผู้ใช้เปลี่ยนรูประหว่างรอ

    switch (result) {
      case ApiSuccess(:final data):
        _ocrResult = data;
        _ocrReadAt = DateTime.now();
        _ocrStatus = OcrStatus.success;
        await _applyOcrResult(data);
      case ApiFailure(:final error):
        _ocrStatus = OcrStatus.failure;
        _ocrError = error.message;
    }
    if (!_disposed) notifyListeners();
  }

  /// เติมข้อมูลจากบัตรลงฟอร์ม ทับค่าเดิมเฉพาะเมื่อ OCR อ่านได้
  Future<void> _applyOcrResult(IdCardOcrResultModel data) async {
    _ocrFilledValues.clear();

    void fill(String key, TextEditingController controller, String? value) {
      final v = value?.trim();
      if (v == null || v.isEmpty) return;
      controller.text = v;
      _ocrFilledValues[key] = v;
    }

    final idNumber = data.idNumber?.replaceAll(RegExp(r'\D'), '');
    if (idNumber != null && idNumber.length == 13) {
      fill('idCardNumber', _patientIdCardController, idNumber);
      _autoCheckIdCardPending = true;
    }
    fill('title', _patientTitleController, data.titleTH);
    fill('firstName', _patientFirstNameController, data.firstNameTH);
    fill('lastName', _patientLastNameController, data.lastNameTH);

    // zendai-ocr ส่งวันเกิดเป็น ISO (ค.ศ.) แล้ว
    final dob = DateTime.tryParse(data.dateOfBirth ?? '');
    if (dob != null && !dob.isAfter(DateTime.now())) {
      _dateOfBirth = dob;
      _ocrFilledValues['dateOfBirth'] = DateHelper.formatDateThai(dob) ?? '';
    }

    await _applyOcrAddress(data.address);
  }

  /// แยกที่อยู่ตามทะเบียนบ้านจากบัตร: บ้านเลขที่/หมู่/ถนน → ช่องที่อยู่,
  /// ตำบล/อำเภอ/จังหวัด → จับคู่รหัสจากไฟล์พื้นที่ (จับคู่ไม่ได้ปล่อยให้เลือกเอง)
  Future<void> _applyOcrAddress(String? address) async {
    final text = address?.trim();
    if (text == null || text.isEmpty) return;

    String? capture(RegExp re) => re.firstMatch(text)?.group(1)?.trim();
    final subDistrictName = capture(
      RegExp(r'(?:^|\s)(?:ต\.|ตำบล|แขวง)\s*([ก-๙]+)'),
    );
    final districtName = capture(
      RegExp(r'(?:^|\s)(?:อ\.|อำเภอ|เขต)\s*([ก-๙]+)'),
    );
    final provinceName =
        capture(RegExp(r'(?:^|\s)(?:จ\.|จังหวัด)\s*([ก-๙]+)')) ??
        (text.contains('กรุงเทพ') ? 'กรุงเทพมหานคร' : null);

    // ส่วนหน้า (ก่อนถึง ต./แขวง) คือบ้านเลขที่ หมู่ ซอย ถนน
    final cut = RegExp(
      r'\s(?:ต\.|ตำบล|แขวง|อ\.|อำเภอ|เขต|จ\.|จังหวัด)',
    ).firstMatch(text);
    final houseText = (cut == null ? text : text.substring(0, cut.start))
        .trim();
    if (houseText.isNotEmpty) {
      _registeredAddressController.text = houseText;
      _ocrFilledValues['registeredAddress'] = houseText;
    }

    if (provinceName == null) return;
    final provinceCode = await ProvinceBloc.findProvinceCodeByName(
      provinceName,
    );
    if (_disposed || provinceCode == null) return;
    setRegisteredProvinceCode(provinceCode);
    _ocrFilledValues['registeredProvinceCode'] = '$provinceCode';

    if (districtName == null) return;
    final districtCode = await DistrictBloc.findDistrictCodeByName(
      districtName,
      provinceCode,
    );
    if (_disposed || districtCode == null) return;
    setRegisteredDistrictCode(districtCode);
    _ocrFilledValues['registeredDistrictCode'] = '$districtCode';

    if (subDistrictName == null) return;
    final subDistrictCode = await SubDistrictBloc.findSubDistrictCodeByName(
      subDistrictName,
      districtCode,
    );
    if (_disposed || subDistrictCode == null) return;
    await setRegisteredSubDistrictCode(subDistrictCode);
    _ocrFilledValues['registeredSubDistrictCode'] = '$subDistrictCode';
  }

  /// ช่องที่ผู้ใช้แก้หลังจาก OCR เติมให้ (ให้เจ้าหน้าที่รู้ว่าข้อมูลต่างจากบัตร)
  List<String> get _ocrEditedFields {
    if (_ocrFilledValues.isEmpty) return const [];
    final current = <String, String?>{
      'idCardNumber': _patientIdCardController.textOrNull,
      'title': _patientTitleController.textOrNull,
      'firstName': _patientFirstNameController.textOrNull,
      'lastName': _patientLastNameController.textOrNull,
      'dateOfBirth': DateHelper.formatDateThai(_dateOfBirth),
      'registeredAddress': _registeredAddressController.textOrNull,
      'registeredProvinceCode': _registeredProvinceCode?.toString(),
      'registeredDistrictCode': _registeredDistrictCode?.toString(),
      'registeredSubDistrictCode': _registeredSubDistrictCode?.toString(),
    };
    return [
      for (final entry in _ocrFilledValues.entries)
        if ((current[entry.key] ?? '') != entry.value) entry.key,
    ];
  }

  /// เลขบัตรที่อ่านจากบัตรตรงกับเลขที่จะส่ง (null = OCR อ่านเลขไม่ได้)
  bool? get _ocrIdNumberMatched {
    final read = _ocrResult?.idNumber?.replaceAll(RegExp(r'\D'), '');
    if (read == null || read.length != 13) return null;
    return read == _patientIdCardController.text.trim();
  }

  String get identityMethod => _ocrStatus == OcrStatus.success
      ? identityMethodOcr
      : identityMethodManual;

  /// `identityVerification` ใน payload — ให้ admin เห็นว่าตอนสมัครยืนยันตัวตนด้วยวิธีใด
  Map<String, dynamic> get _identityVerificationData {
    final ocr = _ocrResult;
    final matched = _ocrIdNumberMatched;
    return {
      'method': identityMethod,
      // ยืนยันแล้ว = อ่านบัตรสำเร็จและเลขบัตรตรงกับที่ส่ง
      'verified': identityMethod != identityMethodManual && matched == true,
      'idNumberMatched': matched,
      'hasIdCardImage': _idCardFile != null,
      'provider': ocr?.provider,
      'confidence': ocr?.confidence,
      'readAt': _ocrReadAt?.toUtc().toIso8601String(),
      'warnings': ocr?.warnings,
      'ocrFields': ocr == null
          ? null
          : {
              'idNumber': ocr.idNumber,
              'titleTH': ocr.titleTH,
              'firstNameTH': ocr.firstNameTH,
              'lastNameTH': ocr.lastNameTH,
              'firstNameEN': ocr.firstNameEN,
              'lastNameEN': ocr.lastNameEN,
              'dateOfBirth': ocr.dateOfBirth,
              'address': ocr.address,
              'issueDate': ocr.issueDate,
              'expiryDate': ocr.expiryDate,
            },
      'editedFields': _ocrEditedFields,
    };
  }

  // ---------------------------------------------------------------------------
  // Step 2 — ประเภทผู้ป่วย
  // ---------------------------------------------------------------------------

  PatientType? _patientType;
  PatientType? get patientType => _patientType;

  DisabilityType? _disabilityType;
  DisabilityType? get disabilityType => _disabilityType;

  ElderlyCondition? _elderlyCondition;
  ElderlyCondition? get elderlyCondition => _elderlyCondition;

  DifficultyReason? _difficultyReason;
  DifficultyReason? get difficultyReason => _difficultyReason;

  SpecialSubtype? _specialSubtype;
  SpecialSubtype? get specialSubtype => _specialSubtype;

  final _healthDetailsController = TextEditingController();
  TextEditingController get healthDetailsController => _healthDetailsController;

  final _transportDetailsController = TextEditingController();
  TextEditingController get transportDetailsController =>
      _transportDetailsController;

  final _monthlyIncomeController = TextEditingController();
  TextEditingController get monthlyIncomeController => _monthlyIncomeController;

  final _monthlyExpensesController = TextEditingController();
  TextEditingController get monthlyExpensesController =>
      _monthlyExpensesController;

  final _specialOtherDetailsController = TextEditingController();
  TextEditingController get specialOtherDetailsController =>
      _specialOtherDetailsController;

  List<UploadedFile> _housePhotos = [];
  List<UploadedFile> get housePhotos => _housePhotos;

  // การเปลี่ยนกลุ่ม/สาเหตุไม่ล้างค่าร่าง เพื่อให้ย้อนกลับมาได้โดยไม่เสียข้อมูล
  // แต่ requestData จะส่งเฉพาะข้อมูลของสาขาที่เลือกอยู่

  void setPatientType(PatientType? value) {
    if (_patientType == value) return;
    _patientType = value;
    notifyListeners();
  }

  void setDisabilityType(DisabilityType? value) {
    _disabilityType = value;
    notifyListeners();
  }

  void setElderlyCondition(ElderlyCondition? value) {
    _elderlyCondition = value;
    notifyListeners();
  }

  void setDifficultyReason(DifficultyReason? value) {
    _difficultyReason = value;
    notifyListeners();
  }

  void setSpecialSubtype(SpecialSubtype? value) {
    _specialSubtype = value;
    notifyListeners();
  }

  void setHousePhotos(List<UploadedFile> files) {
    _housePhotos = files;
    notifyListeners();
  }

  /// แปลงตัวเลขเงิน รองรับทศนิยมและเครื่องหมายจุลภาค คืน null ถ้าไม่ใช่ตัวเลข finite ที่ไม่ติดลบ
  static double? parseAmount(String? text) {
    final value = double.tryParse((text ?? '').replaceAll(',', '').trim());
    if (value == null || !value.isFinite || value < 0) return null;
    return value;
  }

  /// ตรวจเฉพาะข้อมูลที่ไม่ใช่ TextFormField (ช่องข้อความตรวจผ่าน validator ของฟอร์ม)
  bool get isCategoryCompleted => switch (_patientType) {
    null => false,
    PatientType.disabled => _disabilityType != null,
    PatientType.elderly => _elderlyCondition != null,
    PatientType.hardship => switch (_difficultyReason) {
      null => false,
      DifficultyReason.resources => _housePhotos.isNotEmpty,
      DifficultyReason.special => _specialSubtype != null,
      _ => true,
    },
  };

  Map<String, dynamic>? get _eligibilityData => switch (_patientType) {
    null => null,
    PatientType.disabled => {'d_type': _disabilityType?.value},
    PatientType.elderly => {'e_condition': _elderlyCondition?.value},
    PatientType.hardship => {
      'r_reason': _difficultyReason?.value,
      if (_difficultyReason == DifficultyReason.special)
        'special_subtype': _specialSubtype?.value,
    },
  };

  Map<String, dynamic>? get _difficultyAssessmentData {
    if (_patientType != PatientType.hardship || _difficultyReason == null) {
      return null;
    }
    final reason = _difficultyReason!;
    return {
      'reason': reason.value,
      ...switch (reason) {
        DifficultyReason.health => {
          'health_details': _healthDetailsController.textOrNull,
        },
        DifficultyReason.transport => {
          'transport_details': _transportDetailsController.textOrNull,
        },
        DifficultyReason.resources => {
          'monthly_income': parseAmount(_monthlyIncomeController.text),
          'monthly_expenses': parseAmount(_monthlyExpensesController.text),
          // ไฟล์จริงส่งแยกใน FormData ชื่อฟิลด์ `housePhotos`
          'house_photos_count': _housePhotos.length,
        },
        DifficultyReason.special => {
          'special_subtype': _specialSubtype?.value,
          if (_specialSubtype == SpecialSubtype.other)
            'special_other_details': _specialOtherDetailsController.textOrNull,
        },
      },
    };
  }

  /// ภาพบ้านส่งเฉพาะสาเหตุเศรษฐานะ
  List<UploadedFile> get housePhotosToSubmit =>
      _patientType == PatientType.hardship &&
          _difficultyReason == DifficultyReason.resources
      ? _housePhotos
      : const [];

  // ---------------------------------------------------------------------------
  // Step 3 — ความสามารถในการเดินทาง
  // ---------------------------------------------------------------------------

  TransportAbility? _transportAbility;
  TransportAbility? get transportAbility => _transportAbility;

  void setTransportAbility(TransportAbility? value) {
    _transportAbility = value;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Step 4 — ผู้ป่วยและผู้ติดตาม
  // ---------------------------------------------------------------------------

  final _patientIdCardController = TextEditingController();
  TextEditingController get patientIdCardController => _patientIdCardController;

  /// ผ่านการตรวจสอบสิทธิ์/ลงทะเบียนซ้ำจาก server แล้ว (ผูกกับเลขบัตรที่ตรวจ)
  bool _isIdCardChecked = false;
  bool get isIdCardChecked => _isIdCardChecked;
  String? _checkedIdCard;

  void markIdCardChecked() {
    _isIdCardChecked = true;
    _checkedIdCard = _patientIdCardController.text.trim();
    notifyListeners();
  }

  /// คำนำหน้า (ไม่บังคับ) ส่วนใหญ่ได้จาก OCR
  final _patientTitleController = TextEditingController();
  TextEditingController get patientTitleController => _patientTitleController;

  final _patientFirstNameController = TextEditingController();
  TextEditingController get patientFirstNameController =>
      _patientFirstNameController;

  final _patientLastNameController = TextEditingController();
  TextEditingController get patientLastNameController =>
      _patientLastNameController;

  final _patientPhoneController = TextEditingController();
  TextEditingController get patientPhoneController => _patientPhoneController;

  final _patientLineIdController = TextEditingController();
  TextEditingController get patientLineIdController => _patientLineIdController;

  final _patientHealthNoteController = TextEditingController();
  TextEditingController get patientHealthNoteController =>
      _patientHealthNoteController;

  DateTime? _dateOfBirth;
  DateTime? get dateOfBirth => _dateOfBirth;

  void setDateOfBirth(DateTime? value) {
    _dateOfBirth = value;
    notifyListeners();
  }

  bool? _hasCompanion;
  bool? get hasCompanion => _hasCompanion;

  void setHasCompanion(bool? value) {
    _hasCompanion = value;
    notifyListeners();
  }

  final _companionIdCardController = TextEditingController();
  TextEditingController get companionIdCardController =>
      _companionIdCardController;

  final _companionFirstNameController = TextEditingController();
  TextEditingController get companionFirstNameController =>
      _companionFirstNameController;

  final _companionLastNameController = TextEditingController();
  TextEditingController get companionLastNameController =>
      _companionLastNameController;

  final _companionPhoneController = TextEditingController();
  TextEditingController get companionPhoneController =>
      _companionPhoneController;

  ContactRelationType? _companionRelation;
  ContactRelationType? get companionRelation => _companionRelation;

  void setCompanionRelation(ContactRelationType? value) {
    _companionRelation = value;
    notifyListeners();
  }

  final _referrerNameController = TextEditingController();
  TextEditingController get referrerNameController => _referrerNameController;

  // ---------------------------------------------------------------------------
  // Step 5 — ที่อยู่อาศัย
  // ---------------------------------------------------------------------------

  final _registeredAddressController = TextEditingController();
  TextEditingController get registeredAddressController =>
      _registeredAddressController;

  final _registeredPostalCodeController = TextEditingController();
  TextEditingController get registeredPostalCodeController =>
      _registeredPostalCodeController;

  int? _registeredProvinceCode;
  int? get registeredProvinceCode => _registeredProvinceCode;
  int? _registeredDistrictCode;
  int? get registeredDistrictCode => _registeredDistrictCode;
  int? _registeredSubDistrictCode;
  int? get registeredSubDistrictCode => _registeredSubDistrictCode;

  /// `address_same`: true = same, false = different, null = ยังไม่ตอบ
  bool? _addressSame;
  bool? get addressSame => _addressSame;
  bool get _isAddressSame => _addressSame == true;

  final _currentAddressController = TextEditingController();
  TextEditingController get currentAddressController =>
      _currentAddressController;

  final _currentPostalCodeController = TextEditingController();
  TextEditingController get currentPostalCodeController =>
      _currentPostalCodeController;

  int? _currentProvinceCode;
  int? get currentProvinceCode => _currentProvinceCode;
  int? _currentDistrictCode;
  int? get currentDistrictCode => _currentDistrictCode;
  int? _currentSubDistrictCode;
  int? get currentSubDistrictCode => _currentSubDistrictCode;

  void setRegisteredProvinceCode(int? value) {
    if (_registeredProvinceCode == value) return;
    _registeredProvinceCode = value;
    _registeredDistrictCode = null;
    _registeredSubDistrictCode = null;
    _registeredPostalCodeController.clear();
    notifyListeners();
  }

  void setRegisteredDistrictCode(int? value) {
    if (_registeredDistrictCode == value) return;
    _registeredDistrictCode = value;
    _registeredSubDistrictCode = null;
    _registeredPostalCodeController.clear();
    notifyListeners();
  }

  Future<void> setRegisteredSubDistrictCode(int? value) async {
    _registeredSubDistrictCode = value;
    notifyListeners();
    final postalCode = await _lookupPostalCode(value);
    // ไม่เขียนทับถ้าผู้ใช้เปลี่ยนตำบลไปแล้วระหว่างรอ
    if (_registeredSubDistrictCode == value) {
      _registeredPostalCodeController.text = postalCode;
    }
  }

  void setCurrentProvinceCode(int? value) {
    if (_currentProvinceCode == value) return;
    _currentProvinceCode = value;
    _currentDistrictCode = null;
    _currentSubDistrictCode = null;
    _currentPostalCodeController.clear();
    notifyListeners();
  }

  void setCurrentDistrictCode(int? value) {
    if (_currentDistrictCode == value) return;
    _currentDistrictCode = value;
    _currentSubDistrictCode = null;
    _currentPostalCodeController.clear();
    notifyListeners();
  }

  Future<void> setCurrentSubDistrictCode(int? value) async {
    _currentSubDistrictCode = value;
    notifyListeners();
    final postalCode = await _lookupPostalCode(value);
    if (_currentSubDistrictCode == value) {
      _currentPostalCodeController.text = postalCode;
    }
  }

  /// รหัสไปรษณีย์ของตำบลที่เลือก ใช้เติมให้อัตโนมัติ (ผู้ใช้แก้เองได้)
  Future<String> _lookupPostalCode(int? subDistrictCode) async {
    final postalCode = await SubDistrictBloc.findPostalCodeBySubDistrictCode(
      subDistrictCode,
    );
    return postalCode?.toString() ?? '';
  }

  void setAddressSame(bool? value) {
    _addressSame = value;
    notifyListeners();
  }

  /// โครงการของฟอร์มนี้รับประชากรแฝงหรือไม่ (ตั้งที่ admin ดู [PopulationPolicyService])
  /// false = รับเฉพาะคนในทะเบียนบ้าน → ทะเบียนบ้านต้องอยู่ในพื้นที่ให้บริการด้วย
  bool _allowsLatentPopulation = false;
  bool get allowsLatentPopulation => _allowsLatentPopulation;

  Future<void> _loadPopulationPolicy() async {
    final allows = await PopulationPolicyService.allowsLatentPopulation();
    if (_disposed || allows == _allowsLatentPopulation) return;
    _allowsLatentPopulation = allows;
    notifyListeners();
  }

  /// ที่อยู่ผ่านเงื่อนไขพื้นที่ให้บริการตามตัวเลือกประชากรของโครงการ
  /// - รับประชากรแฝง: ดูเฉพาะที่อยู่ปัจจุบัน
  /// - รับเฉพาะคนในทะเบียนบ้าน: ทะเบียนบ้านและที่อยู่ปัจจุบันต้องอยู่ในพื้นที่
  bool get isAddressInServiceArea =>
      isCurrentAddressInServiceArea &&
      (_allowsLatentPopulation || isRegisteredAddressInServiceArea);

  /// ที่อยู่ปัจจุบันที่ใช้จริง (ทะเบียนบ้านถ้า "ตรงกัน") อยู่ในพื้นที่ให้บริการ
  /// ของ customer นี้หรือไม่ (ALLOWED_PROVINCE_CODE / DISTRICT / SUB_DISTRICT)
  ///
  /// ยังเลือกไม่ครบ หรือ env ไม่ได้กำหนดพื้นที่ → ถือว่าผ่าน (ให้ validator ช่องจัดการ)
  bool get isCurrentAddressInServiceArea {
    if (_addressSame == null) return true;
    return _isAreaInServiceArea(_currentAddressArea);
  }

  /// ทะเบียนบ้านอยู่ในพื้นที่ให้บริการหรือไม่ — ใช้ตัดสินตอนผู้ใช้กด "ตรงกับทะเบียนบ้าน"
  bool get isRegisteredAddressInServiceArea => _isAreaInServiceArea({
    'provinceCode': _registeredProvinceCode,
    'districtCode': _registeredDistrictCode,
    'subDistrictCode': _registeredSubDistrictCode,
  });

  bool _isAreaInServiceArea(Map<String, dynamic> area) {
    final province = area['provinceCode'] as int?;
    final district = area['districtCode'] as int?;
    final subDistrict = area['subDistrictCode'] as int?;

    final allowedProvince = EnvHelper.allowedProvinceCode;
    if (allowedProvince != null &&
        province != null &&
        province.toString() != allowedProvince) {
      return false;
    }
    final allowedDistrict = EnvHelper.allowedDistrictCode;
    if (allowedDistrict != null &&
        district != null &&
        district.toString() != allowedDistrict) {
      return false;
    }
    final allowedSubDistricts = EnvHelper.allowedSubDistrictCodes;
    if (allowedSubDistricts.isNotEmpty &&
        subDistrict != null &&
        !allowedSubDistricts.contains(subDistrict.toString())) {
      return false;
    }
    return true;
  }

  // ถ้าที่อยู่ตรงกัน ส่งค่าจากทะเบียนบ้านเสมอ ไม่ใช้สำเนาเก่า
  Map<String, dynamic> get _currentAddressArea => _isAddressSame
      ? {
          'address': _registeredAddressController.textOrNull,
          'provinceCode': _registeredProvinceCode,
          'districtCode': _registeredDistrictCode,
          'subDistrictCode': _registeredSubDistrictCode,
          'postalCode': _registeredPostalCodeController.textOrNull,
        }
      : {
          'address': _currentAddressController.textOrNull,
          'provinceCode': _currentProvinceCode,
          'districtCode': _currentDistrictCode,
          'subDistrictCode': _currentSubDistrictCode,
          'postalCode': _currentPostalCodeController.textOrNull,
        };

  // ---------------------------------------------------------------------------
  // Step 6 — สถานที่รับผู้ป่วย
  // ---------------------------------------------------------------------------

  final _pickupDescriptionController = TextEditingController();
  TextEditingController get pickupDescriptionController =>
      _pickupDescriptionController;

  final _pickupLandmarkController = TextEditingController();
  TextEditingController get pickupLandmarkController =>
      _pickupLandmarkController;

  double? _pickupLatitude;
  double? get pickupLatitude => _pickupLatitude;
  double? _pickupLongitude;
  double? get pickupLongitude => _pickupLongitude;

  String? _pickupFormattedAddress;
  String? get pickupFormattedAddress => _pickupFormattedAddress;
  String? _pickupPlusCode;
  String? get pickupPlusCode => _pickupPlusCode;

  bool get hasPickupPin => _pickupLatitude != null && _pickupLongitude != null;

  /// ข้อความที่ระบบเติมให้จากหมุดล่าสุด ใช้แยกว่าผู้ใช้แก้ชื่อจุดรับเองหรือยัง
  String? _autoPickupDescription;

  void setPickupLocation({
    required double latitude,
    required double longitude,
    String? formattedAddress,
    String? plusCode,
  }) {
    _pickupLatitude = latitude;
    _pickupLongitude = longitude;
    _pickupFormattedAddress = formattedAddress;
    _pickupPlusCode = plusCode;
    // ย้ายหมุดแล้วเปลี่ยนชื่อจุดรับตามที่อยู่ใหม่ ถ้าช่องยังว่าง
    // หรือยังเป็นข้อความที่ระบบเติมให้ (ไม่ทับข้อความที่ผู้ใช้พิมพ์เอง)
    final current = _pickupDescriptionController.text.trim();
    final isUntouched =
        current.isEmpty || current == _autoPickupDescription?.trim();
    if (isUntouched && (formattedAddress?.isNotEmpty ?? false)) {
      _pickupDescriptionController.text = formattedAddress!;
      _autoPickupDescription = formattedAddress;
    }
    notifyListeners();
  }

  /// ที่อยู่ปัจจุบันแบบเต็ม (ใช้จัดกึ่งกลางแผนที่ตอนปักหมุด)
  Future<String> currentAddressFullText() => _areaFullText(_currentAddressArea);

  Future<String> registeredAddressFullText() => _areaFullText({
    'address': _registeredAddressController.textOrNull,
    'provinceCode': _registeredProvinceCode,
    'districtCode': _registeredDistrictCode,
    'subDistrictCode': _registeredSubDistrictCode,
    'postalCode': _registeredPostalCodeController.textOrNull,
  });

  Future<String> _areaFullText(Map<String, dynamic> area) async {
    final subDistrict = await SubDistrictBloc.findSubDistrictNameByCode(
      area['subDistrictCode'] as int?,
    );
    final district = await DistrictBloc.findDistrictNameByCode(
      area['districtCode'] as int?,
    );
    final province = await ProvinceBloc.findProvinceNameByCode(
      area['provinceCode'] as int?,
    );
    return [
      area['address'] as String?,
      if (subDistrict != null) 'ตำบล$subDistrict',
      if (district != null) 'อำเภอ$district',
      if (province != null) 'จังหวัด$province',
      area['postalCode'] as String?,
    ].whereType<String>().join(' ');
  }

  // ---------------------------------------------------------------------------
  // Step 7 — เอกสาร
  // ---------------------------------------------------------------------------

  UploadedFile? _idCardFile;
  UploadedFile? get idCardFile => _idCardFile;

  UploadedFile? _disabilityCardFile;
  UploadedFile? get disabilityCardFile => _disabilityCardFile;

  UploadedFile? _thaiStateWelfareCardFile;
  UploadedFile? get thaiStateWelfareCardFile => _thaiStateWelfareCardFile;

  List<UploadedFile> _houseRegistrationFiles = [];
  List<UploadedFile> get houseRegistrationFiles => _houseRegistrationFiles;

  UploadedFile? _addressConfirmationFile;
  UploadedFile? get addressConfirmationFile => _addressConfirmationFile;

  List<UploadedFile> _otherFiles = [];
  List<UploadedFile> get otherFiles => _otherFiles;

  /// checkbox "อัปโหลดเอกสารภายหลัง" — true = `document_status: later`
  bool _uploadDocumentLater = false;
  bool get uploadDocumentLater => _uploadDocumentLater;

  void setIdCardFile(UploadedFile? file) {
    _idCardFile = file;
    notifyListeners();
  }

  void setDisabilityCardFile(UploadedFile? file) {
    _disabilityCardFile = file;
    notifyListeners();
  }

  void setThaiStateWelfareCardFile(UploadedFile? file) {
    _thaiStateWelfareCardFile = file;
    notifyListeners();
  }

  void setHouseRegistrationFiles(List<UploadedFile> files) {
    _houseRegistrationFiles = files;
    notifyListeners();
  }

  void setAddressConfirmationFile(UploadedFile? file) {
    _addressConfirmationFile = file;
    notifyListeners();
  }

  void setOtherFiles(List<UploadedFile> files) {
    _otherFiles = files;
    notifyListeners();
  }

  void setUploadDocumentLater(bool value) {
    _uploadDocumentLater = value;
    notifyListeners();
  }

  // เงื่อนไขเอกสารคงตามหน้าเดิม (แยกตามประเภทผู้ป่วยและ customer)
  static const _houseRegistrationCustomers = {
    'tessaban_saensuk',
    'pattaya',
    'tessaban_angsila',
  };

  /// ติ๊ก "อัปโหลดเอกสารภายหลัง" แล้วไม่บังคับแนบ
  bool get _documentsRequired => !_uploadDocumentLater;

  bool get showDisabilityCard => _patientType != PatientType.hardship;
  bool get disabilityCardRequired =>
      _documentsRequired && _patientType == PatientType.disabled;

  bool get idCardRequired => _documentsRequired;

  bool get showThaiStateWelfareCard => _patientType == PatientType.hardship;

  bool get showHouseRegistration =>
      _houseRegistrationCustomers.contains(EnvHelper.customerCode);
  bool get houseRegistrationRequired =>
      _documentsRequired && EnvHelper.customerCode != 'pattaya';

  bool get showAddressConfirmation =>
      EnvHelper.customerCode == 'tessaban_angsila';

  /// รายการเอกสารที่ "ต้องมี" ตามประเภทผู้ป่วยและ customer (ไม่สนว่าติ๊กส่งภายหลังหรือไม่)
  /// key ตรงกับชื่อฟิลด์ใน [filesToSubmit]
  List<String> get requiredDocumentKeys => [
    'idCard',
    if (showDisabilityCard && _patientType == PatientType.disabled)
      'disabilityCard',
    if (showHouseRegistration && EnvHelper.customerCode != 'pattaya')
      'houseRegistrations',
  ];

  /// เอกสารบังคับที่ยังไม่แนบ
  List<String> get missingDocumentKeys {
    final provided = filesToSubmit.keys.toSet();
    return requiredDocumentKeys.where((k) => !provided.contains(k)).toList();
  }

  /// `documentChecklist` ใน payload — สรุปว่าขาดเอกสารอะไรตามประเภทผู้ป่วย
  Map<String, dynamic> get _documentChecklistData {
    final provided = filesToSubmit.keys.toList();
    final required = requiredDocumentKeys;
    return {
      'status': _uploadDocumentLater ? 'later' : 'ready',
      'required': required,
      'provided': provided,
      'missing': missingDocumentKeys,
      'optionalProvided': provided.where((k) => !required.contains(k)).toList(),
    };
  }

  /// ไฟล์ที่จะส่งจริง แยกตามชื่อฟิลด์ของ FormData (ไม่ส่งไฟล์ของหัวข้อที่ซ่อนอยู่)
  Map<String, List<UploadedFile>> get filesToSubmit => {
    'idCard': [?_idCardFile],
    if (showDisabilityCard) 'disabilityCard': [?_disabilityCardFile],
    if (showThaiStateWelfareCard)
      'thaiStateWelfareCard': [?_thaiStateWelfareCardFile],
    if (showHouseRegistration) 'houseRegistrations': _houseRegistrationFiles,
    if (showAddressConfirmation)
      'addressConfirmation': [?_addressConfirmationFile],
    'otherDocuments': _otherFiles,
    'housePhotos': housePhotosToSubmit,
  }..removeWhere((_, files) => files.isEmpty);

  // ---------------------------------------------------------------------------
  // Step 8 — ADL (เฉพาะผู้สูงอายุ) และยืนยันข้อมูล
  // ---------------------------------------------------------------------------

  bool get requiresAdl => _patientType?.requiresAdl ?? false;

  /// key = id ของ [barthelQuestions] (1–10)
  final Map<int, int> _adlScores = {};
  Map<int, int> get adlScores => Map.unmodifiable(_adlScores);

  int? adlScoreOf(int questionId) => _adlScores[questionId];

  void setAdlScore(int questionId, int score) {
    _adlScores[questionId] = score;
    notifyListeners();
  }

  void resetAdlScores() {
    _adlScores.clear();
    notifyListeners();
  }

  bool get isAdlCompleted =>
      !requiresAdl ||
      barthelQuestions.every((q) => _adlScores.containsKey(q.id));

  int? get adlTotal => requiresAdl && isAdlCompleted
      ? _adlScores.values.fold<int>(0, (sum, score) => sum + score)
      : null;

  // การยืนยัน 2 ข้อ (checkbox) ต้องติ๊กครบจึงไปต่อได้
  bool _privacyAck = false;
  bool get privacyAck => _privacyAck;

  bool _truthAck = false;
  bool get truthAck => _truthAck;

  void setPrivacyAck(bool value) {
    _privacyAck = value;
    notifyListeners();
  }

  void setTruthAck(bool value) {
    _truthAck = value;
    notifyListeners();
  }

  bool get isConfirmationCompleted => _privacyAck && _truthAck;

  /// payload ADL แบบเดิม (`barthelAdl`) ให้ admin ใช้ต่อได้
  /// คะแนนเป็นข้อมูลให้เจ้าหน้าที่สอบทาน ไม่ใช้ตัดสิทธิ์ใน client
  Map<String, dynamic> get _legacyBarthelData {
    if (!requiresAdl) {
      return {'details': [], 'totalScore': null, 'isEligible': null};
    }
    final details = [
      for (final entry in _adlScores.entries)
        {
          'questionId': entry.key,
          'questionTitle': barthelQuestions
              .firstWhereOrNull((q) => q.id == entry.key)
              ?.title,
          'score': entry.value,
          'answer': barthelQuestions
              .firstWhereOrNull((q) => q.id == entry.key)
              ?.options
              .firstWhereOrNull((o) => o.score == entry.value)
              ?.label,
        },
    ];
    final total = adlTotal;
    return {
      'details': details,
      'totalScore': total,
      // คงไว้ให้ admin ดูอย่างเดียว
      'isEligible': total == null ? null : total <= 11,
    };
  }

  static const _adlKeys = {
    1: 'feeding',
    2: 'grooming',
    3: 'transfer',
    4: 'toilet',
    5: 'mobility',
    6: 'dressing',
    7: 'stairs',
    8: 'bathing',
    9: 'bowels',
    10: 'bladder',
  };

  Map<String, dynamic> get _adlData => requiresAdl
      ? {
          'required': true,
          'answers': {
            for (final entry in _adlScores.entries)
              _adlKeys[entry.key]!: '${entry.value}',
          },
          'total': adlTotal,
          'status': 'pending_verification',
        }
      : {
          'required': false,
          'answers': null,
          'total': null,
          'status': 'not_required',
        };

  // ---------------------------------------------------------------------------
  // Submit
  // ---------------------------------------------------------------------------

  RegisterV2SubmitStatus _submitStatus = RegisterV2SubmitStatus.idle;
  RegisterV2SubmitStatus get submitStatus => _submitStatus;
  bool get isSubmitting => _submitStatus == RegisterV2SubmitStatus.submitting;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Map<String, dynamic> get requestData {
    final hasCompanion = _hasCompanion == true;
    return {
      // ---- โครงสร้างเดิม (backend/admin ใช้อยู่) ----
      'patient': {
        'idCardNumber': _patientIdCardController.textOrNull,
        'title': _patientTitleController.textOrNull,
        'firstName': _patientFirstNameController.textOrNull,
        'lastName': _patientLastNameController.textOrNull,
        'phone': _patientPhoneController.textOrNull,
        'dateOfBirth': DateHelper.formatDateThai(_dateOfBirth),
        'lineId': _patientLineIdController.textOrNull,
        'type': _patientType?.valueToStore,
        'healthNote': _patientHealthNoteController.textOrNull,
      },
      'companion': {
        'hasCompanion': _hasCompanion,
        'idCardNumber': hasCompanion
            ? _companionIdCardController.textOrNull
            : null,
        'firstName': hasCompanion
            ? _companionFirstNameController.textOrNull
            : null,
        'lastName': hasCompanion
            ? _companionLastNameController.textOrNull
            : null,
        'phone': hasCompanion ? _companionPhoneController.textOrNull : null,
        'relation': hasCompanion ? _companionRelation?.value : null,
      },
      'addresses': {
        'registered': {
          'address': _registeredAddressController.textOrNull,
          'provinceCode': _registeredProvinceCode,
          'districtCode': _registeredDistrictCode,
          'subDistrictCode': _registeredSubDistrictCode,
          'postalCode': _registeredPostalCodeController.textOrNull,
          'pickupAddress': null,
          'pickupLatitude': null,
          'pickupLongitude': null,
          'currentLocation': null,
          'pickupPlusCode': _pickupPlusCode,
        },
        'current': {
          'addressSame': switch (_addressSame) {
            null => null,
            true => 'same',
            false => 'different',
          },
          ..._currentAddressArea,
          'pickupAddress': _pickupDescriptionController.textOrNull,
          'pickupLatitude': _pickupLatitude?.toString(),
          'pickupLongitude': _pickupLongitude?.toString(),
          'pickupLandmark': _pickupLandmarkController.textOrNull,
          'currentLocation': _pickupFormattedAddress,
          'pickupPlusCode': _pickupPlusCode,
        },
      },
      'barthelAdl': _legacyBarthelData,
      'referrer': {'name': _referrerNameController.textOrNull},
      'transportation': {
        'ability': _transportAbility?.valueToStore,
        'vehicleRequest': _transportAbility?.vehicleRequestValue,
      },
      'documents': null,
      'documentStatus': _uploadDocumentLater ? 'later' : 'ready',
      '_pdpaAccepted': isConfirmationCompleted,

      // ---- field ใหม่ตามสเปก v4 ----
      'category': _patientType?.categoryValue,
      'eligibility': _eligibilityData,
      'difficultyAssessment': _difficultyAssessmentData,
      'adl': _adlData,
      'confirmations': {
        'privacy_ack': _privacyAck ? 'read' : 'not_read',
        'truth_ack': _truthAck ? 'confirm' : 'edit',
      },

      // ---- ยืนยันตัวตน / เอกสารที่ขาด / ผู้กดลงทะเบียน ----
      'identityVerification': _identityVerificationData,
      'documentChecklist': _documentChecklistData,
      'registrant': _registrantData,

      // ---- ข้อมูลระบบ ----
      'submittedAt': DateTime.now().toUtc().toIso8601String(),
      'lineUserId': locator<AuthService>().profile?.userId,
      'customerCode': EnvHelper.customerCode,
    };
  }

  /// `registrant` — โปรไฟล์ LINE ของคนที่กดส่งคำขอ (อาจไม่ใช่ตัวผู้ป่วย)
  Map<String, dynamic> get _registrantData {
    final profile = locator<AuthService>().profile;
    return {
      'lineUserId': profile?.userId,
      'displayName': profile?.displayName,
      'pictureUrl': profile?.pictureUrl,
      'channel': LiffService.isMockMode ? 'web_dev' : 'liff',
      'platform': defaultTargetPlatform.name,
    };
  }

  /// FormData ที่ส่งไป `/api/v1/patients`: `data` = requestData (JSON) + ไฟล์ตามชื่อฟิลด์
  FormData buildFormData() {
    final formData = FormData()
      ..fields.add(MapEntry('data', jsonEncode(requestData)));
    filesToSubmit.forEach((fieldName, files) {
      for (final file in files) {
        final mime = MimeHelper.getMimeType(file.extension);
        formData.files.add(
          MapEntry(
            fieldName,
            MultipartFile.fromBytes(
              file.bytes,
              filename: file.name,
              contentType: mime == null ? null : MediaType.parse(mime),
            ),
          ),
        );
      }
    });
    return formData;
  }

  Future<bool> submit() async {
    if (isSubmitting) return false;

    _submitStatus = RegisterV2SubmitStatus.submitting;
    _errorMessage = null;
    notifyListeners();

    try {
      log('📝 RegisterV2 submit: $requestData');
      final response = await locator<PatientRepository>().createPatient(
        fomdata: buildFormData(),
      );
      if (response?['success'] != true) {
        throw Exception(response?['message'] ?? MessageConstant.defaultError);
      }
      _submitStatus = RegisterV2SubmitStatus.success;
      return true;
    } catch (e) {
      log('❌ RegisterV2 submit failed: $e');
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _submitStatus = RegisterV2SubmitStatus.failure;
      return false;
    } finally {
      notifyListeners();
    }
  }
}
