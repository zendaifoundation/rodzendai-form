import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';
import 'package:rodzendai_form/core/constants/app_shadow.dart';
import 'package:rodzendai_form/core/constants/app_text_styles.dart';
import 'package:rodzendai_form/presentation/edit_address/providers/edit_address_provider.dart';
import 'package:rodzendai_form/presentation/edit_address/widgets/google_map_widget.dart';
import 'package:rodzendai_form/presentation/register/blocs/get_latlng_bloc/get_latlng_bloc.dart';
import 'package:rodzendai_form/presentation/register/widgets/custom_place_autocomplete.dart';
import 'package:rodzendai_form/presentation/register_status/blocs/get_location_detail_bloc/get_location_detail_bloc.dart';
import 'package:rodzendai_form/widgets/base_card_container.dart';
import 'package:rodzendai_form/widgets/loading_widget.dart';
import 'package:rodzendai_form/widgets/required_label.dart';

class FormPickupLocationEditAddress extends StatelessWidget {
  const FormPickupLocationEditAddress({super.key});

  @override
  Widget build(BuildContext context) {
    final editProvider = context.read<EditAddressProvider>();

    return BlocListener<GetLatLngBloc, GetLatLngState>(
      listener: (context, state) {
        if (state is GetLatLngSuccess) {
          log(
            '✅ GetLatLngSuccess: lat=${state.latitude}, lng=${state.longitude}',
          );
          editProvider.onMapTap(LatLng(state.latitude, state.longitude));
        } else if (state is GetLatLngFailure) {
          log('❌ GetLatLngFailure: ${state.message}');
        }
      },
      child: BlocListener<GetLocationDetailBloc, GetLocationDetailState>(
        listener: (context, state) {
          if (state is GetLocationDetailSuccess) {
            editProvider.setFormattedAddress(
              state.addressDetail.formattedAddress,
            );
            editProvider.setPickupPlusCode(state.addressDetail.plusCode);
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
                  CustomPlaceAutocomplete(
                    controller: editProvider.pickupLocationController,
                    focusNode: editProvider.pickupLocationFocusNode,
                    onSelected: (prediction) {
                      log('📍 Selected place: $prediction');

                      final description = prediction['description'];
                      if (description != null) {
                        editProvider.setFormattedAddress(description);
                        editProvider.pickupLocationController.text =
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
                  const EditAddressGoogleMapWidget(),
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
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 8,
                              children: [
                                Text(
                                  'ที่อยู่ที่เลือก: ',
                                  style: AppTextStyles.regular.copyWith(
                                    color: AppColors.success,
                                  ),
                                ),
                                Consumer<EditAddressProvider>(
                                  builder: (context, p, _) => Text(
                                    p.formattedAddress ?? 'ไม่มีข้อมูล',
                                    style: AppTextStyles.regular.copyWith(
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
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
    );
  }
}
