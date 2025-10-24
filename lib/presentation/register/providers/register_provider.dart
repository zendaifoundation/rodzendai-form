import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rodzendai_form/core/extensions/text_editing_controller_extension.dart';
import 'package:rodzendai_form/core/services/auth_service.dart';
import 'package:rodzendai_form/core/services/service_locator.dart';
import 'package:rodzendai_form/core/utils/date_helper.dart';
import 'package:rodzendai_form/models/interfaces/service_type.dart';
import 'package:rodzendai_form/models/patient_response_model.dart';
import 'package:rodzendai_form/presentation/register/blocs/id_card_reader/id_card_reader_bloc.dart';
import 'package:rodzendai_form/presentation/register/interfaces/contact_relatio_type.dart';
import 'package:rodzendai_form/presentation/register/interfaces/patient_type.dart';
import 'package:rodzendai_form/presentation/register/interfaces/transport_ability.dart';
import 'package:rodzendai_form/presentation/register/widgets/box_upload_file_widget.dart';
import 'package:rodzendai_form/presentation/register_status/blocs/get_location_detail_bloc/get_location_detail_bloc.dart';

class RegisterProvider extends ChangeNotifier {
  RegisterProvider({required GetLocationDetailBloc getLocationDetailBloc})
    : _getLocationDetailBloc = getLocationDetailBloc {
    // Listen to focus changes
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
        notifyListeners();
      });
    });
  }
  Timer? _debounceTimer;

  final GetLocationDetailBloc _getLocationDetailBloc;

  final _formKey = GlobalKey<FormState>();
  GlobalKey<FormState> get formKey => _formKey;

  //
  final _contactNameController = TextEditingController();
  TextEditingController get contactNameController => _contactNameController;

  final _contactPhoneController = TextEditingController();
  TextEditingController get contactPhoneController => _contactPhoneController;

  ContactRelationType? _contactRelationSelected;
  ContactRelationType? get contactRelationSelected => _contactRelationSelected;

  bool _hasContact = false;
  bool get hasContact => _hasContact;

  bool _patientInfoForContact = false;
  bool get patientInfoForContact => _patientInfoForContact;

  final _companionNameController = TextEditingController();
  TextEditingController get companionNameController => _companionNameController;

  final _companionPhoneController = TextEditingController();
  TextEditingController get companionPhoneController =>
      _companionPhoneController;

  ContactRelationType? _companionRelationSelected;
  ContactRelationType? get companionRelationSelected =>
      _companionRelationSelected;

  bool _contactInfoForCompanion = false;
  bool get contactInfoForCompanion => _contactInfoForCompanion;

  bool _patientInfoForCompanion = false;
  bool get patientInfoForCompanion => _patientInfoForCompanion;

  bool _hasCompanion = false;
  bool get hasCompanion => _hasCompanion;

  // Patient Info
  PatientType? _patientTypeSelected;
  PatientType? get patientTypeSelected => _patientTypeSelected;

  final _patientIdCardController = TextEditingController();
  TextEditingController get patientIdCardController => _patientIdCardController;

  final _patientNameController = TextEditingController();
  TextEditingController get patientNameController => _patientNameController;

  final _patientPhoneController = TextEditingController();
  TextEditingController get patientPhoneController => _patientPhoneController;

  final _patientLineIdController = TextEditingController();
  TextEditingController get patientLineIdController => _patientLineIdController;

  TransportAbility? _transportAbilitySelected;
  TransportAbility? get transportAbilitySelected => _transportAbilitySelected;

  TimeOfDay? _appointmentTimeSelected;
  TimeOfDay? get appointmentTimeSelected => _appointmentTimeSelected;

  DateTime? _appointmentDateSelected;
  DateTime? get appointmentDateSelected => _appointmentDateSelected;

  String? _selectedHospital;
  String? get selectedHospital => _selectedHospital;

  TextEditingController _diagnosisController = TextEditingController();
  TextEditingController get diagnosisController => _diagnosisController;

  TextEditingController _transportNotesController = TextEditingController();
  TextEditingController get transportNotesController =>
      _transportNotesController;

  UploadedFile? _uploadedFile;
  UploadedFile? get uploadedFile => _uploadedFile;

  TextEditingController _registeredAddressController = TextEditingController();
  TextEditingController get registeredAddressController =>
      _registeredAddressController;

  ServiceType? _serviceTypeSelected;
  ServiceType? get serviceTypeSelected => _serviceTypeSelected;

  TextEditingController _registerPickupLocationController =
      TextEditingController();
  TextEditingController get registerPickupLocationController =>
      _registerPickupLocationController;

  final FocusNode _pickupLocationFocusNode = FocusNode();
  FocusNode get pickupLocationFocusNode => _pickupLocationFocusNode;

  GoogleMapController? _googleMapController;
  GoogleMapController? get googleMapController => _googleMapController;

  LatLng _currentLocation = LatLng(13.7563, 100.5018); // กรุงเทพฯ
  LatLng get currentLocation => _currentLocation;

  Set<Marker> _registerMarkers = {};
  Set<Marker> get registerMarkers => _registerMarkers;

  LatLng? _selectedLocation;
  LatLng? get selectedLocation => _selectedLocation;

  bool _sameAsRegistered = false;
  bool get sameAsRegistered => _sameAsRegistered;

  bool _isLoadingLocation = false;
  bool get isLoadingLocation => _isLoadingLocation;

  String? _locationError;

  String? get locationError => _locationError;

  String? _formattedAddress;
  String? get formattedAddress => _formattedAddress;

  bool _isEnableTapGoogleMap = true;
  bool get isEnableTapGoogleMap => _isEnableTapGoogleMap;

  ///
  PatientModel? _patientData;
  PatientModel? get patientData => _patientData;

  Map<String, dynamic> get requestData {
    final authService = locator<AuthService>();
    Map<String, dynamic> data = {
      //
      'contactName': _contactNameController.textOrNull,
      'contactPhone': _contactPhoneController.textOrNull,
      'contactRelation': _contactRelationSelected?.value,

      'companionName': _companionNameController.textOrNull,
      'companionPhone': _companionPhoneController.textOrNull,
      'companionRelation': _companionRelationSelected?.value,

      'patientIdCard': _patientIdCardController.textOrNull,
      'patientName': _patientNameController.textOrNull,
      'patientPhone': _patientPhoneController.textOrNull,
      'patientLineId': _patientLineIdController.textOrNull,
      'patientType': _patientTypeSelected?.valueToStore,
      'pickupAddress': _registerPickupLocationController.textOrNull,
      'pickupLatitude': _selectedLocation?.latitude.toString(),
      'pickupLongitude': _selectedLocation?.longitude.toString(),
      'pickupPlusCode': null,
      'transportAbility': _transportAbilitySelected?.valueToStore,
      'appointmentDate': DateHelper.formatDate(
        _appointmentDateSelected,
      ), // "2025-08-27"
      'appointmentTime': DateHelper.formatTime(
        _appointmentTimeSelected,
      ), // "09:30"
      'hospital': _selectedHospital,
      'diagnosis': _diagnosisController.textOrNull,
      'transportNotes': _transportNotesController.textOrNull,
      'registeredAddress': _registeredAddressController.textOrNull,
      'currentLocation': _formattedAddress,
      'serviceType': _serviceTypeSelected?.value,
      'appointmentDocumentName': null,
      'appointmentDocumentUrl': null,
      'appointmentDocumentOriginalFileName': null,
      'status': 'รอดำเนินการ',
      'submittedAt': DateTime.now().toUtc().toIso8601String(),
      'createdAt': null,
      'updatedAt': null,
      'lineUserId': authService.profile?.userId,
      // ไม่ใส่ timestamp ที่นี่ เพราะจะถูกเพิ่มที่ repository ด้วย FieldValue.serverTimestamp()
    };
    log('📦 Preparing request data: $data');
    return data;
  }

  /// ดึงตำแหน่งปัจจุบันของผู้ใช้
  Future<void> getCurrentLocation() async {
    try {
      _isLoadingLocation = true;
      _locationError = null;
      notifyListeners();

      log('📍 Starting to get current location... (Web: $kIsWeb)');

      if (kIsWeb) {
        // สำหรับ Web - ใช้ getCurrentPosition โดยตรง
        log('🌐 Running on Web - using HTML5 Geolocation');

        Position position =
            await Geolocator.getCurrentPosition(
              locationSettings: LocationSettings(
                accuracy: LocationAccuracy.high,
              ),
            ).timeout(
              Duration(seconds: 10),
              onTimeout: () {
                throw Exception('Timeout: ไม่สามารถดึงตำแหน่งได้');
              },
            );

        _currentLocation = LatLng(position.latitude, position.longitude);
        log(
          '✅ Current location (Web): ${position.latitude}, ${position.longitude}',
        );
      } else {
        // สำหรับ Mobile - ตรวจสอบ permission ก่อน
        log('📱 Running on Mobile - checking permissions');

        LocationPermission permission = await Geolocator.checkPermission();
        log('📍 Current permission status: $permission');

        if (permission == LocationPermission.denied) {
          log('📍 Requesting permission...');
          permission = await Geolocator.requestPermission();

          if (permission == LocationPermission.denied) {
            _locationError = 'ไม่ได้รับอนุญาตให้เข้าถึงตำแหน่ง';
            log('❌ Location permissions are denied');
            _isLoadingLocation = false;
            notifyListeners();
            return;
          }
        }

        if (permission == LocationPermission.deniedForever) {
          _locationError = 'กรุณาเปิดการเข้าถึงตำแหน่งในการตั้งค่า';
          log('❌ Location permissions are permanently denied');
          _isLoadingLocation = false;
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
              Duration(seconds: 10),
              onTimeout: () {
                throw Exception('Timeout: ไม่สามารถดึงตำแหน่งได้');
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

      // Preserve the error message so the UI can show it (helps debugging
      // intermittent failures such as timeouts or permission issues).
      _locationError = e.toString();

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

  /// ไปยังตำแหน่งปัจจุบัน
  Future<void> goToCurrentLocation() async {
    log('📍 Going to current location...');

    // ดึงตำแหน่งปัจจุบันใหม่
    await getCurrentLocation();

    // เลื่อนกล้องไปยังตำแหน่งปัจจุบัน
    if (_googleMapController != null) {
      await _googleMapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_currentLocation, 17.0),
      );

      // วางหมุดที่ตำแหน่งปัจจุบัน
      setMarkers(_currentLocation);
      _selectedLocation = _currentLocation;

      log(
        '✅ Moved to current location: ${_currentLocation.latitude}, ${_currentLocation.longitude}',
      );
      notifyListeners();
    }
  }

  /// ล้างหมุดทั้งหมด
  void clearMarkers() {
    _registerMarkers.clear();
    _selectedLocation = null;
    notifyListeners();
  }

  void setFormattedAddress(String address) {
    _formattedAddress = address;
    notifyListeners();
  }

  @override
  void dispose() {
    log('dispose RegisterProvider');
    _contactNameController.dispose();
    _contactPhoneController.dispose();
    _companionNameController.dispose();
    _companionPhoneController.dispose();
    _diagnosisController.dispose();
    _transportNotesController.dispose();
    _registeredAddressController.dispose();
    _registerPickupLocationController.dispose();
    _pickupLocationFocusNode.dispose();

    super.dispose();
  }

  void setContactRelationSelected(ContactRelationType? value) {
    _contactRelationSelected = value;
    notifyListeners();
  }

  void useContactInfoForCompanion(bool value) {
    log('useContactInfoForCompanion -> $value');
    _contactInfoForCompanion = value;

    if (_contactInfoForCompanion) {
      _companionNameController.text = _contactNameController.text;
      _companionRelationSelected = _contactRelationSelected;
      _companionPhoneController.text = _contactPhoneController.text;

      log('_companionRelationSelected -> $_companionRelationSelected');
    }
    notifyListeners();
  }

  void usePatientInfoForContact(bool value) {
    log('usePatientInfoForContact -> $value');
    _patientInfoForContact = value;

    if (_patientInfoForContact) {
      _contactNameController.text = _patientNameController.text;
      _contactRelationSelected = ContactRelationType.self;
      _contactPhoneController.text = _patientPhoneController.text;

      log('_contactRelationSelected -> $_contactRelationSelected');
    }
    notifyListeners();
  }

  void usePatientInfoForCompanion(bool value) {
    log('usePatientInfoForCompanion -> $value');
    _patientInfoForCompanion = value;

    if (_patientInfoForCompanion) {
      _companionNameController.text = _patientNameController.text;
      _companionRelationSelected = ContactRelationType.self;
      _companionPhoneController.text = _patientPhoneController.text;

      log('_companionRelationSelected -> $_companionRelationSelected');
    }
    notifyListeners();
  }

  void setCompanionRelationSelected(ContactRelationType? value) {
    _companionRelationSelected = value;
    log('_companionRelationSelected -> $_companionRelationSelected');
    notifyListeners();
  }

  void setPatientTypeSelected(PatientType? value) {
    _patientTypeSelected = value;
    notifyListeners();
  }

  void setTransportAbilitySelected(TransportAbility? value) {
    _transportAbilitySelected = value;
    notifyListeners();
  }

  void setAppointmentTime(TimeOfDay selectedTime) {
    _appointmentTimeSelected = selectedTime;
    notifyListeners();
  }

  void setAppointmentDate(DateTime dateTime) {
    _appointmentDateSelected = dateTime;
    notifyListeners();
  }

  void setSelectedHospital(String? value) {
    _selectedHospital = value;
    notifyListeners();
  }

  void setServiceTypeSelected(ServiceType serviceType) {
    log('setServiceTypeSelected -> $serviceType');
    _serviceTypeSelected = serviceType;
    notifyListeners();
  }

  void setSameAsRegistered(bool value) {
    log('setSameAsRegistered -> $value');
    _sameAsRegistered = value;
    if (_registeredAddressController.text.isNotEmpty && _sameAsRegistered) {
      _registerPickupLocationController.text =
          _registeredAddressController.text;
      _formattedAddress = _registeredAddressController.text;
    }
    notifyListeners();
  }

  void setUploadedFile(UploadedFile? file) {
    log('setUploadedFile -> $file');
    _uploadedFile = file;
    notifyListeners();
  }

  void morkUpData() {
    _contactNameController.text = 'นายสมชาย ใจดี';
    _contactPhoneController.text = '0812345678';
    _contactRelationSelected = ContactRelationType.child;

    _companionNameController.text = 'นางสาวสมหญิง ใจดี';
    _companionPhoneController.text = '0898765432';
    _companionRelationSelected = ContactRelationType.spouse;

    _patientIdCardController.text = '1234567890123';
    _patientNameController.text = 'เด็กชายสมปอง ใจดี';
    _patientPhoneController.text = '0823456789';
    _patientLineIdController.text = 'sompong123';
    _patientTypeSelected = PatientType.elderly;
    _transportAbilitySelected = TransportAbility.independent;

    _appointmentDateSelected = DateTime.now().add(Duration(days: 3));
    _appointmentTimeSelected = TimeOfDay(hour: 10, minute: 30);
    _selectedHospital = 'รพ.รามาธิบดี  มหาวิทยาลัยมหิดล';

    _diagnosisController.text = 'ไข้หวัดใหญ่';
    _transportNotesController.text = 'ไม่มีอาการแพ้ยา';

    _registeredAddressController.text =
        '123 หมู่ 4 ตำบลสุขใจ อำเภอเมือง จังหวัดกรุงเทพฯ 10100';
    _registerPickupLocationController.text =
        '123 หมู่ 4 ตำบลสุขใจ อำเภอเมือง จังหวัดกรุงเทพฯ 10100';

    _serviceTypeSelected = ServiceType.inbound;

    notifyListeners();
  }

  void setEnableTapGoogleMap(bool enable) {
    log('setEnableTapGoogleMap -> $enable');
    _isEnableTapGoogleMap = enable;
    // Ensure UI updates when enabling/disabling map taps.
    notifyListeners();
  }

  void setPatientInfoFromIDCard(IDCardPayload idCardPayload) {
    log('setPatientInfoFromIDCard -> $idCardPayload');
    _patientIdCardController.text = idCardPayload.idCard;
    _patientNameController.text = idCardPayload.fullName;
    _registeredAddressController.text = idCardPayload.address;
    notifyListeners();
  }

  void setPatientData(PatientModel? patient) {
    log('setPatientData -> $patient');
    _patientData = patient;
    notifyListeners();
  }

  void setHasCompanion(bool value) {
    _hasCompanion = value;
    notifyListeners();
  }

  void setHasContact(bool value) {
    _hasContact = value;
    notifyListeners();
  }
}
