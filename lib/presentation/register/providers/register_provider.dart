import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RegisterProvider extends ChangeNotifier {
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

  void onRequestRegister() {
    //todo
  }

  void onMapCreated(GoogleMapController controller) {
    _googleMapController = controller;
  }

  /// ปักหมุดใหม่เมื่อแตะที่แผนที่
  void onMapTap(LatLng location) {
    log('🗺️ Map tapped at: ${location.latitude}, ${location.longitude}');

    // เก็บตำแหน่งที่เลือก
    _selectedLocation = location;

    // ลบหมุดเก่าและสร้างหมุดใหม่
    _registerMarkers = {
      Marker(
        markerId: MarkerId('pickup_location'),
        position: location,
        infoWindow: InfoWindow(
          snippet:
              '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        draggable: true,
        onDragEnd: (newPosition) {
          onMarkerDragEnd(newPosition);
        },
      ),
    };

    log('📍 Marker created at: ${location.latitude}, ${location.longitude}');
    log('📍 Total markers: ${_registerMarkers.length}');

    // เลื่อนกล้องไปที่ตำแหน่งใหม่
    _googleMapController?.animateCamera(
      CameraUpdate.newLatLngZoom(location, 17.0),
    );

    // // แสดง InfoWindow
    // Future.delayed(Duration(milliseconds: 200), () {
    //   _googleMapController?.showMarkerInfoWindow(MarkerId('pickup_location'));
    // });

    log('🔔 Notifying listeners...');
    notifyListeners();
  }

  /// เมื่อลากหมุดเสร็จ
  void onMarkerDragEnd(LatLng newPosition) {
    log('Marker dragged to: ${newPosition.latitude}, ${newPosition.longitude}');
    _selectedLocation = newPosition;

    // อัพเดทตำแหน่งหมุด
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

    notifyListeners();
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

  @override
  void dispose() {
    _registerPickupLocationController.dispose();
    _googleMapController?.dispose();
    super.dispose();
  }
}
