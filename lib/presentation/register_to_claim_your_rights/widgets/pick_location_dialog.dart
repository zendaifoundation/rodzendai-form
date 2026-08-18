import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';
import 'package:rodzendai_form/core/constants/app_text_styles.dart';
import 'package:rodzendai_form/core/services/places_service.dart';
import 'package:rodzendai_form/core/services/service_locator.dart';
import 'package:rodzendai_form/presentation/register/blocs/get_latlng_bloc/get_latlng_bloc.dart';
import 'package:rodzendai_form/presentation/register/blocs/places_autocomplete_bloc/places_autocomplete_bloc.dart';
import 'package:rodzendai_form/presentation/register/widgets/custom_place_autocomplete.dart';
import 'package:rodzendai_form/presentation/register_status/blocs/get_location_detail_bloc/get_location_detail_bloc.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/providers/register_to_claim_your_rights_provider.dart';

class PickLocationDialog extends StatefulWidget {
  const PickLocationDialog({super.key, required this.registerProvider});

  final RegisterToClaimYourRightsProvider registerProvider;

  static Future<void> show(
    BuildContext context, {
    required RegisterToClaimYourRightsProvider registerProvider,
  }) {
    final locationDetailBloc = context.read<GetLocationDetailBloc>();
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => MultiProvider(
        providers: [
          ChangeNotifierProvider<RegisterToClaimYourRightsProvider>.value(
            value: registerProvider,
          ),
          BlocProvider<GetLocationDetailBloc>.value(value: locationDetailBloc),
        ],
        child: PickLocationDialog(registerProvider: registerProvider),
      ),
    );
  }

  @override
  State<PickLocationDialog> createState() => _PickLocationDialogState();
}

class _PickLocationDialogState extends State<PickLocationDialog> {
  late final LatLng? initialLocation;
  late final String? initialAddress;
  late final String initialPickupText;
  PlacesAutocompleteBloc? _placesBloc;

  RegisterToClaimYourRightsProvider get registerProvider =>
      widget.registerProvider;

  @override
  void initState() {
    super.initState();
    initialLocation = registerProvider.selectedLocation;
    initialAddress = registerProvider.formattedAddress;
    initialPickupText = registerProvider.registerPickupLocationController.text;
    // เคลียร์ text ในช่องค้นหาเมื่อเปิด dialog เพื่อให้ผู้ใช้พิมพ์ค้นหาใหม่ได้
    // ถ้าผู้ใช้กดยกเลิก จะ revert กลับเป็น initialPickupText
    registerProvider.registerPickupLocationController.clear();
    registerProvider.registerPickupLocationController.addListener(
      _onPickupTextChanged,
    );
  }

  @override
  void dispose() {
    registerProvider.registerPickupLocationController.removeListener(
      _onPickupTextChanged,
    );
    super.dispose();
  }

  /// ตรวจสอบว่า text ที่กรอกเป็นพิกัด lat,lng หรือไม่
  /// รับรูปแบบ "13.79689, 100.56053" หรือ "13.79689,100.56053"
  LatLng? _tryParseLatLng(String text) {
    final parts = text.split(',');
    if (parts.length != 2) return null;
    final lat = double.tryParse(parts[0].trim());
    final lng = double.tryParse(parts[1].trim());
    if (lat == null || lng == null) return null;
    if (lat < -90 || lat > 90 || lng < -180 || lng > 180) return null;
    return LatLng(lat, lng);
  }

  void _onPickupTextChanged() {
    final text = registerProvider.registerPickupLocationController.text;
    final latLng = _tryParseLatLng(text);
    if (latLng == null) return;
    // เป็นพิกัด → ปักหมุดทันที และยกเลิกการค้นหา places
    registerProvider.onMapTap(latLng);
    registerProvider.pickupLocationFocusNode.unfocus();
    _placesBloc?.add(const ClearPlacesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => GetLatLngBloc()),
        BlocProvider(
          create: (_) =>
              PlacesAutocompleteBloc(placesService: locator<PlacesService>()),
        ),
      ],
      child: BlocListener<GetLatLngBloc, GetLatLngState>(
        listener: (context, state) {
          if (state is GetLatLngSuccess) {
            registerProvider.onMapTap(LatLng(state.latitude, state.longitude));
          } else if (state is GetLatLngFailure) {
            log('❌ GetLatLngFailure: ${state.message}');
          }
        },
        child: BlocListener<GetLocationDetailBloc, GetLocationDetailState>(
          listener: (context, state) {
            if (state is GetLocationDetailSuccess) {
              registerProvider.setFormattedAddress(
                state.addressDetail.formattedAddress,
              );
              registerProvider.setPickupPlusCode(state.addressDetail.plusCode);
            }
          },
          child: Builder(
            builder: (context) {
              final getLatLngBloc = context.read<GetLatLngBloc>();
              _placesBloc = context.read<PlacesAutocompleteBloc>();
              final media = MediaQuery.of(context);

              return Dialog(
                insetPadding: EdgeInsets.symmetric(
                  horizontal: media.size.width > 720 ? 48 : 12,
                  vertical: 24,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 720,
                    maxHeight: media.size.height * 0.92,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Header(
                        onClose: () {
                          _revert(
                            location: initialLocation,
                            address: initialAddress,
                            pickupText: initialPickupText,
                          );
                          Navigator.of(context).pop();
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        child: CustomPlaceAutocomplete(
                          controller:
                              registerProvider.registerPickupLocationController,
                          focusNode: registerProvider.pickupLocationFocusNode,
                          onSelected: (prediction) {
                            final description = prediction['description'];
                            if (description != null) {
                              registerProvider.setFormattedAddress(description);
                              registerProvider
                                      .registerPickupLocationController
                                      .text =
                                  description;
                            }
                            final placeId = prediction['place_id'];
                            if (placeId != null) {
                              getLatLngBloc.add(
                                GetLatLngFromPlaceIdEvent(placeId: placeId),
                              );
                            }
                          },
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Consumer<RegisterToClaimYourRightsProvider>(
                              builder: (context, provider, _) {
                                return GoogleMap(
                                  onMapCreated: provider.onMapCreated,
                                  initialCameraPosition: CameraPosition(
                                    target:
                                        provider.selectedLocation ??
                                        provider.currentLocation,
                                    zoom: 15.0,
                                  ),
                                  markers: provider.registerMarkers,
                                  onTap: (location) {
                                    provider.onMapTap(location);
                                    provider
                                            .registerPickupLocationController
                                            .text =
                                        '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}';
                                    // ปิด overlay ค้นหา places ที่อาจค้างอยู่
                                    provider.pickupLocationFocusNode.unfocus();
                                    context.read<PlacesAutocompleteBloc>().add(
                                      const ClearPlacesEvent(),
                                    );
                                  },
                                  myLocationEnabled: true,
                                  myLocationButtonEnabled: true,
                                  zoomControlsEnabled: true,
                                  mapToolbarEnabled: false,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      _AddressPreview(),
                      _Footer(
                        onCancel: () {
                          _revert(
                            location: initialLocation,
                            address: initialAddress,
                            pickupText: initialPickupText,
                          );
                          registerProvider.clearMapController();
                          Navigator.of(context).pop();
                        },
                        onConfirm: () {
                          registerProvider.clearMapController();
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _revert({
    required LatLng? location,
    required String? address,
    required String pickupText,
  }) {
    if (location == null) {
      registerProvider.clearMarkers();
    } else {
      registerProvider.onMapTap(location);
    }
    registerProvider.setFormattedAddress(address ?? '');
    registerProvider.registerPickupLocationController.text = pickupText;
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onClose});
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.06),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Icon(Icons.location_on, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'ปักหมุดสถานที่รับผู้ป่วย',
              style: AppTextStyles.bold.copyWith(
                color: AppColors.primary,
                fontSize: 18,
              ),
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close),
            tooltip: 'ปิด',
          ),
        ],
      ),
    );
  }
}

class _AddressPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: BlocBuilder<GetLocationDetailBloc, GetLocationDetailState>(
          builder: (context, state) {
            final isLoading = state is GetLocationDetailLoading;
            return Consumer<RegisterToClaimYourRightsProvider>(
              builder: (context, provider, _) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.place_outlined,
                      color: AppColors.success,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ที่อยู่ที่เลือก',
                            style: AppTextStyles.regular.copyWith(
                              color: AppColors.success,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isLoading
                                ? 'กำลังโหลด...'
                                : (provider.formattedAddress?.isNotEmpty == true
                                      ? provider.formattedAddress!
                                      : 'แตะบนแผนที่หรือค้นหาเพื่อเลือกตำแหน่ง'),
                            style: AppTextStyles.regular.copyWith(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.onCancel, required this.onConfirm});
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onCancel,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                side: BorderSide(color: AppColors.textLighter),
              ),
              child: Text(
                'ยกเลิก',
                style: AppTextStyles.regular.copyWith(color: AppColors.text),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Consumer<RegisterToClaimYourRightsProvider>(
              builder: (context, provider, _) {
                final canConfirm = provider.selectedLocation != null;
                return ElevatedButton(
                  onPressed: canConfirm ? onConfirm : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'ยืนยันตำแหน่ง',
                    style: AppTextStyles.bold.copyWith(color: Colors.white),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
