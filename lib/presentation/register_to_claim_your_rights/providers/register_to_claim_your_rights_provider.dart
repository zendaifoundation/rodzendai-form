import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:rodzendai_form/presentation/register/interfaces/contact_relatio_type.dart';
import 'package:rodzendai_form/presentation/register/interfaces/patient_type.dart';
import 'package:rodzendai_form/presentation/register/interfaces/transport_ability.dart';
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
          _currentAddressController.text !=
              _registeredAddressController.text) {
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

  PatientType? _patientTypeSelected;
  PatientType? get patientTypeSelected => _patientTypeSelected;

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

  void setTransportAbilitySelected(TransportAbility? value) {}

  void setPatientTypeSelected(PatientType? value) {}

  void usePatientInfoForCompanion(bool bool) {}

  void setCompanionRelationSelected(ContactRelationType? value) {}

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
}
