import 'dart:async';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:rodzendai_form/core/extensions/text_editing_controller_extension.dart';
import 'package:rodzendai_form/core/services/auth_service.dart';
import 'package:rodzendai_form/core/services/service_locator.dart';
import 'package:rodzendai_form/presentation/register/interfaces/contact_relatio_type.dart';
import 'package:rodzendai_form/presentation/register/interfaces/patient_type.dart';
import 'package:rodzendai_form/presentation/register/interfaces/transport_ability.dart';
import 'package:rodzendai_form/presentation/register/widgets/box_upload_file_widget.dart';
import 'package:rodzendai_form/presentation/register/widgets/box_upload_multi_file_widget.dart';

class RegisterToClaimYourRightsProvider extends ChangeNotifier {
  Timer? _debounceTimer;

  RegisterToClaimYourRightsProvider() {
    _patientIdCardController.addListener(() {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 300), () {
        _isChecked = false;
        notifyListeners();
      });
    });
    _registeredAddressController.addListener(() {
      if (_patientAddressForCurrentAddress &&
          _currentAddressController.text != _registeredAddressController.text) {
        _currentAddressController.text = _registeredAddressController.text;
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _patientIdCardController.dispose();
    _patientFirstNameController.dispose();
    _patientLastNameController.dispose();
    _patientPhoneController.dispose();
    _patientLineIdController.dispose();
    _companionIdCardController.dispose();
    _companionFirstNameController.dispose();
    _companionLastNameController.dispose();
    _companionPhoneController.dispose();
    _registeredAddressController.dispose();
    _currentAddressController.dispose();
    super.dispose();
  }

  final _formKey = GlobalKey<FormState>();
  GlobalKey<FormState> get formKey => _formKey;

  bool _isChecked = false;
  bool get isChecked => _isChecked;

  final _patientIdCardController = TextEditingController();
  TextEditingController get patientIdCardController => _patientIdCardController;

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

  TransportAbility? _transportAbilitySelected;
  TransportAbility? get transportAbilitySelected => _transportAbilitySelected;

  PatientType _patientTypeSelected = PatientType.elderly;
  PatientType get patientTypeSelected => _patientTypeSelected;

  bool _patientInfoForCompanion = false;
  bool get patientInfoForCompanion => _patientInfoForCompanion;

  final _companionIdCardController = TextEditingController();
  TextEditingController get companionIdCardController =>
      _companionIdCardController;

  final _companionFirstNameController = TextEditingController();
  TextEditingController get companionFirstNameController =>
      _companionFirstNameController;

  final _companionLastNameController = TextEditingController();
  TextEditingController get companionLastNameController =>
      _companionLastNameController;

  ContactRelationType? _companionRelationSelected;
  ContactRelationType? get companionRelationSelected =>
      _companionRelationSelected;

  final _companionPhoneController = TextEditingController();
  TextEditingController get companionPhoneController =>
      _companionPhoneController;

  final _registeredAddressController = TextEditingController();
  TextEditingController get registeredAddressController =>
      _registeredAddressController;

  final _currentAddressController = TextEditingController();
  TextEditingController get currentAddressController =>
      _currentAddressController;

  int? _registeredProvinceId;
  int? get registeredProvinceId => _registeredProvinceId;
  int? _registeredDistrictId;
  int? get registeredDistrictId => _registeredDistrictId;
  int? _registeredSubDistrictId;
  int? get registeredSubDistrictId => _registeredSubDistrictId;

  int? _currentProvinceId;
  int? get currentProvinceId => _currentProvinceId;
  int? _currentDistrictId;
  int? get currentDistrictId => _currentDistrictId;
  int? _currentSubDistrictId;
  int? get currentSubDistrictId => _currentSubDistrictId;

  bool _patientAddressForCurrentAddress = false;
  bool get patientAddressForCurrentAddress => _patientAddressForCurrentAddress;

  List<UploadedFile> _uploadedFiles = [];
  List<UploadedFile> get uploadedFiles => _uploadedFiles;

  void setTransportAbilitySelected(TransportAbility? value) {
    _transportAbilitySelected = value;
    notifyListeners();
  }

  void setPatientTypeSelected(PatientType value) {
    _patientTypeSelected = value;
    notifyListeners();
  }

  void usePatientInfoForCompanion(bool value) {
    log('usePatientInfoForCompanion -> $value');
    _patientInfoForCompanion = value;

    if (_patientInfoForCompanion) {
      _companionIdCardController.text = _patientIdCardController.text;
      _companionFirstNameController.text = _patientFirstNameController.text;
      _companionLastNameController.text = _patientLastNameController.text;
      _companionRelationSelected = ContactRelationType.self;
      _companionPhoneController.text = _patientPhoneController.text;

      log('_companionRelationSelected -> $_companionRelationSelected');
    }
    notifyListeners();
  }

  void setCompanionRelationSelected(ContactRelationType? value) {
    _companionRelationSelected = value;
  }

  void usePatientAddressForCurrentAddress(bool value) {
    _patientAddressForCurrentAddress = value;
    if (value) {
      _currentAddressController.text = _registeredAddressController.text;
      _currentProvinceId = _registeredProvinceId;
      _currentDistrictId = _registeredDistrictId;
      _currentSubDistrictId = _registeredSubDistrictId;
    }
    notifyListeners();
  }

  void setUploadedFiles(List<UploadedFile> files) {
    _uploadedFiles = files;
    notifyListeners();
  }

  void setIsChecked(bool value) {
    _isChecked = value;
  }

  void setRegisteredProvinceId(int? value) {
    _registeredProvinceId = value;
    _registeredDistrictId = null;
    _registeredSubDistrictId = null;
    if (_patientAddressForCurrentAddress) {
      _currentProvinceId = value;
      _currentDistrictId = null;
      _currentSubDistrictId = null;
    }
    notifyListeners();
  }

  void setRegisteredDistrictId(int? value) {
    _registeredDistrictId = value;
    if (value == null) {
      _registeredSubDistrictId = null;
    }
    if (_patientAddressForCurrentAddress) {
      _currentDistrictId = value;
      if (value == null) {
        _currentSubDistrictId = null;
      }
    }
    notifyListeners();
  }

  void setRegisteredSubDistrictId(int? value) {
    _registeredSubDistrictId = value;
    if (_patientAddressForCurrentAddress) {
      _currentSubDistrictId = value;
    }
    notifyListeners();
  }

  void setCurrentProvinceId(int? value) {
    _currentProvinceId = value;
    _currentDistrictId = null;
    _currentSubDistrictId = null;
    notifyListeners();
  }

  void setCurrentDistrictId(int? value) {
    _currentDistrictId = value;
    if (value == null) {
      _currentSubDistrictId = null;
    }
    notifyListeners();
  }

  void setCurrentSubDistrictId(int? value) {
    _currentSubDistrictId = value;
    notifyListeners();
  }

  Map<String, dynamic> get requestData {
    final authService = locator<AuthService>();
    Map<String, dynamic> data = {
      // ข้อมูลผู้ป่วย
      'patient': {
        'idCardNumber': _patientIdCardController.textOrNull,
        'firstName': _patientFirstNameController.textOrNull,
        'lastName': _patientLastNameController.textOrNull,
        'phone': _patientPhoneController.textOrNull,
        'lineId': _patientLineIdController.textOrNull,
        'type': _patientTypeSelected?.valueToStore,
      },
      // ข้อมูลผู้ติดต่อ
      'companion': {
        'idCardNumber': _companionIdCardController.textOrNull,
        'firstName': _companionFirstNameController.textOrNull,
        'lastName': _companionLastNameController.textOrNull,
        'phone': _companionPhoneController.textOrNull,
        'relation': _companionRelationSelected?.value,
      },
      //ข้อมูลที่อยู่
      'addresses': {
        // ข้อมูลที่อยู่ทะเบียน
        'registered': {
          'address': _registeredAddressController.textOrNull,
          'provinceId': _registeredProvinceId,
          'districtId': _registeredDistrictId,
          'subDistrictId': _registeredSubDistrictId,
        },

        // ข้อมูลที่อยู่ปัจจุบัน
        'current': {
          'address': _currentAddressController.textOrNull,
          'provinceId': _currentProvinceId,
          'districtId': _currentDistrictId,
          'subDistrictId': _currentSubDistrictId,
        },
      },
      // ข้อมูลการเดินทาง
      'transportation': {'ability': _transportAbilitySelected?.valueToStore},

      // ข้อมูลเอกสาร (สามารถอัพโหลดได้สูงสุด 5 ไฟล์)
      'documents': null,

      // ข้อมูลระบบ
      'submittedAt': DateTime.now().toUtc().toIso8601String(),
      'lineUserId': authService.profile?.userId,
      // ไม่ใส่ createdAt, updatedAt เพราะจะถูกเพิ่มที่ repository ด้วย FieldValue.serverTimestamp()
    };
    log('📦 Preparing request data: $data');
    return data;
  }

  void morkData() {
    _patientIdCardController.text = '1100400057961';
    _patientPhoneController.text = '0839047769';
    _patientFirstNameController.text = 'วิไล';
    _patientLastNameController.text = 'เรืองวรางรัตน์';
    _patientLineIdController.text = 'linetester';
    _registeredAddressController.text = 'ทดสอบ';
    _registeredProvinceId = 1;
    _registeredDistrictId = 1001;
    _registeredSubDistrictId = 100101;
    _transportAbilitySelected = TransportAbility.dependent;
    _patientTypeSelected = PatientType.elderly;

    usePatientInfoForCompanion(true);
    usePatientAddressForCurrentAddress(true);
  }
}
