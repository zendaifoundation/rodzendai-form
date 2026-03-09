import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rodzendai_form/core/extensions/text_editing_controller_extension.dart';
import 'package:rodzendai_form/models/patient_response_model.dart';
import 'package:rodzendai_form/presentation/blocs/district_bloc/district_bloc.dart';
import 'package:rodzendai_form/presentation/blocs/province_bloc/province_bloc.dart';
import 'package:rodzendai_form/presentation/blocs/sub_district_bloc/sub_district_bloc.dart';
import 'package:rodzendai_form/presentation/register_status/blocs/get_location_detail_bloc/get_location_detail_bloc.dart';

enum AddressType { registered, current }

class EditAddressProvider extends ChangeNotifier {
  EditAddressProvider({required GetLocationDetailBloc getLocationDetailBloc})
    : _getLocationDetailBloc = getLocationDetailBloc {
    _pickupLocationFocusNode.addListener(() {
      _isEnableTapGoogleMap = !_pickupLocationFocusNode.hasFocus;
      notifyListeners();
    });
  }

  final GetLocationDetailBloc _getLocationDetailBloc;

  final _formKey = GlobalKey<FormState>();
  GlobalKey<FormState> get formKey => _formKey;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // ---- เลขบัตรประชาชน ----
  final _idCardController = TextEditingController();
  TextEditingController get idCardController => _idCardController;

  // ---- patient id จากการค้นหา ----
  String? _patientId;
  String? get patientId => _patientId;

  // ---- ประเภทที่อยู่ที่ต้องการแก้ไข ----
  AddressType _selectedAddressType = AddressType.registered;
  AddressType get selectedAddressType => _selectedAddressType;

  void setAddressType(AddressType value) {
    _selectedAddressType = value;
    notifyListeners();
  }

  // ---- ที่อยู่ตามทะเบียนบ้าน ----
  final _registeredAddressController = TextEditingController();
  TextEditingController get registeredAddressController =>
      _registeredAddressController;

  int? _registeredProvinceCode;
  int? get registeredProvinceCode => _registeredProvinceCode;

  int? _registeredDistrictCode;
  int? get registeredDistrictCode => _registeredDistrictCode;

  int? _registeredSubDistrictCode;
  int? get registeredSubDistrictCode => _registeredSubDistrictCode;

  void setRegisteredProvinceCode(int? value) {
    _registeredProvinceCode = value;
    _registeredDistrictCode = null;
    _registeredSubDistrictCode = null;
    notifyListeners();
  }

  void setRegisteredDistrictCode(int? value) {
    _registeredDistrictCode = value;
    _registeredSubDistrictCode = null;
    notifyListeners();
  }

  void setRegisteredSubDistrictCode(int? value) {
    _registeredSubDistrictCode = value;
    notifyListeners();
  }

  // ---- ที่อยู่ปัจจุบัน ----
  final _currentAddressController = TextEditingController();
  TextEditingController get currentAddressController =>
      _currentAddressController;

  int? _currentProvinceCode;
  int? get currentProvinceCode => _currentProvinceCode;

  int? _currentDistrictCode;
  int? get currentDistrictCode => _currentDistrictCode;

  int? _currentSubDistrictCode;
  int? get currentSubDistrictCode => _currentSubDistrictCode;

  void setCurrentProvinceCode(int? value) {
    _currentProvinceCode = value;
    _currentDistrictCode = null;
    _currentSubDistrictCode = null;
    notifyListeners();
  }

  void setCurrentDistrictCode(int? value) {
    _currentDistrictCode = value;
    _currentSubDistrictCode = null;
    notifyListeners();
  }

  void setCurrentSubDistrictCode(int? value) {
    _currentSubDistrictCode = value;
    notifyListeners();
  }

  /// เติมข้อมูลที่อยู่จาก PatientModel (ทะเบียนบ้าน + ปัจจุบัน)
  void populateFromPatient(PatientModel patient) {
    log(
      '📋 Populating provider with patient data:${patient.id} ${patient.patient?.firstName} ${patient.patient?.lastName}',
    );
    _patientId = patient.id;
    final reg = patient.addresses?.registered;
    if (reg != null) {
      _registeredAddressController.text = reg.address ?? '';
      _registeredProvinceCode = reg.provinceCode;
      _registeredDistrictCode = reg.districtCode;
      _registeredSubDistrictCode = reg.subDistrictCode;
    }

    final cur = patient.addresses?.current;
    if (cur != null) {
      _currentAddressController.text = cur.address ?? '';
      _currentProvinceCode = cur.provinceCode;
      _currentDistrictCode = cur.districtCode;
      _currentSubDistrictCode = cur.subDistrictCode;
    }

    notifyListeners();
  } // populateFromPatient (ทะเบียนบ้าน หรือ ปัจจุบัน)

  Future<String> getFullAddressText() async {
    final isRegistered = _selectedAddressType == AddressType.registered;
    final addressText = isRegistered
        ? _registeredAddressController.text.trim()
        : _currentAddressController.text.trim();
    final provinceCode = isRegistered
        ? _registeredProvinceCode
        : _currentProvinceCode;
    final districtCode = isRegistered
        ? _registeredDistrictCode
        : _currentDistrictCode;
    final subDistrictCode = isRegistered
        ? _registeredSubDistrictCode
        : _currentSubDistrictCode;

    final parts = <String>[];
    if (addressText.isNotEmpty) parts.add(addressText);

    if (subDistrictCode != null) {
      final name = await SubDistrictBloc.findSubDistrictNameByCode(
        subDistrictCode,
      );
      if (name != null) parts.add('ตำบล$name');
    }
    if (districtCode != null) {
      final name = await DistrictBloc.findDistrictNameByCode(districtCode);
      if (name != null) parts.add('อำเภอ$name');
    }
    if (provinceCode != null) {
      final name = await ProvinceBloc.findProvinceNameByCode(provinceCode);
      if (name != null) parts.add('จังหวัด$name');
    }
    return parts.join(' ');
  }

  final _pickupLocationController = TextEditingController();
  TextEditingController get pickupLocationController =>
      _pickupLocationController;

  final FocusNode _pickupLocationFocusNode = FocusNode();
  FocusNode get pickupLocationFocusNode => _pickupLocationFocusNode;

  LatLng _currentLocation = const LatLng(13.7563, 100.5018); // กรุงเทพฯ
  LatLng get currentLocation => _currentLocation;

  LatLng? _selectedLocation;
  LatLng? get selectedLocation => _selectedLocation;

  Set<Marker> _registerMarkers = {};
  Set<Marker> get registerMarkers => _registerMarkers;

  GoogleMapController? _googleMapController;
  GoogleMapController? get googleMapController => _googleMapController;

  bool _isEnableTapGoogleMap = true;
  bool get isEnableTapGoogleMap => _isEnableTapGoogleMap;

  bool _isLoadingLocation = false;
  bool get isLoadingLocation => _isLoadingLocation;

  String? _locationError;
  String? get locationError => _locationError;

  void setSelectedLocation(LatLng? value) {
    _selectedLocation = value;
    notifyListeners();
  }

  String? _formattedAddress;
  String? get formattedAddress => _formattedAddress;

  void setFormattedAddress(String? value) {
    _formattedAddress = value;
    notifyListeners();
  }

  String? _pickupPlusCode;
  String? get pickupPlusCode => _pickupPlusCode;

  void setPickupPlusCode(String? value) {
    _pickupPlusCode = value;
    notifyListeners();
  }

  // ---- Map methods ----
  void setMarkers(LatLng newPosition) {
    _registerMarkers = {
      Marker(
        markerId: const MarkerId('pickup_location'),
        position: newPosition,
        infoWindow: InfoWindow(
          title: 'สถานที่รับผู้ป่วย',
          snippet:
              '${newPosition.latitude.toStringAsFixed(6)}, ${newPosition.longitude.toStringAsFixed(6)}',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        draggable: true,
        onDragEnd: onMarkerDragEnd,
      ),
    };
    _getLocationDetailBloc.add(
      GetLocationDetailRequestEvent(
        latitude: newPosition.latitude,
        longitude: newPosition.longitude,
      ),
    );
  }

  void onMapTap(LatLng location) {
    log('🗺️ Map tapped at: ${location.latitude}, ${location.longitude}');
    _selectedLocation = location;
    setMarkers(location);
    _googleMapController?.animateCamera(
      CameraUpdate.newLatLngZoom(location, 15.0),
    );
    notifyListeners();
  }

  void onMarkerDragEnd(LatLng newPosition) {
    _selectedLocation = newPosition;
    setMarkers(newPosition);
    notifyListeners();
  }

  void clearMarkers() {
    _registerMarkers.clear();
    _selectedLocation = null;
    notifyListeners();
  }

  void onMapCreated(GoogleMapController controller) async {
    log('🗺️ Map created!');
    _googleMapController = controller;
    await getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    try {
      _isLoadingLocation = true;
      _locationError = null;
      notifyListeners();

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _locationError = 'กรุณาเปิด Location Service ในการตั้งค่า';
        _isLoadingLocation = false;
        _currentLocation = const LatLng(13.7563, 100.5018);
        notifyListeners();
        return;
      }

      if (kIsWeb) {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        ).timeout(const Duration(seconds: 15));
        _currentLocation = LatLng(position.latitude, position.longitude);
      } else {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            _locationError = 'ไม่ได้รับอนุญาตให้เข้าถึงตำแหน่ง';
            _isLoadingLocation = false;
            _currentLocation = const LatLng(13.7563, 100.5018);
            notifyListeners();
            return;
          }
        }
        if (permission == LocationPermission.deniedForever) {
          _locationError = 'กรุณาเปิดการเข้าถึงตำแหน่งในการตั้งค่า';
          _isLoadingLocation = false;
          _currentLocation = const LatLng(13.7563, 100.5018);
          notifyListeners();
          return;
        }
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          ),
        ).timeout(const Duration(seconds: 15));
        _currentLocation = LatLng(position.latitude, position.longitude);
      }

      _isLoadingLocation = false;
      notifyListeners();

      await Future.delayed(const Duration(milliseconds: 300));
      if (_googleMapController != null) {
        await _googleMapController?.animateCamera(
          CameraUpdate.newLatLngZoom(_currentLocation, 17.0),
        );
        setMarkers(_currentLocation);
        notifyListeners();
      }
    } catch (e) {
      log('❌ Error getting location: $e');
      _locationError = 'ไม่สามารถดึงตำแหน่งได้';
      _currentLocation = const LatLng(13.7563, 100.5018);
      _isLoadingLocation = false;
      notifyListeners();
    }
  }

  // ---- Validate & Submit ----
  bool validate() => _formKey.currentState?.validate() ?? false;

  /// คืนค่า Map payload ของที่อยู่ที่เลือกแก้ไข
  Map<String, dynamic> toPayload() {
    final pickupFields = {
      'pickupAddress': _pickupLocationController.textOrNull,
      'pickupLatitude': _selectedLocation?.latitude.toString(),
      'pickupLongitude': _selectedLocation?.longitude.toString(),
      'currentLocation': _formattedAddress,
      'pickupPlusCode': _pickupPlusCode,
    };

    return {
      'id': _patientId,
      'idCardNumber': _idCardController.text.trim(),
      'addressType': _selectedAddressType.name,
      if (_selectedAddressType == AddressType.registered) ...{
        'address': _registeredAddressController.text.trim(),
        'provinceCode': _registeredProvinceCode,
        'districtCode': _registeredDistrictCode,
        'subDistrictCode': _registeredSubDistrictCode,
        ...pickupFields,
      } else ...{
        'address': _currentAddressController.text.trim(),
        'provinceCode': _currentProvinceCode,
        'districtCode': _currentDistrictCode,
        'subDistrictCode': _currentSubDistrictCode,
        ...pickupFields,
      },
    };
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _idCardController.dispose();
    _registeredAddressController.dispose();
    _currentAddressController.dispose();
    _pickupLocationController.dispose();
    _pickupLocationFocusNode.dispose();
    super.dispose();
  }
}
