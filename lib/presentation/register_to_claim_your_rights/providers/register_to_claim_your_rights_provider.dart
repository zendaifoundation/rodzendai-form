import 'dart:async';
import 'dart:developer';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rodzendai_form/core/extensions/text_editing_controller_extension.dart';
import 'package:rodzendai_form/core/services/auth_service.dart';
import 'package:rodzendai_form/core/services/service_locator.dart';
import 'package:rodzendai_form/core/utils/date_helper.dart';
import 'package:rodzendai_form/core/utils/env_helper.dart';
import 'package:rodzendai_form/presentation/blocs/district_bloc/district_bloc.dart';
import 'package:rodzendai_form/presentation/blocs/province_bloc/province_bloc.dart';
import 'package:rodzendai_form/presentation/blocs/sub_district_bloc/sub_district_bloc.dart';
import 'package:rodzendai_form/presentation/register/blocs/id_card_reader/id_card_reader_bloc.dart';
import 'package:rodzendai_form/presentation/register/interfaces/contact_relatio_type.dart';
import 'package:rodzendai_form/presentation/register/interfaces/patient_type.dart';
import 'package:rodzendai_form/presentation/register/interfaces/transport_ability.dart';
import 'package:rodzendai_form/presentation/register/widgets/box_upload_file_widget.dart';
import 'package:rodzendai_form/presentation/register_status/blocs/get_location_detail_bloc/get_location_detail_bloc.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/views/form_barthel_activity_adl.dart';
import 'package:rodzendai_form/widgets/dialog/app_dialogs.dart';

class RegisterToClaimYourRightsProvider extends ChangeNotifier {
  Timer? _debounceTimer;

  RegisterToClaimYourRightsProvider({
    required GetLocationDetailBloc getLocationDetailBloc,
  }) : _getLocationDetailBloc = getLocationDetailBloc {
    _pickupLocationFocusNode.addListener(() {
      _isEnableTapGoogleMap = !_pickupLocationFocusNode.hasFocus;
      log(
        '📍 Focus changed: hasFocus=${_pickupLocationFocusNode.hasFocus}, isEnableTapGoogleMap=$_isEnableTapGoogleMap',
      );
      notifyListeners();
    });
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
    _referrerNameController.dispose();
    _registeredAddressController.dispose();
    _currentAddressController.dispose();
    super.dispose();
  }

  final GetLocationDetailBloc _getLocationDetailBloc;

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

  DateTime? _dateOfBirth;
  DateTime? get dateOfBirth => _dateOfBirth;

  TransportAbility? _transportAbilitySelected;
  TransportAbility? get transportAbilitySelected => _transportAbilitySelected;

  //PatientType _patientTypeSelected = PatientType.elderly;
  PatientType? _patientTypeSelected;
  PatientType? get patientTypeSelected => _patientTypeSelected;

  bool _patientInfoForCompanion = false;
  bool get patientInfoForCompanion => _patientInfoForCompanion;

  bool _hasCompanion = false;
  bool get hasCompanion => _hasCompanion;

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

  // ข้อมูลผู้แนะนำ
  final _referrerNameController = TextEditingController();
  TextEditingController get referrerNameController => _referrerNameController;

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

  UploadedFile? _disabilityCardFiles;
  UploadedFile? get disabilityCardFiles => _disabilityCardFiles;

  UploadedFile? _thaiStateWelfareCardFiles;
  UploadedFile? get thaiStateWelfareCardFiles => _thaiStateWelfareCardFiles;

  List<UploadedFile> _otherFiles = [];
  List<UploadedFile> get otherFiles => _otherFiles;

  bool _uploadDocumentLater = false;
  bool get uploadDocumentLater => _uploadDocumentLater;

  bool _sameAsRegistered = false;
  bool get sameAsRegistered => _sameAsRegistered;

  bool _pdpaAccepted = false;
  bool get pdpaAccepted => _pdpaAccepted;

  TextEditingController _registerPickupLocationController =
      TextEditingController();
  TextEditingController get registerPickupLocationController =>
      _registerPickupLocationController;

  String get currentAddress => _currentAddressController.text.trim();

  String? _currentAddressFullText;
  String? get currentAddressFullText => _currentAddressFullText;

  /// สร้างข้อความที่อยู่เต็ม (รวมตำบล อำเภอ จังหวัด)
  Future<String> getCurrentAddressFullText() async {
    final parts = <String>[];

    // เพิ่มที่อยู่
    if (_currentAddressController.text.trim().isNotEmpty) {
      parts.add(_currentAddressController.text.trim());
    }

    // เพิ่มตำบล
    if (_currentSubDistrictCode != null) {
      final subDistrictName = await SubDistrictBloc.findSubDistrictNameByCode(
        _currentSubDistrictCode!,
      );
      if (subDistrictName != null) {
        parts.add('ตำบล$subDistrictName');
      }
    }

    // เพิ่มอำเภอ
    if (_currentDistrictCode != null) {
      final districtName = await DistrictBloc.findDistrictNameByCode(
        _currentDistrictCode!,
      );
      if (districtName != null) {
        parts.add('อำเภอ$districtName');
      }
    }

    // เพิ่มจังหวัด
    if (_currentProvinceCode != null) {
      final provinceName = await ProvinceBloc.findProvinceNameByCode(
        _currentProvinceCode!,
      );
      if (provinceName != null) {
        parts.add('จังหวัด$provinceName');
      }
    }

    _currentAddressFullText = parts.join(' ');
    return _currentAddressFullText ?? '';
  }

  final FocusNode _pickupLocationFocusNode = FocusNode();
  FocusNode get pickupLocationFocusNode => _pickupLocationFocusNode;

  LatLng _currentLocation = LatLng(13.7563, 100.5018); // กรุงเทพฯ
  LatLng get currentLocation => _currentLocation;

  LatLng? _selectedLocation;
  LatLng? get selectedLocation => _selectedLocation;

  bool _isLoadingLocation = false;
  bool get isLoadingLocation => _isLoadingLocation;

  String? _locationError;

  String? get locationError => _locationError;

  GoogleMapController? _googleMapController;
  GoogleMapController? get googleMapController => _googleMapController;

  Set<Marker> _registerMarkers = {};
  Set<Marker> get registerMarkers => _registerMarkers;

  String? _formattedAddress;
  String? get formattedAddress => _formattedAddress;

  String? _pickupPlusCode;
  String? get pickupPlusCode => _pickupPlusCode;

  bool _isEnableTapGoogleMap = true;
  bool get isEnableTapGoogleMap => _isEnableTapGoogleMap;

  void setDateOfBirth(DateTime? value) {
    _dateOfBirth = value;
    notifyListeners();
  }

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

  void setHasCompanion(bool value) {
    _hasCompanion = value;
    log('setHasCompanion -> $_hasCompanion');
    notifyListeners();
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

  void setDisabilityCardFiles(UploadedFile? files) {
    _disabilityCardFiles = files;
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

  void setUploadDocumentLater(bool value) {
    _uploadDocumentLater = value;
    notifyListeners();
  }

  void setIsChecked(bool value) {
    _isChecked = value;
  }

  void setRegisteredProvinceCode(int? value) {
    log('setRegisteredProvinceCode -> $value');
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
    log('setRegisteredDistrictCode -> $value');
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
    log('setRegisteredSubDistrictCode -> $value');
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

  void setMarkers(LatLng newPosition) {
    _registerMarkers = {
      Marker(
        markerId: MarkerId('pickup_location'),
        position: newPosition,
        infoWindow: InfoWindow(
          title: 'สถานที่รับผู้ป่วย',
          snippet:
              '${newPosition.latitude.toStringAsFixed(6)}, ${newPosition.longitude.toStringAsFixed(6)}',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        draggable: true,
        onDragEnd: (position) {
          onMarkerDragEnd(position);
        },
      ),
    };

    _getLocationDetailBloc.add(
      GetLocationDetailRequestEvent(
        latitude: newPosition.latitude,
        longitude: newPosition.longitude,
      ),
    );
  }

  /// ปักหมุดใหม่เมื่อแตะที่แผนที่
  void onMapTap(LatLng location) {
    // if (!_isEnableTapGoogleMap) {
    //   log('⚠️ Map tap ignored - isEnableTapGoogleMap is false');
    //   return;
    // }
    log('🗺️ Map tapped at: ${location.latitude}, ${location.longitude}');

    // เก็บตำแหน่งที่เลือก
    _selectedLocation = location;

    // ลบหมุดเก่าและสร้างหมุดใหม่
    setMarkers(location);

    log('📍 Marker created at: ${location.latitude}, ${location.longitude}');
    log('📍 Total markers: ${_registerMarkers.length}');

    // เลื่อนกล้องไปที่ตำแหน่งใหม่
    _googleMapController?.animateCamera(
      CameraUpdate.newLatLngZoom(location, 15.0),
    );

    log('🔔 Notifying listeners...');
    notifyListeners();
  }

  /// เมื่อลากหมุดเสร็จ
  void onMarkerDragEnd(LatLng newPosition) {
    log('Marker dragged to: ${newPosition.latitude}, ${newPosition.longitude}');
    _selectedLocation = newPosition;

    // อัพเดทตำแหน่งหมุด
    setMarkers(newPosition);
    log(
      '📍 Marker updated to: ${newPosition.latitude}, ${newPosition.longitude}',
    );

    notifyListeners();
  }

  void clearMarkers() {
    _registerMarkers.clear();
    _selectedLocation = null;
    notifyListeners();
  }

  void setSameAsRegistered(bool value) async {
    log('setSameAsRegistered -> $value');
    _sameAsRegistered = value;
    // if (_registeredAddressController.text.isNotEmpty && _sameAsRegistered) {
    //   _registerPickupLocationController.text =
    //       _registeredAddressController.text;
    //   _formattedAddress = _registeredAddressController.text;
    // }
    if (_sameAsRegistered) {
      final fullAddress = await getCurrentAddressFullText();
      _registerPickupLocationController.text = fullAddress;
    }

    notifyListeners();
  }

  void setPdpaAccepted(bool value) {
    _pdpaAccepted = value;
    notifyListeners();
  }

  // Barthel ADL Index
  final Map<int, int> _barthelScores = {};
  int _barthelResetCount = 0;

  int? getBarthelScore(int questionId) {
    return _barthelScores[questionId];
  }

  void setBarthelScore(int questionId, int score) {
    _barthelScores[questionId] = score;
    log('📊 Barthel Q$questionId: $score');
    notifyListeners();
  }

  int getTotalBarthelScore() {
    return _barthelScores.values.fold(0, (sum, score) => sum + score);
  }

  Map<int, int> get barthelScores => Map.unmodifiable(_barthelScores);

  int get barthelResetCount => _barthelResetCount;

  void resetBarthelScores() {
    _barthelScores.clear();
    _barthelResetCount++;
    log('🔄 Barthel scores reset (count: $_barthelResetCount)');
    notifyListeners();
  }

  // สร้างข้อมูลแบบประเมิน Barthel ADL แบบละเอียด
  Map<String, dynamic> getBarthelAdlData() {
    final List<Map<String, dynamic>> details = [];

    // ใช้ข้อมูลจาก barthelQuestions ที่อยู่ใน form_barthel_activity_adl.dart
    for (var entry in _barthelScores.entries) {
      final questionId = entry.key;
      final score = entry.value;

      // หา question จาก barthelQuestions
      final question = barthelQuestions.firstWhereOrNull(
        (q) => q.id == questionId,
      );

      // หา answer text จาก options
      final String? answerText = question?.options
          .firstWhereOrNull((opt) => opt.score == score)
          ?.label;

      details.add({
        'questionId': questionId,
        'questionTitle': question?.title,
        'score': score,
        'answer': answerText,
      });
    }

    return {
      'details': details,
      'totalScore': getTotalBarthelScore(),
      'isEligible': getTotalBarthelScore() <= 11,
    };
  }

  /// ดึงตำแหน่งปัจจุบันของผู้ใช้
  Future<void> getCurrentLocation() async {
    try {
      _isLoadingLocation = true;
      _locationError = null;
      notifyListeners();

      log('📍 Starting to get current location... (Web: $kIsWeb)');

      // ตรวจสอบว่า Location Service เปิดอยู่หรือไม่
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      log('📍 Location service enabled: $serviceEnabled');

      if (!serviceEnabled) {
        _locationError = 'กรุณาเปิด Location Service ในการตั้งค่า';
        log('❌ Location services are disabled');
        _isLoadingLocation = false;
        _currentLocation = LatLng(13.7563, 100.5018); // Default: Bangkok
        notifyListeners();
        return;
      }

      if (kIsWeb) {
        // สำหรับ Web - ใช้ getCurrentPosition โดยตรง
        log('🌐 Running on Web - using HTML5 Geolocation');

        Position position =
            await Geolocator.getCurrentPosition(
              locationSettings: LocationSettings(
                accuracy: LocationAccuracy.high,
              ),
            ).timeout(
              Duration(seconds: 15),
              onTimeout: () {
                throw Exception('ไม่สามารถดึงตำแหน่งได้ (Timeout)');
              },
            );

        _currentLocation = LatLng(position.latitude, position.longitude);
        log(
          '✅ Current location (Web): ${position.latitude}, ${position.longitude}',
        );
      } else {
        // สำหรับ Mobile/Desktop - ตรวจสอบ permission ก่อน
        log('📱 Running on Mobile/Desktop - checking permissions');

        LocationPermission permission = await Geolocator.checkPermission();
        log('📍 Current permission status: $permission');

        if (permission == LocationPermission.denied) {
          log('📍 Requesting permission...');
          permission = await Geolocator.requestPermission();

          if (permission == LocationPermission.denied) {
            _locationError = 'ไม่ได้รับอนุญาตให้เข้าถึงตำแหน่ง';
            log('❌ Location permissions are denied');
            _isLoadingLocation = false;
            _currentLocation = LatLng(13.7563, 100.5018); // Default: Bangkok
            notifyListeners();
            return;
          }
        }

        if (permission == LocationPermission.deniedForever) {
          _locationError = 'กรุณาเปิดการเข้าถึงตำแหน่งในการตั้งค่า';
          log('❌ Location permissions are permanently denied');
          _isLoadingLocation = false;
          _currentLocation = LatLng(13.7563, 100.5018); // Default: Bangkok
          notifyListeners();
          return;
        }

        // ดึงตำแหน่งปัจจุบัน
        log('🔄 Getting current position...');
        Position position =
            await Geolocator.getCurrentPosition(
              locationSettings: LocationSettings(
                accuracy: LocationAccuracy.high,
                distanceFilter: 10,
              ),
            ).timeout(
              Duration(seconds: 15),
              onTimeout: () {
                throw Exception('ไม่สามารถดึงตำแหน่งได้ (Timeout)');
              },
            );

        _currentLocation = LatLng(position.latitude, position.longitude);
        log(
          '✅ Current location (Mobile): ${position.latitude}, ${position.longitude}',
        );
      }

      _isLoadingLocation = false;
      log('⚡ Location fetching completed');
      log('🔔 Notifying listeners...');
      notifyListeners();

      // เลื่อนกล้องไปยังตำแหน่งปัจจุบัน (หลังจาก notify เพื่อให้ map rebuild ก่อน)
      await Future.delayed(Duration(milliseconds: 300));

      if (_googleMapController != null) {
        log(
          '📷 Animating camera to: ${_currentLocation.latitude}, ${_currentLocation.longitude}',
        );
        await _googleMapController?.animateCamera(
          CameraUpdate.newLatLngZoom(_currentLocation, 17.0),
        );
        setMarkers(_currentLocation);
        notifyListeners();
        log('✅ Camera animation completed');
      } else {
        log('⚠️ GoogleMapController is null, cannot animate camera');
      }
    } catch (e) {
      log('❌ Error getting location: $e');

      // ตรวจสอบ error message เพื่อแสดงข้อความที่เหมาะสม
      String errorMessage = e.toString();
      if (errorMessage.contains('Position update is unavailable')) {
        _locationError =
            'ไม่สามารถดึงตำแหน่งได้ กรุณาตรวจสอบ:\n'
            '1. Location Service เปิดอยู่\n'
            '2. Browser/App มีสิทธิ์เข้าถึงตำแหน่ง\n'
            '3. ใช้ HTTPS (สำหรับ Web)';
      } else if (errorMessage.contains('Timeout')) {
        _locationError = 'ใช้เวลาดึงตำแหน่งนานเกินไป กรุณาลองอีกครั้ง';
      } else {
        _locationError = 'ไม่สามารถดึงตำแหน่งได้: ${e.toString()}';
      }

      // Use default location (Bangkok) as a fallback so map still renders.
      _currentLocation = LatLng(13.7563, 100.5018);

      log('⚠️ Using default location (Bangkok)');

      _isLoadingLocation = false;
      notifyListeners();
    }
  }

  void onMapCreated(GoogleMapController controller) async {
    log('🗺️ Map created!');
    _googleMapController = controller;
    await getCurrentLocation();
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
        'dateOfBirth': DateHelper.formatDateThai(_dateOfBirth),
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
          'provinceCode': _registeredProvinceCode,
          'districtCode': _registeredDistrictCode,
          'subDistrictCode': _registeredSubDistrictCode,
          'pickupAddress': null,
          'pickupLatitude': null,
          'pickupLongitude': null,
          'currentLocation': null,
          'pickupPlusCode': _pickupPlusCode,
        },

        // ข้อมูลที่อยู่ปัจจุบัน
        'current': {
          'address': _currentAddressController.textOrNull,
          'provinceCode': _currentProvinceCode,
          'districtCode': _currentDistrictCode,
          'subDistrictCode': _currentSubDistrictCode,
          'pickupAddress': _registerPickupLocationController.textOrNull,
          'pickupLatitude': _selectedLocation?.latitude.toString(),
          'pickupLongitude': _selectedLocation?.longitude.toString(),
          'currentLocation': _formattedAddress,
          'pickupPlusCode': _pickupPlusCode,
        },
      },
      'barthelAdl': getBarthelAdlData(),
      // ข้อมูลผู้แนะนำ
      'referrer': {'name': _referrerNameController.textOrNull},
      // ข้อมูลการเดินทาง
      'transportation': {'ability': _transportAbilitySelected?.valueToStore},

      // ข้อมูลเอกสาร (สามารถอัพโหลดได้สูงสุด 5 ไฟล์)
      'documents': null,
      '_pdpaAccepted': _pdpaAccepted,

      // ข้อมูลระบบ
      'submittedAt': DateTime.now().toUtc().toIso8601String(),
      'lineUserId': authService.profile?.userId,
      // ไม่ใส่ createdAt, updatedAt เพราะจะถูกเพิ่มที่ repository ด้วย FieldValue.serverTimestamp()
    };
    log('📦 Preparing request data: $data');
    return data;
  }

  bool get isBarthelActivityAdlVisible =>
      _patientTypeSelected == PatientType.elderly ||
      _patientTypeSelected == PatientType.hardship;

  // ตรวจสอบว่าตอบคำถาม Barthel ADL ครบหรือยัง
  bool get isBarthelAdlCompleted {
    if (!isBarthelActivityAdlVisible) {
      return true; // ถ้าไม่ต้องทำแบบประเมิน ถือว่าผ่าน
    }
    return _barthelScores.length == 10; // ต้องตอบครบ 10 ข้อ
  }

  // ตรวจสอบว่าผ่านเกณฑ์ Barthel ADL หรือไม่
  bool get isBarthelAdlEligible {
    if (!isBarthelActivityAdlVisible) {
      return true; // ถ้าไม่ต้องทำแบบประเมิน ถือว่าผ่าน
    }
    if (!isBarthelAdlCompleted) return false; // ยังตอบไม่ครบ
    return getTotalBarthelScore() <= 11; // คะแนนต้อง <= 11
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
    BuildContext context,
    IDCardPayload idCardPayload,
  ) async {
    log('setPatientInfoFromIDCard -> ${idCardPayload.toString()}');
    _patientIdCardController.text = idCardPayload.idCard ?? '';
    //_patientNameController.text = idCardPayload.fullName;
    _patientFirstNameController.text = idCardPayload.firstName ?? '';
    _patientLastNameController.text = idCardPayload.lastName ?? '';

    // แปลงวันเดือนปีเกิด
    String? birthDate = idCardPayload.bridthDate;
    log('birthDate from idCardPayload -> $birthDate');

    if (birthDate != null && birthDate.length == 8) {
      int year = int.parse(birthDate.substring(0, 4)) - 543; // ลบ 543 ปี
      int month = int.parse(birthDate.substring(4, 6));
      int day = int.parse(birthDate.substring(6, 8));
      _dateOfBirth = DateTime(year, month, day);
      log('Parsed dateOfBirth -> $_dateOfBirth');
    }

    log('address from idCardPayload -> ${idCardPayload.address}');
    List<String> adrr = (idCardPayload.address ?? '').split(' ');
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

      String? allowedProvinceCode = EnvHelper.allowedProvinceCode;
      log('allowedProvinceCode -> $allowedProvinceCode');

      if (allowedProvinceCode != null) {
        if (_registeredProvinceCode != int.tryParse(allowedProvinceCode)) {
          log('❌ Province code ${_registeredProvinceCode} is not allowed.');
          _registeredProvinceCode = null;
          _registeredDistrictCode = null;
          _registeredSubDistrictCode = null;
          await AppDialogs.warning(
            context,
            message: 'จังหวัดที่ท่านอยู่ ไม่อยู่ในพื้นที่ให้บริการ',
          );
          if (context.mounted) {
            context.go('/home');
          }
          return;
        }
      }
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

  void setFormattedAddress(String address) {
    _formattedAddress = address;
    notifyListeners();
  }

  void setPickupPlusCode(String? plusCode) {
    log('setPickupPlusCode -> $plusCode');
    _pickupPlusCode = plusCode;
  }
}
