import 'dart:async';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:rodzendai_form/core/extensions/text_editing_controller_extension.dart';
import 'package:rodzendai_form/core/services/auth_service.dart';
import 'package:rodzendai_form/core/services/service_locator.dart';
import 'package:rodzendai_form/presentation/blocs/district_bloc/district_bloc.dart';
import 'package:rodzendai_form/presentation/blocs/province_bloc/province_bloc.dart';
import 'package:rodzendai_form/presentation/blocs/sub_district_bloc/sub_district_bloc.dart';
import 'package:rodzendai_form/presentation/register/blocs/id_card_reader/id_card_reader_bloc.dart';
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

  int? _registeredProvinceCode;
  int? get registeredProvinceCode => _registeredProvinceCode;

  int? _registeredDistrictCode;
  int? get registeredDistrictCode => _registeredDistrictCode;

  int? _registeredSubDistrictCode;
  int? get registeredSubDistrictCode => _registeredSubDistrictCode;

  int? _currentProvinceCode;
  int? get currentProvinceCode => _currentProvinceCode;
  int? _currentDistrictCode;

  int? get currentDistrictCode => _currentDistrictCode;
  int? _currentSubDistrictCode;
  int? get currentSubDistrictCode => _currentSubDistrictCode;

  bool _patientAddressForCurrentAddress = false;
  bool get patientAddressForCurrentAddress => _patientAddressForCurrentAddress;

  UploadedFile? _idCardFiles;
  UploadedFile? get idCardFiles => _idCardFiles;

  UploadedFile? _thaiStateWelfareCardFiles;
  UploadedFile? get thaiStateWelfareCardFiles => _thaiStateWelfareCardFiles;

  List<UploadedFile> _otherFiles = [];
  List<UploadedFile> get otherFiles => _otherFiles;

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
      _currentProvinceCode = _registeredProvinceCode;
      _currentDistrictCode = _registeredDistrictCode;
      _currentSubDistrictCode = _registeredSubDistrictCode;
    }
    notifyListeners();
  }

  void setIdCardFiles(UploadedFile? files) {
    _idCardFiles = files;
    notifyListeners();
  }

  void setThaiStateWelfareCardFiles(UploadedFile? files) {
    _thaiStateWelfareCardFiles = files;
    notifyListeners();
  }

  void setOtherFiles(List<UploadedFile> files) {
    _otherFiles = files;
    notifyListeners();
  }

  void setIsChecked(bool value) {
    _isChecked = value;
  }

  void setRegisteredProvinceCode(int? value) {
    _registeredProvinceCode = value;
    _registeredDistrictCode = null;
    _registeredSubDistrictCode = null;
    if (_patientAddressForCurrentAddress) {
      _currentProvinceCode = value;
      _currentDistrictCode = null;
      _currentSubDistrictCode = null;
    }
    notifyListeners();
  }

  void setRegisteredDistrictCode(int? value) {
    _registeredDistrictCode = value;
    if (value == null) {
      _registeredSubDistrictCode = null;
    }
    if (_patientAddressForCurrentAddress) {
      _currentDistrictCode = value;
      if (value == null) {
        _currentSubDistrictCode = null;
      }
    }
    notifyListeners();
  }

  void setRegisteredSubDistrictCode(int? value) {
    _registeredSubDistrictCode = value;
    if (_patientAddressForCurrentAddress) {
      _currentSubDistrictCode = value;
    }
    notifyListeners();
  }

  void setCurrentProvinceCode(int? value) {
    _currentProvinceCode = value;
    _currentDistrictCode = null;
    _currentSubDistrictCode = null;
    notifyListeners();
  }

  void setCurrentDistrictCode(int? value) {
    _currentDistrictCode = value;
    if (value == null) {
      _currentSubDistrictCode = null;
    }
    notifyListeners();
  }

  void setCurrentSubDistrictCode(int? value) {
    _currentSubDistrictCode = value;
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
        'type': _patientTypeSelected.valueToStore,
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
          'provinceCode': _registeredProvinceCode,
          'districtCode': _registeredDistrictCode,
          'subDistrictCode': _registeredSubDistrictCode,
        },

        // ข้อมูลที่อยู่ปัจจุบัน
        'current': {
          'address': _currentAddressController.textOrNull,
          'provinceCode': _currentProvinceCode,
          'districtCode': _currentDistrictCode,
          'subDistrictCode': _currentSubDistrictCode,
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
    // _patientIdCardController.text = '1100400057961';
    // _patientPhoneController.text = '0839047769';
    // _patientFirstNameController.text = 'วิไล';
    // _patientLastNameController.text = 'เรืองวรางรัตน์';
    // _patientLineIdController.text = 'linetester';
    // _registeredAddressController.text = 'ทดสอบ';
    // _registeredProvinceCode = 1;
    // _registeredDistrictCode = 1001;
    // _registeredSubDistrictCode = 100101;
    // _transportAbilitySelected = TransportAbility.dependent;
    // _patientTypeSelected = PatientType.elderly;

    // usePatientInfoForCompanion(true);
    // usePatientAddressForCurrentAddress(true);
  }

  Future<void> setPatientInfoFromIDCard(
    context,
    IDCardPayload idCardPayload,
  ) async {
    log('setPatientInfoFromIDCard -> ${idCardPayload.toString()}');
    _patientIdCardController.text = idCardPayload.idCard;
    //_patientNameController.text = idCardPayload.fullName;
    _patientFirstNameController.text = idCardPayload.firstName;
    _patientLastNameController.text = idCardPayload.lastName;
    log('address from idCardPayload -> ${idCardPayload.address}');

    List<String> adrr = idCardPayload.address.split(' ');
    log('adrr -> $adrr');

    String houseAddress = '';
    String? provinceName;
    String? districtName;
    String? subDistrictName;

    for (var element in adrr) {
      log('message loop address -> $element');
      if (element.startsWith('ตำบล') ||
          element.startsWith('อำเภอ') ||
          element.startsWith('จังหวัด')) {
        if (element.startsWith('ตำบล')) {
          log('found subDistrictName in address loop -> $element');
          subDistrictName = element.replaceFirst('ตำบล', '').trim();
        } else if (element.startsWith('อำเภอ')) {
          log('found districtName in address loop -> $element');
          districtName = element.replaceFirst('อำเภอ', '').trim();
        } else if (element.startsWith('จังหวัด')) {
          log('found provinceName in address loop -> $element');
          provinceName = element.replaceFirst('จังหวัด', '').trim();
        }
        continue;
      }
      houseAddress += '$element ';
    }
    log('houseAddress -> $houseAddress');
    log('provinceName -> $provinceName');
    log('districtName -> $districtName');
    log('subDistrictName -> $subDistrictName');

    _registeredAddressController.text = houseAddress;

    // Lookup location codes from Thai names
    if (provinceName != null) {
      _registeredProvinceCode = await ProvinceBloc.findProvinceCodeByName(
        provinceName,
      );
      log('_registeredProvinceCode -> $_registeredProvinceCode');

      if (_registeredProvinceCode != null && districtName != null) {
        _registeredDistrictCode = await DistrictBloc.findDistrictCodeByName(
          districtName,
          _registeredProvinceCode!,
        );
        log('_registeredDistrictCode -> $_registeredDistrictCode');

        if (_registeredDistrictCode != null && subDistrictName != null) {
          _registeredSubDistrictCode =
              await SubDistrictBloc.findSubDistrictCodeByName(
                subDistrictName,
                _registeredDistrictCode!,
              );
          log('_registeredSubDistrictCode -> $_registeredSubDistrictCode');
        }
      }
    }

    notifyListeners();
  }
}
