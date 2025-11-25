import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:rodzendai_form/core/services/hospital_service.dart';
import 'package:uuid/uuid.dart';
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
import 'package:rodzendai_form/presentation/blocs/district_bloc/district_bloc.dart';
import 'package:rodzendai_form/presentation/blocs/province_bloc/province_bloc.dart';
import 'package:rodzendai_form/presentation/blocs/sub_district_bloc/sub_district_bloc.dart';
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
  var uuid = Uuid();

  Timer? _debounceTimer;

  final GetLocationDetailBloc _getLocationDetailBloc;

  final _formKey = GlobalKey<FormState>();
  GlobalKey<FormState> get formKey => _formKey;

  final _formIdCardKey = GlobalKey<FormState>();
  GlobalKey<FormState> get formIdCardKey => _formIdCardKey;

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

  HospitalData? _selectedHospital;
  HospitalData? get selectedHospital => _selectedHospital;

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

  // Outbound Pickup (จุดรับผู้ป่วย - ขาไป) fields
  TextEditingController _outboundPickupLocationController =
      TextEditingController();
  TextEditingController get outboundPickupLocationController =>
      _outboundPickupLocationController;

  int? _outboundPickupProvinceCode;
  int? get outboundPickupProvinceCode => _outboundPickupProvinceCode;

  int? _outboundPickupDistrictCode;
  int? get outboundPickupDistrictCode => _outboundPickupDistrictCode;

  int? _outboundPickupSubDistrictCode;
  int? get outboundPickupSubDistrictCode => _outboundPickupSubDistrictCode;

  TextEditingController _outboundPickupLandmarkController =
      TextEditingController();
  TextEditingController get outboundPickupLandmarkController =>
      _outboundPickupLandmarkController;

  bool _outboundPickupSameAsCurrent = false;
  bool get outboundPickupSameAsCurrent => _outboundPickupSameAsCurrent;

  // Outbound Dropoff (จุดส่งผู้ป่วย - ขาไป) fields
  TextEditingController _outboundDropoffLocationController =
      TextEditingController();
  TextEditingController get outboundDropoffLocationController =>
      _outboundDropoffLocationController;

  int? _outboundDropoffProvinceCode;
  int? get outboundDropoffProvinceCode => _outboundDropoffProvinceCode;

  int? _outboundDropoffDistrictCode;
  int? get outboundDropoffDistrictCode => _outboundDropoffDistrictCode;

  int? _outboundDropoffSubDistrictCode;
  int? get outboundDropoffSubDistrictCode => _outboundDropoffSubDistrictCode;

  TextEditingController _outboundDropoffLandmarkController =
      TextEditingController();
  TextEditingController get outboundDropoffLandmarkController =>
      _outboundDropoffLandmarkController;

  // Inbound Pickup (จุดรับผู้ป่วย - ขากลับ) fields
  TextEditingController _inboundPickupLocationController =
      TextEditingController();
  TextEditingController get inboundPickupLocationController =>
      _inboundPickupLocationController;

  int? _inboundPickupProvinceCode;
  int? get inboundPickupProvinceCode => _inboundPickupProvinceCode;

  int? _inboundPickupDistrictCode;
  int? get inboundPickupDistrictCode => _inboundPickupDistrictCode;

  int? _inboundPickupSubDistrictCode;
  int? get inboundPickupSubDistrictCode => _inboundPickupSubDistrictCode;

  TextEditingController _inboundPickupLandmarkController =
      TextEditingController();
  TextEditingController get inboundPickupLandmarkController =>
      _inboundPickupLandmarkController;

  bool _inboundPickupSameAsCurrent = false;
  bool get inboundPickupSameAsCurrent => _inboundPickupSameAsCurrent;

  // Inbound Dropoff (จุดส่งผู้ป่วย - ขากลับ) fields
  TextEditingController _inboundDropoffLocationController =
      TextEditingController();
  TextEditingController get inboundDropoffLocationController =>
      _inboundDropoffLocationController;

  int? _inboundDropoffProvinceCode;
  int? get inboundDropoffProvinceCode => _inboundDropoffProvinceCode;

  int? _inboundDropoffDistrictCode;
  int? get inboundDropoffDistrictCode => _inboundDropoffDistrictCode;

  int? _inboundDropoffSubDistrictCode;
  int? get inboundDropoffSubDistrictCode => _inboundDropoffSubDistrictCode;

  TextEditingController _inboundDropoffLandmarkController =
      TextEditingController();
  TextEditingController get inboundDropoffLandmarkController =>
      _inboundDropoffLandmarkController;

  bool _inboundDropoffSameAsCurrent = false;
  bool get inboundDropoffSameAsCurrent => _inboundDropoffSameAsCurrent;

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

      'companionName': hasCompanion
          ? _companionNameController.textOrNull
          : null,
      'companionPhone': hasCompanion
          ? _companionPhoneController.textOrNull
          : null,
      'companionRelation': hasCompanion
          ? _companionRelationSelected?.value
          : null,

      'patientIdCard': _patientIdCardController.textOrNull,
      'patientName': _patientNameController.textOrNull,
      'patientPhone': _patientPhoneController.textOrNull,
      'patientLineId': _patientLineIdController.textOrNull,
      //'patientType': _patientTypeSelected?.valueToStore,
      'patientType': _patientData?.patient?.type,
      'pickupAddress': _registerPickupLocationController.textOrNull,
      'pickupLatitude': _selectedLocation?.latitude.toString(),
      'pickupLongitude': _selectedLocation?.longitude.toString(),
      'pickupPlusCode': null,
      //'transportAbility': _transportAbilitySelected?.valueToStore,
      'transportAbility': _patientData?.transportation?.ability,
      'appointmentDate': DateHelper.formatDate(
        _appointmentDateSelected,
      ), // "2025-08-27"
      'appointmentTime': DateHelper.formatTime(
        _appointmentTimeSelected,
      ), // "09:30"
      'hospital': _selectedHospital?.name,
      'diagnosis': _diagnosisController.textOrNull,
      'transportNotes': _transportNotesController.textOrNull,
      //'registeredAddress': _registeredAddressController.textOrNull,
      'registeredAddress': getPatientAddress(),
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
      'createdBy': {
        'source': 'line',
        'userId': authService.profile?.userId,
        'displayName': authService.profile?.displayName,
      },
      "transport_request": getTransportRequest(),
    };
    log('📦 Preparing request data: $data');
    return data;
  }

  Map<String, dynamic> get requestDataCaseCRM {
    final authService = locator<AuthService>();
    final now = DateTime.now();
    Map<String, dynamic> data = {
      "recorded_by": authService.profile?.displayName,
      "recorded_date": DateHelper.formatDate(DateTime.now()),
      "data": [
        {
          "case_id":
              'zendai${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}', // "1020250609110268",
          "patient_info": {
            "full_name":
                "${patientData?.patient?.firstName ?? ''} ${patientData?.patient?.lastName ?? ''}",
            "patient_type": _patientData?.patient?.type,
            "service_type": _getServiceType(),
            "service_step": "0",
            "national_id": patientData?.patient?.idCardNumber,
            "date_of_birth": patientData?.patient?.dateOfBirth,
            "phone_number": patientData?.patient?.phone,
            "photo_document": "",
            "mobility_ability": _patientData?.transportation?.ability,
            "medical_diagnosis": _diagnosisController.textOrNull,
            "address": _patientData?.addresses?.registered?.address,
            "province": _patientData?.addresses?.registered?.provinceCode,
            "district": _patientData?.addresses?.registered?.districtCode,
            "subdistrict": _patientData?.addresses?.registered?.subDistrictCode,
          },
          "appointment_info": {
            'appointment_date': DateHelper.formatDate(
              _appointmentDateSelected,
            ), // "2025-08-27"
            'appointment_time': DateHelper.formatTime(
              _appointmentTimeSelected,
            ), // "09:30"
            "hospital_name":
                _selectedHospital?.displayName, //"11469 : รพ.เลิดสิน",
            "h_code": _selectedHospital?.hCode, // "11469",
            "hospital_code": _selectedHospital?.hCode, //"11469",
            "photo_document": [
              if (_uploadedFile?.bytes != null)
                {
                  "file": base64.encode(_uploadedFile!.bytes),
                  "type_document": _uploadedFile?.extension,
                  "order": 1,
                },
            ],
          },
          "reporter_info": [
            {
              'full_name': _contactNameController.textOrNull,
              'phone_number': _contactPhoneController.textOrNull,
              'relation_to_patient': _contactRelationSelected?.value,
            },
          ],
          "companions": [
            {
              'full_name': hasCompanion
                  ? _companionNameController.textOrNull
                  : null,
              'phone_number': hasCompanion
                  ? _companionPhoneController.textOrNull
                  : null,
              'relation_to_patient': hasCompanion
                  ? _companionRelationSelected?.value
                  : null,
              "companion_num_id": null,
            },
          ],
          "transport_request": getTransportRequest(),
        },
      ],
    };
    log('📦 Preparing  request data crm: ${json.encode(data)}');
    return data;
  }

  List<Map<String, Object>> getTransportRequest() {
    log('getTransportRequest -> ${serviceTypeSelected?.value}');

    switch (serviceTypeSelected) {
      case null:
        return [];
      case ServiceType.inbound:
        return [
          {
            "id": uuid.v7().toUpperCase(),
            "return_schedule": true, // กลับ
            "pickup_location": {
              "pickup_place": inboundPickupLocationController.textOrNull,
              "province": inboundPickupProvinceCode,
              "district": inboundPickupDistrictCode,
              "subdistrict": inboundPickupSubDistrictCode,
              "landmark": inboundPickupLandmarkController.textOrNull,
            },
            "dropoff_location": {
              "dropoff_place": inboundDropoffLocationController.textOrNull,
              "province": inboundDropoffProvinceCode,
              "district": inboundDropoffDistrictCode,
              "subdistrict": inboundDropoffSubDistrictCode,
              "landmark": inboundDropoffLandmarkController.textOrNull,
            },
          },
        ];
      case ServiceType.outbound:
        return [
          {
            "id": uuid.v7().toUpperCase(),
            "departure_schedule": true, // ไป
            "pickup_location": {
              "pickup_place": outboundPickupLocationController.textOrNull,
              "province": outboundPickupProvinceCode,
              "district": outboundPickupDistrictCode,
              "subdistrict": outboundPickupSubDistrictCode,
              "landmark": outboundPickupLandmarkController.textOrNull,
            },
            "dropoff_location": {
              "dropoff_place": outboundDropoffLocationController.textOrNull,
              "province": outboundDropoffProvinceCode,
              "district": outboundDropoffDistrictCode,
              "subdistrict": outboundDropoffSubDistrictCode,
              "landmark": outboundDropoffLandmarkController.textOrNull,
            },
          },
        ];
      case ServiceType.roundTrip:
        return [
          {
            "id": uuid.v7().toUpperCase(),
            "departure_schedule": true, // ไป
            "pickup_location": {
              "pickup_place": outboundPickupLocationController.textOrNull,
              "province": outboundPickupProvinceCode,
              "district": outboundPickupDistrictCode,
              "subdistrict": outboundPickupSubDistrictCode,
              "landmark": outboundPickupLandmarkController.textOrNull,
            },
            "dropoff_location": {
              "dropoff_place": outboundDropoffLocationController.textOrNull,
              "province": outboundDropoffProvinceCode,
              "district": outboundDropoffDistrictCode,
              "subdistrict": outboundDropoffSubDistrictCode,
              "landmark": outboundDropoffLandmarkController.textOrNull,
            },
          },
          {
            "id": uuid.v7().toUpperCase(),
            "return_schedule": true, // กลับ
            "pickup_location": {
              "pickup_place": inboundPickupLocationController.textOrNull,
              "province": inboundPickupProvinceCode,
              "district": inboundPickupDistrictCode,
              "subdistrict": inboundPickupSubDistrictCode,
              "landmark": inboundPickupLandmarkController.textOrNull,
            },
            "dropoff_location": {
              "dropoff_place": inboundDropoffLocationController.textOrNull,
              "province": inboundDropoffProvinceCode,
              "district": inboundDropoffDistrictCode,
              "subdistrict": inboundDropoffSubDistrictCode,
              "landmark": inboundDropoffLandmarkController.textOrNull,
            },
          },
        ];
    }
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

  void setSelectedHospital(HospitalData? value) async {
    _selectedHospital = value;
    log('_selectedHospital -> $_selectedHospital');
    if (_selectedHospital != null) {
      log('_selectedHospital.hCode -> ${_selectedHospital?.hCode}');
      log('_selectedHospital.subDistrict -> ${_selectedHospital?.subDistrict}');
      log('_selectedHospital.district -> ${_selectedHospital?.district}');
      log('_selectedHospital.province -> ${_selectedHospital?.province}');

      // Auto-fill hospital location based on service type
      await _autoFillHospitalLocation();
    } else {
      // ถ้าไม่มีโรงพยาบาล ให้ notify ทันที
      notifyListeners();
    }
  }

  /// เติมข้อมูลที่อยู่โรงพยาบาลอัตโนมัติตาม serviceType
  Future<void> _autoFillHospitalLocation() async {
    if (_selectedHospital == null) return;

    // สร้างข้อความที่อยู่โรงพยาบาล
    final hospitalAddress = _buildHospitalAddress();

    // ค้นหา codes จากชื่อ province, district, subdistrict
    int? provinceCode;
    int? districtCode;
    int? subDistrictCode;

    // 1. ค้นหา Province Code
    if (_selectedHospital?.province != null &&
        _selectedHospital!.province!.isNotEmpty) {
      provinceCode = await ProvinceBloc.findProvinceCodeByName(
        _selectedHospital!.province!,
      );
      log(
        'Found provinceCode: $provinceCode for ${_selectedHospital!.province}',
      );
    }

    // 2. ค้นหา District Code (ต้องมี provinceCode ก่อน)
    if (provinceCode != null &&
        _selectedHospital?.district != null &&
        _selectedHospital!.district!.isNotEmpty) {
      districtCode = await DistrictBloc.findDistrictCodeByName(
        _selectedHospital!.district!,
        provinceCode,
      );
      log(
        'Found districtCode: $districtCode for ${_selectedHospital!.district}',
      );
    }

    // 3. ค้นหา SubDistrict Code (ต้องมี districtCode ก่อน)
    if (districtCode != null &&
        _selectedHospital?.subDistrict != null &&
        _selectedHospital!.subDistrict!.isNotEmpty) {
      subDistrictCode = await SubDistrictBloc.findSubDistrictCodeByName(
        _selectedHospital!.subDistrict!,
        districtCode,
      );
      log(
        'Found subDistrictCode: $subDistrictCode for ${_selectedHospital!.subDistrict}',
      );
    }

    // เติมข้อมูลตาม serviceType แบบทีละขั้น
    switch (_serviceTypeSelected) {
      case ServiceType.outbound:
        // ขาไป: โรงพยาบาลเป็นจุดหมายปลายทาง (Dropoff)
        _outboundDropoffLocationController.text = hospitalAddress;

        // เซ็ต province ก่อน
        _outboundDropoffProvinceCode = provinceCode;
        notifyListeners();
        await Future.delayed(const Duration(milliseconds: 100));

        // เซ็ต district ตามหลัง
        _outboundDropoffDistrictCode = districtCode;
        notifyListeners();
        await Future.delayed(const Duration(milliseconds: 100));

        // เซ็ต subdistrict สุดท้าย
        _outboundDropoffSubDistrictCode = subDistrictCode;
        log('Auto-filled Outbound Dropoff with hospital: $hospitalAddress');
        break;

      case ServiceType.inbound:
        // ขากลับ: โรงพยาบาลเป็นจุดเริ่มต้น (Pickup)
        _inboundPickupLocationController.text = hospitalAddress;

        // เซ็ต province ก่อน
        _inboundPickupProvinceCode = provinceCode;
        notifyListeners();
        await Future.delayed(const Duration(milliseconds: 100));

        // เซ็ต district ตามหลัง
        _inboundPickupDistrictCode = districtCode;
        notifyListeners();
        await Future.delayed(const Duration(milliseconds: 100));

        // เซ็ต subdistrict สุดท้าย
        _inboundPickupSubDistrictCode = subDistrictCode;
        log('Auto-filled Inbound Pickup with hospital: $hospitalAddress');
        break;

      case ServiceType.roundTrip:
        // ไป-กลับ: โรงพยาบาลเป็นทั้งจุดหมายขาไป และจุดเริ่มต้นขากลับ
        _outboundDropoffLocationController.text = hospitalAddress;
        _inboundPickupLocationController.text = hospitalAddress;

        // เซ็ต province ก่อนสำหรับทั้ง 2 ทิศทาง
        _outboundDropoffProvinceCode = provinceCode;
        _inboundPickupProvinceCode = provinceCode;
        notifyListeners();
        await Future.delayed(const Duration(milliseconds: 100));

        // เซ็ต district ตามหลัง
        _outboundDropoffDistrictCode = districtCode;
        _inboundPickupDistrictCode = districtCode;
        notifyListeners();
        await Future.delayed(const Duration(milliseconds: 100));

        // เซ็ต subdistrict สุดท้าย
        _outboundDropoffSubDistrictCode = subDistrictCode;
        _inboundPickupSubDistrictCode = subDistrictCode;
        log('Auto-filled RoundTrip with hospital: $hospitalAddress');
        break;

      case null:
        log('Service type not selected, skip auto-fill');
        break;
    }

    // Notify listeners after all updates
    notifyListeners();
  }

  /// สร้างข้อความที่อยู่โรงพยาบาลจากข้อมูลใน HospitalData
  String _buildHospitalAddress() {
    final parts = <String>[];

    // เพิ่มชื่อโรงพยาบาล
    if (_selectedHospital?.displayName != null) {
      parts.add(_selectedHospital!.displayName);
    }

    // เพิ่มตำบล
    if (_selectedHospital?.subDistrict != null &&
        _selectedHospital!.subDistrict!.isNotEmpty) {
      parts.add('ตำบล${_selectedHospital!.subDistrict}');
    }

    // เพิ่มอำเภอ
    if (_selectedHospital?.district != null &&
        _selectedHospital!.district!.isNotEmpty) {
      parts.add('อำเภอ${_selectedHospital!.district}');
    }

    // เพิ่มจังหวัด
    if (_selectedHospital?.province != null &&
        _selectedHospital!.province!.isNotEmpty) {
      parts.add('จังหวัด${_selectedHospital!.province}');
    }

    return parts.join(' ');
  }

  void setServiceTypeSelected(ServiceType serviceType) async {
    log('setServiceTypeSelected -> $serviceType');
    _serviceTypeSelected = serviceType;

    // ถ้ามีโรงพยาบาลที่เลือกไว้แล้ว ให้เติมข้อมูลอัตโนมัติ
    if (_selectedHospital != null) {
      log('Hospital already selected, auto-filling location data...');
      await _autoFillHospitalLocation();
    } else {
      notifyListeners();
    }
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

  // void morkUpData() {
  //   _contactNameController.text = 'นายสมชาย ใจดี';
  //   _contactPhoneController.text = '0812345678';
  //   _contactRelationSelected = ContactRelationType.child;

  //   _companionNameController.text = 'นางสาวสมหญิง ใจดี';
  //   _companionPhoneController.text = '0898765432';
  //   _companionRelationSelected = ContactRelationType.spouse;

  //   _patientIdCardController.text = '1234567890123';
  //   _patientNameController.text = 'เด็กชายสมปอง ใจดี';
  //   _patientPhoneController.text = '0823456789';
  //   _patientLineIdController.text = 'sompong123';
  //   _patientTypeSelected = PatientType.elderly;
  //   _transportAbilitySelected = TransportAbility.independent;

  //   _appointmentDateSelected = DateTime.now().add(Duration(days: 3));
  //   _appointmentTimeSelected = TimeOfDay(hour: 10, minute: 30);
  //   //_selectedHospital = 'รพ.รามาธิบดี  มหาวิทยาลัยมหิดล';

  //   _diagnosisController.text = 'ไข้หวัดใหญ่';
  //   _transportNotesController.text = 'ไม่มีอาการแพ้ยา';

  //   _registeredAddressController.text =
  //       '123 หมู่ 4 ตำบลสุขใจ อำเภอเมือง จังหวัดกรุงเทพฯ 10100';
  //   _registerPickupLocationController.text =
  //       '123 หมู่ 4 ตำบลสุขใจ อำเภอเมือง จังหวัดกรุงเทพฯ 10100';

  //   _serviceTypeSelected = ServiceType.inbound;

  //   notifyListeners();
  // }

  void setEnableTapGoogleMap(bool enable) {
    log('setEnableTapGoogleMap -> $enable');
    _isEnableTapGoogleMap = enable;
    // Ensure UI updates when enabling/disabling map taps.
    notifyListeners();
  }

  void setPatientInfoFromIDCard(IDCardPayload idCardPayload) {
    log('setPatientInfoFromIDCard -> ${idCardPayload.toString()}');
    _patientIdCardController.text = idCardPayload.idCard ?? '';
    //_patientNameController.text = idCardPayload.fullName ?? '';
    //_registeredAddressController.text = idCardPayload.address ?? '';
    notifyListeners();
  }

  void setPatientData(PatientModel? patient) {
    log('setPatientData -> $patient');
    _patientData = patient;

    _patientNameController.text =
        '${patient?.patient?.firstName ?? ''} ${patient?.patient?.lastName ?? ''}';
    _patientIdCardController.text = patient?.patient?.idCardNumber ?? '';
    _patientPhoneController.text = patient?.patient?.phone ?? '';
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

  // Outbound Pickup (จุดรับผู้ป่วย - ขาไป) methods
  void setOutboundPickupProvinceCode(int? value) {
    log('setOutboundPickupProvinceCode -> $value');
    _outboundPickupProvinceCode = value;
    // Reset district and subdistrict when province changes
    _outboundPickupDistrictCode = null;
    _outboundPickupSubDistrictCode = null;
    notifyListeners();
  }

  void setOutboundPickupDistrictCode(int? value) {
    log('setOutboundPickupDistrictCode -> $value');
    _outboundPickupDistrictCode = value;
    // Reset subdistrict when district changes
    _outboundPickupSubDistrictCode = null;
    notifyListeners();
  }

  void setOutboundPickupSubDistrictCode(int? value) {
    log('setOutboundPickupSubDistrictCode -> $value');
    _outboundPickupSubDistrictCode = value;
    notifyListeners();
  }

  // Outbound Dropoff (จุดส่งผู้ป่วย - ขาไป) methods
  void setOutboundDropoffProvinceCode(int? value) {
    log('setOutboundDropoffProvinceCode -> $value');
    _outboundDropoffProvinceCode = value;
    _outboundDropoffDistrictCode = null;
    _outboundDropoffSubDistrictCode = null;
    notifyListeners();
  }

  void setOutboundDropoffDistrictCode(int? value) {
    log('setOutboundDropoffDistrictCode -> $value');
    _outboundDropoffDistrictCode = value;
    _outboundDropoffSubDistrictCode = null;
    notifyListeners();
  }

  void setOutboundDropoffSubDistrictCode(int? value) {
    log('setOutboundDropoffSubDistrictCode -> $value');
    _outboundDropoffSubDistrictCode = value;
    notifyListeners();
  }

  // Inbound Pickup (จุดรับผู้ป่วย - ขากลับ) methods
  void setInboundPickupProvinceCode(int? value) {
    log('setInboundPickupProvinceCode -> $value');
    _inboundPickupProvinceCode = value;
    _inboundPickupDistrictCode = null;
    _inboundPickupSubDistrictCode = null;
    notifyListeners();
  }

  void setInboundPickupDistrictCode(int? value) {
    log('setInboundPickupDistrictCode -> $value');
    _inboundPickupDistrictCode = value;
    _inboundPickupSubDistrictCode = null;
    notifyListeners();
  }

  void setInboundPickupSubDistrictCode(int? value) {
    log('setInboundPickupSubDistrictCode -> $value');
    _inboundPickupSubDistrictCode = value;
    notifyListeners();
  }

  // Inbound Dropoff (จุดส่งผู้ป่วย - ขากลับ) methods
  void setInboundDropoffProvinceCode(int? value) {
    log('setInboundDropoffProvinceCode -> $value');
    _inboundDropoffProvinceCode = value;
    _inboundDropoffDistrictCode = null;
    _inboundDropoffSubDistrictCode = null;
    notifyListeners();
  }

  void setInboundDropoffDistrictCode(int? value) {
    log('setInboundDropoffDistrictCode -> $value');
    _inboundDropoffDistrictCode = value;
    _inboundDropoffSubDistrictCode = null;
    notifyListeners();
  }

  void setInboundDropoffSubDistrictCode(int? value) {
    log('setInboundDropoffSubDistrictCode -> $value');
    _inboundDropoffSubDistrictCode = value;
    notifyListeners();
  }

  // Same as current address methods
  void setOutboundPickupSameAsCurrent(bool value) async {
    log('setOutboundPickupSameAsCurrent -> $value');
    _outboundPickupSameAsCurrent = value;

    if (value && _patientData?.addresses?.current != null) {
      // ใช้ที่อยู่ปัจจุบันของผู้ป่วย
      _outboundPickupLocationController.text =
          _patientData?.addresses?.current?.address ?? '';
      _outboundPickupProvinceCode =
          _patientData?.addresses?.current?.provinceCode;
      _outboundPickupDistrictCode =
          _patientData?.addresses?.current?.districtCode;
      _outboundPickupSubDistrictCode =
          _patientData?.addresses?.current?.subDistrictCode;
    } else {
      // ล้างข้อมูล
      _outboundPickupLocationController.clear();
      _outboundPickupProvinceCode = null;
      _outboundPickupDistrictCode = null;
      _outboundPickupSubDistrictCode = null;
    }

    notifyListeners();
  }

  void setInboundPickupSameAsCurrent(bool value) async {
    log('setInboundPickupSameAsCurrent -> $value');
    _inboundPickupSameAsCurrent = value;

    if (value && _patientData?.addresses?.current != null) {
      // ใช้ที่อยู่ปัจจุบันของผู้ป่วย
      _inboundPickupLocationController.text =
          _patientData?.addresses?.current?.address ?? '';
      _inboundPickupProvinceCode =
          _patientData?.addresses?.current?.provinceCode;
      _inboundPickupDistrictCode =
          _patientData?.addresses?.current?.districtCode;
      _inboundPickupSubDistrictCode =
          _patientData?.addresses?.current?.subDistrictCode;
    } else {
      // ล้างข้อมูล
      _inboundPickupLocationController.clear();
      _inboundPickupProvinceCode = null;
      _inboundPickupDistrictCode = null;
      _inboundPickupSubDistrictCode = null;
    }

    notifyListeners();
  }

  void setInboundDropoffSameAsCurrent(bool value) async {
    log('setInboundDropoffSameAsCurrent -> $value');
    _inboundDropoffSameAsCurrent = value;

    if (value && _patientData?.addresses?.current != null) {
      // ใช้ที่อยู่ปัจจุบันของผู้ป่วย
      _inboundDropoffLocationController.text =
          _patientData?.addresses?.current?.address ?? '';
      _inboundDropoffProvinceCode =
          _patientData?.addresses?.current?.provinceCode;
      _inboundDropoffDistrictCode =
          _patientData?.addresses?.current?.districtCode;
      _inboundDropoffSubDistrictCode =
          _patientData?.addresses?.current?.subDistrictCode;
    } else {
      // ล้างข้อมูล
      _inboundDropoffLocationController.clear();
      _inboundDropoffProvinceCode = null;
      _inboundDropoffDistrictCode = null;
      _inboundDropoffSubDistrictCode = null;
    }

    notifyListeners();
  }

  /// สร้างข้อความที่อยู่เต็ม (รวมตำบล อำเภอ จังหวัด)
  Future<String> getCurrentAddressFullText() async {
    final parts = <String>[];

    // เพิ่มที่อยู่

    parts.add(_patientData?.addresses?.current?.address ?? ''.trim());

    // เพิ่มตำบล
    if (_patientData?.addresses?.current?.subDistrictCode != null) {
      final subDistrictName = await SubDistrictBloc.findSubDistrictNameByCode(
        _patientData?.addresses?.current?.subDistrictCode,
      );
      if (subDistrictName != null) {
        parts.add('ตำบล$subDistrictName');
      }
    }

    // เพิ่มอำเภอ
    if (_patientData?.addresses?.current?.districtCode != null) {
      final districtName = await DistrictBloc.findDistrictNameByCode(
        _patientData?.addresses?.current?.districtCode,
      );
      if (districtName != null) {
        parts.add('อำเภอ$districtName');
      }
    }

    // เพิ่มจังหวัด
    if (_patientData?.addresses?.current?.provinceCode != null) {
      final provinceName = await ProvinceBloc.findProvinceNameByCode(
        _patientData?.addresses?.current?.provinceCode,
      );
      if (provinceName != null) {
        parts.add('จังหวัด$provinceName');
      }
    }

    String currentAddressFullText = parts.join(' ');
    return currentAddressFullText;
  }

  String? _getServiceType() {
    if (_patientData?.projectInfo?.name == null) return null;

    if (_patientData?.projectInfo?.name == 'รับ-ส่งผู้ป่วยทุพพลภาพ') {
      return 'กองทุนท้องถิ่น (กปท.)';
    }
    return _patientData?.projectInfo?.name;
  }

  String getPatientAddress() {
    final address = _patientData?.addresses?.registered;
    if (address == null) {
      return '-';
    }
    return '${address.address ?? ''} ตำบล${address.subDistrict ?? '-'} อำเภอ${address.district ?? '-'} จังหวัด${address.province ?? '-'}';
  }
}
