import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';
import 'package:rodzendai_form/core/constants/app_shadow.dart';
import 'package:rodzendai_form/core/constants/app_text_styles.dart';
import 'package:rodzendai_form/core/services/geocoding_service.dart';
import 'package:rodzendai_form/presentation/register/providers/register_provider.dart';
import 'package:rodzendai_form/presentation/register/widgets/google_map_widget.dart';
import 'package:rodzendai_form/presentation/register/widgets/google_place_auto_complete_widget.dart';
import 'package:rodzendai_form/presentation/register_status/blocs/get_location_detail_bloc/get_location_detail_bloc.dart';
import 'package:rodzendai_form/widgets/base_card_container.dart';
import 'package:rodzendai_form/widgets/dialog/loading_dialog.dart';
import 'package:rodzendai_form/widgets/loading_widget.dart';
import 'package:rodzendai_form/widgets/required_label.dart';

// สถานที่รับผู้ป่วย
class FormPickupLocation extends StatelessWidget {
  const FormPickupLocation({super.key, required this.registerProvider});
  final RegisterProvider registerProvider;

  @override
  Widget build(BuildContext context) {
    return BlocListener<GetLocationDetailBloc, GetLocationDetailState>(
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
      child: BaseCardContainer(
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
            Divider(color: AppColors.secondary.withOpacity(0.16), thickness: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Checkbox(
                  value: registerProvider.sameAsRegistered,
                  onChanged: (value) {
                    if (value == null) return;
                    registerProvider.setSameAsRegistered(value);
                  },
                  activeColor: AppColors.primary,
                  checkColor: AppColors.white,
                  side: BorderSide(color: AppColors.textLighter, width: 2),
                ),
                Text(
                  'ใช้ข้อมูลผู้แจ้ง/ผู้ติดต่อ',
                  style: AppTextStyles.regular,
                ),
              ],
            ),

            GooglePlaceAutoCompleteWidget(
              controller: registerProvider.registerPickupLocationController,
              focusNode: registerProvider.pickupLocationFocusNode,
              latitude: registerProvider.currentLocation.latitude,
              longitude: registerProvider.currentLocation.longitude,
              itemClick: (prediction) async {
                log('📍 Selected place: ${prediction.toJson()}');

                // // เมื่อเลือกสถานที่
                // final lat = double.tryParse(prediction.lat ?? '0');
                // final lng = double.tryParse(prediction.lng ?? '0');

                // if (lat != null && lng != null) {
                //   final location = LatLng(lat, lng);

                //   // อัพเดทตำแหน่งบนแผนที่
                //   registerProvider.onMapTap(location);

                //   // ตั้งค่าที่อยู่
                if (prediction.description != null) {
                  registerProvider.setFormattedAddress(
                    prediction.description ?? '',
                  );
                  registerProvider.registerPickupLocationController.text =
                      prediction.description ?? '';
                }
                //}

                // ยกเลิก focus หลังจากเลือกสถานที่
                registerProvider.pickupLocationFocusNode.unfocus();
                LoadingDialog.show(context);
                try {
                  final result = await GeocodingService().getLatLngFromPlaceId(
                    prediction.placeId ?? '',
                  );
                  LoadingDialog.hide(context);
                  log('📍 Fetched lat/lng: $result');
                  if (result != null) {
                    final location = LatLng(result['lat']!, result['lng']!);
                    // อัพเดทตำแหน่งบนแผนที่
                    registerProvider.onMapTap(location);
                  } else {
                    log(
                      '📍 Warning: No lat/lng found for place ID ${prediction.placeId}',
                    );
                  }
                } catch (e) {
                  log('📍 Error fetching lat/lng: $e');
                  LoadingDialog.hide(context);
                }
              },
              formSubmitCallback: () {
                log('Form Submitted');
              },
            ),

            GoogleMapWidget(),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bgColor,
                borderRadius: BorderRadius.circular(8),
                boxShadow: AppShadow.primaryShadow,
              ),
              child: BlocBuilder<GetLocationDetailBloc, GetLocationDetailState>(
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
                        registerProvider.formattedAddress ?? 'ไม่มีข้อมูล',
                        style: AppTextStyles.regular.copyWith(fontSize: 14),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
