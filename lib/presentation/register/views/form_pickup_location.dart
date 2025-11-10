import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';
import 'package:rodzendai_form/core/constants/app_shadow.dart';
import 'package:rodzendai_form/core/constants/app_text_styles.dart';
import 'package:rodzendai_form/core/services/places_service.dart';
import 'package:rodzendai_form/core/services/service_locator.dart';
import 'package:rodzendai_form/presentation/register/blocs/get_latlng_bloc/get_latlng_bloc.dart';
import 'package:rodzendai_form/presentation/register/blocs/places_autocomplete_bloc/places_autocomplete_bloc.dart';
import 'package:rodzendai_form/presentation/register/providers/register_provider.dart';
import 'package:rodzendai_form/presentation/register/widgets/custom_place_autocomplete.dart';
import 'package:rodzendai_form/presentation/register/widgets/google_map_widget.dart';
import 'package:rodzendai_form/presentation/register/widgets/google_place_auto_complete_widget.dart';
import 'package:rodzendai_form/presentation/register_status/blocs/get_location_detail_bloc/get_location_detail_bloc.dart';
import 'package:rodzendai_form/widgets/base_card_container.dart';
import 'package:rodzendai_form/widgets/loading_widget.dart';
import 'package:rodzendai_form/widgets/required_label.dart';

// สถานที่รับผู้ป่วย
class FormPickupLocation extends StatelessWidget {
  const FormPickupLocation({super.key, required this.registerProvider});
  final RegisterProvider registerProvider;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => GetLatLngBloc()),
        BlocProvider(
          create: (context) =>
              PlacesAutocompleteBloc(placesService: locator<PlacesService>()),
        ),
      ],
      child: BlocListener<GetLatLngBloc, GetLatLngState>(
        listener: (context, state) {
          if (state is GetLatLngSuccess) {
            log(
              '✅ GetLatLngSuccess: lat=//${state.latitude}, lng=${state.longitude}',
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
                break;
              case GetLocationDetailFailure():
                break;
            }
          },
          child: Builder(
            builder: (context) {
              final getLatLngBloc = context.read<GetLatLngBloc>();
              // Debug: log provider state whenever this widget rebuilds
              log(
                'FormPickupLocation build: formattedAddress=${registerProvider.formattedAddress}, '
                'selectedLocation=${registerProvider.selectedLocation}, '
                'isLoadingLocation=${registerProvider.isLoadingLocation}, '
                'locationError=${registerProvider.locationError}',
              );
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Checkbox(
                          value: registerProvider.sameAsRegistered,
                          onChanged: (value) {
                            if (value == null) return;
                            registerProvider.setSameAsRegistered(value);
                            getLatLngBloc.add(
                              GetLatLngFromAddressEvent(
                                address: registerProvider
                                    .registerPickupLocationController
                                    .text
                                    .trim(),
                              ),
                            );
                          },
                          activeColor: AppColors.primary,
                          checkColor: AppColors.white,
                          side: BorderSide(
                            color: AppColors.textLighter,
                            width: 2,
                          ),
                        ),
                        Text(
                          'ใช้ข้อมูลผู้แจ้ง/ผู้ติดต่อ',
                          style: AppTextStyles.regular,
                        ),
                      ],
                    ),
                    CustomPlaceAutocomplete(
                      controller:
                          registerProvider.registerPickupLocationController,
                      focusNode: registerProvider.pickupLocationFocusNode,
                      onSelected: (prediction) {
                        log('📍 Selected place: ');

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

                    // GooglePlaceAutoCompleteWidget(
                    //   controller:
                    //       registerProvider.registerPickupLocationController,
                    //   focusNode: registerProvider.pickupLocationFocusNode,
                    //   latitude: registerProvider.currentLocation.latitude,
                    //   longitude: registerProvider.currentLocation.longitude,
                    //   itemClick: (prediction) async {
                    //     log('📍 Selected place: ${prediction.toJson()}');

                    //     if (prediction.description != null) {
                    //       registerProvider.setFormattedAddress(
                    //         prediction.description ?? '',
                    //       );
                    //       registerProvider
                    //               .registerPickupLocationController
                    //               .text =
                    //           prediction.description ?? '';
                    //     }

                    //     // ยกเลิก focus หลังจากเลือกสถานที่
                    //     registerProvider.pickupLocationFocusNode.unfocus();

                    //     // ใช้ Bloc แทน direct service call
                    //     if (prediction.placeId != null &&
                    //         prediction.placeId!.isNotEmpty) {
                    //       getLatLngBloc.add(
                    //         GetLatLngFromPlaceIdEvent(
                    //           placeId: prediction.placeId!,
                    //         ),
                    //       );
                    //     }
                    //   },
                    //   formSubmitCallback: () {
                    //     log('Form Submitted');
                    //   },
                    // ),
                    GoogleMapWidget(),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
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
                                return LoadingWidget();
                              }
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 8,
                                children: [
                                  Text(
                                    'ที่อยู่ปัจจุบัน: ',
                                    style: AppTextStyles.regular.copyWith(
                                      color: AppColors.success,
                                    ),
                                  ),
                                  Text(
                                    registerProvider.formattedAddress ??
                                        'ไม่มีข้อมูล',
                                    style: AppTextStyles.regular.copyWith(
                                      fontSize: 14,
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
      ),
    );
  }
}
