import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RegisterProvider extends ChangeNotifier {
  TextEditingController _registerPickupLocationController =
      TextEditingController();
  TextEditingController get registerPickupLocationController =>
      _registerPickupLocationController;

  GoogleMapController? _googleMapController;
  GoogleMapController? get googleMapController => _googleMapController;

  void onRequestRegister() {
    //todo
  }

  void onMapCreated(GoogleMapController controller) {
    _googleMapController = controller;
  }
}
