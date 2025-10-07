import 'package:flutter/material.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';
import 'package:rodzendai_form/core/constants/app_text_styles.dart';
import 'package:rodzendai_form/core/utils/env_helper.dart';

class GooglePlaceAutoCompleteWidget extends StatelessWidget {
  const GooglePlaceAutoCompleteWidget({
    super.key,
    this.getPlaceDetailWithLatLng,
    this.itemClick,
    required this.controller,
  });

  final void Function(Prediction)? getPlaceDetailWithLatLng;
  final void Function(Prediction)? itemClick;
  final TextEditingController controller;
  @override
  Widget build(BuildContext context) {
    return GooglePlaceAutoCompleteTextField(
      textEditingController: controller,
      googleAPIKey: EnvHelper.googleAPIKey,
      boxDecoration: BoxDecoration(),
      inputDecoration: InputDecoration(
        hintText: 'ค้นหาสถานที่...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary, width: 1),
        ),
        hintStyle: AppTextStyles.regular.copyWith(color: AppColors.textLighter),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.textLighter, width: 1),
        ),
      ),
      debounceTime: 500,
      countries: ["th"],
      isLatLngRequired: true,
      getPlaceDetailWithLatLng: getPlaceDetailWithLatLng,
      itemClick: itemClick,
      itemBuilder: (context, index, prediction) {
        return Container(
          color: AppColors.white,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            spacing: 8,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on, color: AppColors.primary),
              Expanded(
                child: Text(
                  prediction.description ?? '',
                  style: AppTextStyles.regular,
                ),
              ),
            ],
          ),
        );
      },
      seperatedBuilder: Divider(
        height: 1,
        color: AppColors.secondary.withOpacity(0.16),
      ),
      showError: false,
    );
  }
}
