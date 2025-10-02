import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rodzendai_form/presentation/register/providers/register_provider.dart';

class GoogleMapWidget extends StatelessWidget {
  const GoogleMapWidget({super.key, required this.registerProvider});
  final RegisterProvider registerProvider;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400, // ความสูงมาตรฐานสำหรับแผนที่ในฟอร์ม
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      clipBehavior: Clip.antiAlias,
      child: GoogleMap(
        onMapCreated: registerProvider.onMapCreated,
        initialCameraPosition: const CameraPosition(
          target: LatLng(13.7563, 100.5018), // กรุงเทพฯ
          zoom: 15.0,
        ),
        markers: {
          // เพิ่ม markers ที่นี่
        },
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        zoomControlsEnabled: true,
        mapToolbarEnabled: false,
      ),
    );
  }
}
