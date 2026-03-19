import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';
import 'package:rodzendai_form/presentation/edit_address/providers/edit_address_provider.dart';

class EditAddressGoogleMapWidget extends StatelessWidget {
  const EditAddressGoogleMapWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EditAddressProvider>(
      builder: (context, provider, child) {
        return AspectRatio(
          aspectRatio: 4 / 3,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.bgColor),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: GoogleMap(
                onMapCreated: provider.onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: provider.currentLocation,
                  zoom: 15.0,
                ),
                markers: provider.registerMarkers,
                onTap: provider.isEnableTapGoogleMap ? provider.onMapTap : null,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: true,
                mapToolbarEnabled: false,
              ),
            ),
          ),
        );
      },
    );
  }
}
