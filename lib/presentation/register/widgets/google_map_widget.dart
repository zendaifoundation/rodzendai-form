import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';
import 'package:rodzendai_form/presentation/register/providers/register_provider.dart';

class GoogleMapWidget extends StatelessWidget {
  const GoogleMapWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RegisterProvider>(
      builder: (context, registerProvider, child) {
        return Container(
          height: 400,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.bgColor),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: GoogleMap(
              onMapCreated: registerProvider.onMapCreated,
              initialCameraPosition: CameraPosition(
                target: registerProvider.currentLocation,
                zoom: 15.0,
              ),
              markers: registerProvider.registerMarkers,
              onTap: (location) {
                registerProvider.onMapTap(location);
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: true,
              mapToolbarEnabled: false,
            ),
          ),
        );
      },
    );
  }
}
