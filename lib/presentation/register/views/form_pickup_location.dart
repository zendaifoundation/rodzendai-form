import 'package:flutter/material.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';
import 'package:rodzendai_form/core/constants/app_shadow.dart';
import 'package:rodzendai_form/core/constants/app_text_styles.dart';
import 'package:rodzendai_form/core/utils/env_helper.dart';
import 'package:rodzendai_form/presentation/register/providers/register_provider.dart';
import 'package:rodzendai_form/presentation/register/widgets/form_header.dart';
import 'package:rodzendai_form/presentation/register/widgets/google_map_widget.dart';
import 'package:rodzendai_form/widgets/base_card_container.dart';

// สถานที่รับผู้ป่วย
class FormPickupLocation extends StatelessWidget {
  const FormPickupLocation({super.key, required this.registerProvider});
  final RegisterProvider registerProvider;

  @override
  Widget build(BuildContext context) {
    return BaseCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,

        children: [
          FormHeaderWidget(title: 'สถานที่รับผู้ป่วย'),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Checkbox(
                value: false,
                onChanged: (value) {
                  //todo
                },
              ),
              Text('ใช้ที่อยู่ตามทะเบียนบ้าน'),
            ],
          ),

          //TextFormFielddCustom(hintText: 'ค้นหาสถานที่...'),
          GooglePlaceAutoCompleteTextField(
            textEditingController:
                registerProvider.registerPickupLocationController,
            googleAPIKey: EnvHelper.googleAPIKey,
            textStyle: AppTextStyles.regular,
            radius: 16,
            boxDecoration: BoxDecoration(),
            countries: ['th'],
            itemClick: (postalCodeResponse) async {
              //todo
            },
            itemBuilder: (context, index, prediction) {
              return Column(
                children: [
                  Container(
                    color: AppColors.white,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          spacing: 4,
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

                        Divider(
                          color: AppColors.secondary.withOpacity(0.16),
                          thickness: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
            inputDecoration: InputDecoration(
              labelText: 'ค้นหาสถานที่...',
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),

            showError: true,
          ),
          GoogleMapWidget(registerProvider: registerProvider),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgColor,
              borderRadius: BorderRadius.circular(8),
              boxShadow: AppShadow.primaryShadow,
            ),
            child: Column(
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
                  '451 ส้นทรายน้อย ซอย 4 Tambon San Sai Noi, Amphoe San Sai, Chang Wat Chiang Mai 50210, Thailand',
                  style: AppTextStyles.regular.copyWith(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
