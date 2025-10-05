import 'dart:developer';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rodzendai_form/core/extensions/text_editing_controller_extension.dart';
import 'package:rodzendai_form/models/interfaces/service_type.dart';
import 'package:rodzendai_form/presentation/register/interfaces/contact_relatio_type.dart';
import 'package:rodzendai_form/presentation/register/interfaces/patient_type.dart';
import 'package:rodzendai_form/presentation/register/interfaces/transport_ability.dart';
import 'package:rodzendai_form/presentation/register_status/blocs/get_location_detail_bloc/get_location_detail_bloc.dart';

class RegisterProvider extends ChangeNotifier {
  RegisterProvider({required GetLocationDetailBloc getLocationDetailBloc})
    : _getLocationDetailBloc = getLocationDetailBloc;

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

  // Patient Info
  PatientType? _patientTypeSelected;
  PatientType? get patientTypeSelected => _patientTypeSelected;

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

  TextEditingController _registeredAddressController = TextEditingController();
  TextEditingController get registeredAddressController =>
      _registeredAddressController;

  ServiceType? _serviceTypeSelected;
  ServiceType? get serviceTypeSelected => _serviceTypeSelected;

  TextEditingController _registerPickupLocationController =
      TextEditingController();
  TextEditingController get registerPickupLocationController =>
      _registerPickupLocationController;

  GoogleMapController? _googleMapController;
  GoogleMapController? get googleMapController => _googleMapController;

  LatLng _currentLocation = LatLng(13.7563, 100.5018); // กรุงเทพฯ
  LatLng get currentLocation => _currentLocation;

  Set<Marker> _registerMarkers = {};
  Set<Marker> get registerMarkers => _registerMarkers;

  LatLng? _selectedLocation;
  LatLng? get selectedLocation => _selectedLocation;

  bool _isLoadingLocation = false;
  bool get isLoadingLocation => _isLoadingLocation;

  String? _locationError;

  String? get locationError => _locationError;

  String? _formattedAddress;
  String? get formattedAddress => _formattedAddress;

  Map<String, dynamic> get requestData {
    Map<String, dynamic> data = {
      //
      'contactName': _contactNameController.textOrNull,
      'contactPhone': _contactPhoneController.textOrNull,
      'contactRelation': _contactRelationSelected?.value,

      'companionName': _companionNameController.textOrNull,
      'companionPhone': _companionPhoneController.textOrNull,
      'companionRelation': _companionRelationSelected?.value,
    };
    log('📦 Preparing request data: $data');
    return data;
  }

  TextEditingController? get patientIdCardController => null;

  TextEditingController? get patientNameController => null;

  TextEditingController? get patientPhoneController => null;

  TextEditingController? get patientLineIdController => null;

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

      // ใช้ตำแหน่งเริ่มต้น (กรุงเทพฯ) ถ้าไม่สามารถดึงตำแหน่งได้
      _locationError = null; // ไม่แสดง error ให้ใช้ตำแหน่งเริ่มต้นแทน
      _currentLocation = LatLng(13.7563, 100.5018);

      log('⚠️ Using default location (Bangkok)');

      _isLoadingLocation = false;
      notifyListeners();
    }
  }

  void onMapCreated(GoogleMapController controller) {
    log('🗺️ Map created!');
    _googleMapController = controller;

    getCurrentLocation();
  }

  /// ปักหมุดใหม่เมื่อแตะที่แผนที่
  void onMapTap(LatLng location) {
    log('🗺️ Map tapped at: ${location.latitude}, ${location.longitude}');

    // เก็บตำแหน่งที่เลือก
    _selectedLocation = location;

    // ลบหมุดเก่าและสร้างหมุดใหม่
    setMarkers(location);

    log('📍 Marker created at: ${location.latitude}, ${location.longitude}');
    log('📍 Total markers: ${_registerMarkers.length}');

    // เลื่อนกล้องไปที่ตำแหน่งใหม่
    _googleMapController?.animateCamera(
      CameraUpdate.newLatLngZoom(location, 17.0),
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
  void goToCurrentLocation() async {
    if (_googleMapController != null) {
      _googleMapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_currentLocation, 15.0),
      );
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
    _registerPickupLocationController.dispose();
    _googleMapController?.dispose();
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
}
