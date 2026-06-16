import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';
import 'package:rodzendai_form/core/constants/app_shadow.dart';
import 'package:rodzendai_form/core/constants/app_text_styles.dart';
import 'package:rodzendai_form/presentation/register/blocs/get_latlng_bloc/get_latlng_bloc.dart';
import 'package:rodzendai_form/presentation/register_status/blocs/get_location_detail_bloc/get_location_detail_bloc.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/providers/register_to_claim_your_rights_provider.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/widgets/pick_location_dialog.dart';
import 'package:rodzendai_form/widgets/base_card_container.dart';
import 'package:rodzendai_form/widgets/loading_widget.dart';
import 'package:rodzendai_form/widgets/required_label.dart';

// สถานที่รับผู้ป่วย
class FormPickupLocationV2 extends StatelessWidget {
  const FormPickupLocationV2({super.key, required this.registerProvider});
  final RegisterToClaimYourRightsProvider registerProvider;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetLatLngBloc(),
      child: BlocListener<GetLatLngBloc, GetLatLngState>(
        listener: (context, state) {
          if (state is GetLatLngSuccess) {
            log(
              '✅ GetLatLngSuccess: lat=${state.latitude}, lng=${state.longitude}',
            );
            final location = LatLng(state.latitude, state.longitude);
            registerProvider.onMapTap(location);
          } else if (state is GetLatLngFailure) {
            log('❌ GetLatLngFailure: ${state.message}');
          }
        },
        child: BlocListener<GetLocationDetailBloc, GetLocationDetailState>(
          listener: (context, state) async {
            switch (state) {
              case GetLocationDetailInitial():
                break;
              case GetLocationDetailLoading():
                break;
              case GetLocationDetailSuccess():
                registerProvider.setFormattedAddress(
                  state.addressDetail.formattedAddress,
                );
                registerProvider.setPickupPlusCode(
                  state.addressDetail.plusCode,
                );
                break;
              case GetLocationDetailFailure():
                break;
            }
          },
          child: Builder(
            builder: (context) {
              final getLatLngBloc = context.read<GetLatLngBloc>();
              return BaseCardContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 16,
                  children: [
                    RequiredLabel(
                      text: 'สถานที่รับผู้ป่วย',
                      isRequired: true,
                      textStyle: AppTextStyles.bold.copyWith(
                        color: AppColors.primary,
                        fontSize: 24,
                      ),
                    ),
                    Divider(
                      color: AppColors.secondary.withOpacity(0.16),
                      thickness: 1,
                    ),
                    Selector<
                      RegisterToClaimYourRightsProvider,
                      PickupLocationSource?
                    >(
                      selector: (context, provider) =>
                          provider.pickupLocationSource,
                      builder: (context, source, child) =>
                          RadioGroup<PickupLocationSource>(
                            groupValue: source,
                            onChanged: (value) async {
                              if (value == null) return;
                              await registerProvider.setPickupLocationSource(
                                value,
                              );
                              if (value ==
                                  PickupLocationSource.currentAddress) {
                                getLatLngBloc.add(
                                  GetLatLngFromAddressEvent(
                                    address: await registerProvider
                                        .getCurrentAddressFullText(),
                                  ),
                                );
                              } else if (value ==
                                  PickupLocationSource.currentPosition) {
                                if (!context.mounted) return;
                                await PickLocationDialog.show(
                                  context,
                                  registerProvider: registerProvider,
                                );
                              }
                            },
                            child: Wrap(
                              alignment: WrapAlignment.end,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                const Radio<PickupLocationSource>(
                                  value: PickupLocationSource.currentAddress,
                                  activeColor: AppColors.primary,
                                ),
                                Text(
                                  'ใช้ข้อมูลที่อยู่ปัจจุบัน',
                                  style: AppTextStyles.regular,
                                ),
                                const SizedBox(width: 16),
                                const Radio<PickupLocationSource>(
                                  value: PickupLocationSource.currentPosition,
                                  activeColor: AppColors.primary,
                                ),
                                Text(
                                  'จุดที่ยืนอยู่',
                                  style: AppTextStyles.regular,
                                ),
                              ],
                            ),
                          ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => PickLocationDialog.show(
                          context,
                          registerProvider: registerProvider,
                        ),
                        icon: const Icon(Icons.place_outlined),
                        label: Text(
                          'ปักหมุดบนแผนที่',
                          style: AppTextStyles.bold.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    Selector<RegisterToClaimYourRightsProvider, LatLng?>(
                      selector: (_, provider) => provider.selectedLocation,
                      builder: (context, selectedLocation, _) {
                        if (selectedLocation == null) {
                          return const SizedBox.shrink();
                        }
                        return _PickedLocationPreview(
                          location: selectedLocation,
                        );
                      },
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.bgColor,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: AppShadow.primaryShadow,
                      ),
                      child:
                          BlocBuilder<
                            GetLocationDetailBloc,
                            GetLocationDetailState
                          >(
                            builder: (context, state) {
                              if (state is GetLocationDetailLoading) {
                                return const LoadingWidget();
                              }
                              return Consumer<
                                RegisterToClaimYourRightsProvider
                              >(
                                builder: (context, provider, _) {
                                  final hasPin =
                                      provider.selectedLocation != null;
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    spacing: 8,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            hasPin
                                                ? Icons.check_circle
                                                : Icons.info_outline,
                                            size: 18,
                                            color: hasPin
                                                ? AppColors.success
                                                : AppColors.textLight,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            hasPin
                                                ? 'ที่อยู่ที่เลือก'
                                                : 'ยังไม่ได้เลือกตำแหน่ง',
                                            style: AppTextStyles.regular
                                                .copyWith(
                                                  color: hasPin
                                                      ? AppColors.success
                                                      : AppColors.textLight,
                                                ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        provider.formattedAddress?.isNotEmpty ==
                                                true
                                            ? provider.formattedAddress!
                                            : 'กดปุ่ม "ปักหมุดบนแผนที่" เพื่อเลือกตำแหน่งรับผู้ป่วย',
                                        style: AppTextStyles.regular.copyWith(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PickedLocationPreview extends StatefulWidget {
  const _PickedLocationPreview({required this.location});

  final LatLng location;

  @override
  State<_PickedLocationPreview> createState() => _PickedLocationPreviewState();
}

class _PickedLocationPreviewState extends State<_PickedLocationPreview> {
  GoogleMapController? _previewController;

  @override
  void didUpdateWidget(covariant _PickedLocationPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.location != widget.location) {
      _moveCameraTo(widget.location);
    }
  }

  Future<void> _moveCameraTo(LatLng target) async {
    final controller = _previewController;
    if (controller == null) return;
    try {
      await controller.animateCamera(CameraUpdate.newLatLngZoom(target, 16.0));
    } catch (_) {
      _previewController = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 200,
        width: double.infinity,
        child: GoogleMap(
          onMapCreated: (controller) {
            _previewController = controller;
          },
          initialCameraPosition: CameraPosition(
            target: widget.location,
            zoom: 16.0,
          ),
          markers: {
            Marker(
              markerId: const MarkerId('picked_location_preview'),
              position: widget.location,
            ),
          },
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          liteModeEnabled: true,
          scrollGesturesEnabled: false,
          zoomGesturesEnabled: false,
          rotateGesturesEnabled: false,
          tiltGesturesEnabled: false,
        ),
      ),
    );
  }
}
