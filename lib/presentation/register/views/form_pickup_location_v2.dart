import 'package:flutter/material.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';
import 'package:rodzendai_form/core/constants/app_shadow.dart';
import 'package:rodzendai_form/core/constants/app_text_styles.dart';
import 'package:rodzendai_form/core/utils/validators.dart';
import 'package:rodzendai_form/models/interfaces/service_type.dart';
import 'package:rodzendai_form/presentation/register/providers/register_provider.dart';
import 'package:rodzendai_form/presentation/register/widgets/form_header.dart';
import 'package:rodzendai_form/presentation/widgets/district_dropdown.dart';
import 'package:rodzendai_form/presentation/widgets/province_dropdown.dart';
import 'package:rodzendai_form/presentation/widgets/sub_district_dropdown.dart';
import 'package:rodzendai_form/widgets/base_card_container.dart';
import 'package:rodzendai_form/widgets/text_form_field_custom.dart';

// สถานที่รับผู้ป่วย
class FormPickupLocationV2 extends StatelessWidget {
  const FormPickupLocationV2({super.key, required this.registerProvider});
  final RegisterProvider registerProvider;

  @override
  Widget build(BuildContext context) {
    if (registerProvider.serviceTypeSelected == null) {
      return SizedBox.shrink();
    }

    return switch (registerProvider.serviceTypeSelected) {
      ServiceType.outbound => _buildOutbound(), //ขาไป
      ServiceType.inbound => _buildInbound(), //ขากลับ
      ServiceType.roundTrip => _buildRoundTrip(), //ขาไป-ขากลับ'
      null => SizedBox(),
    };
  }

  Widget _buildOutbound() {
    return BaseCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          FormHeaderWidget(title: 'รายละเอียดการเดินทาง (ขาไป)'),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                // สำหรับหน้าจอขนาดเล็ก (มือถือ)
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 16,
                  children: [buildFormPickup(), buildFormDropoff()],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 16,
                children: [
                  Expanded(child: buildFormPickup()),
                  Expanded(child: buildFormDropoff()),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Container buildFormPickup() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgHeaderCard,
        borderRadius: BorderRadius.circular(8),
        boxShadow: AppShadow.primaryShadow,
      ),
      child: Column(
        spacing: 16,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormHeaderWidget(
            title: 'จุดรับผู้ป่วย',
            titleTextStyle: AppTextStyles.bold.copyWith(fontSize: 18),
            subTitle: 'ใช้ที่อยู่เดียวกับที่อยู่ปัจจุบัน',
            value: registerProvider.outboundPickupSameAsCurrent,
            onChanged: (bool? value) {
              if (value == null) return;
              registerProvider.setOutboundPickupSameAsCurrent(value);
            },
          ),
          TextFormFielddCustom(
            controller: registerProvider.outboundPickupLocationController,
            label: 'สถานที่รับผู้ป่วย',
            hintText: 'สถานที่ บ้านเลขที่ หมู่ที่ หมู่บ้าน อาคาร ซอย ถนน',
            maxLines: 3,
            validator: Validators.required('กรุณากรอกสถานที่รับผู้ป่วย'),
          ),
          ProvinceDropdown(
            label: 'จังหวัด',
            selectedProvinceCode: registerProvider.outboundPickupProvinceCode,
            onProvinceChanged: (value) {
              registerProvider.setOutboundPickupProvinceCode(value);
            },
            validator: Validators.required('กรุณาเลือกจังหวัด'),
          ),
          DistrictDropdown(
            label: 'อำเภอ/เขต',
            provinceCode: registerProvider.outboundPickupProvinceCode,
            selectedDistrictCode: registerProvider.outboundPickupDistrictCode,
            onDistrictChanged: (value) {
              registerProvider.setOutboundPickupDistrictCode(value);
            },
            validator: Validators.required('กรุณาเลือกอำเภอ/เขต'),
          ),
          SubDistrictDropdown(
            label: 'ตำบล/แขวง',
            districtCode: registerProvider.outboundPickupDistrictCode,
            selectedSubDistrictCode:
                registerProvider.outboundPickupSubDistrictCode,
            onSubDistrictChanged: (value) {
              registerProvider.setOutboundPickupSubDistrictCode(value);
            },
            validator: Validators.required('กรุณาเลือกตำบล/แขวง'),
          ),
          TextFormFielddCustom(
            controller: registerProvider.outboundPickupLandmarkController,
            label: 'จุดสังเกต',
            hintText: 'จุดสังเกต',
            maxLines: 3,
            isRequired: false,
          ),
        ],
      ),
    );
  }

  Container buildFormDropoff() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgHeaderCard,
        borderRadius: BorderRadius.circular(8),
        boxShadow: AppShadow.primaryShadow,
      ),
      child: Column(
        spacing: 16,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormHeaderWidget(
            title: 'จุดส่งผู้ป่วย',
            titleTextStyle: AppTextStyles.bold.copyWith(fontSize: 18),
          ),
          TextFormFielddCustom(
            controller: registerProvider.outboundDropoffLocationController,
            label: 'สถานที่ส่งผู้ป่วย',
            hintText: 'สถานที่ บ้านเลขที่ หมู่ที่ หมู่บ้าน อาคาร ซอย ถนน',
            maxLines: 3,
            validator: Validators.required('กรุณากรอกสถานที่ส่งผู้ป่วย'),
          ),
          ProvinceDropdown(
            label: 'จังหวัด',
            selectedProvinceCode: registerProvider.outboundDropoffProvinceCode,
            onProvinceChanged: (value) {
              registerProvider.setOutboundDropoffProvinceCode(value);
            },
            validator: Validators.required('กรุณาเลือกจังหวัด'),
          ),
          DistrictDropdown(
            label: 'อำเภอ/เขต',
            provinceCode: registerProvider.outboundDropoffProvinceCode,
            selectedDistrictCode: registerProvider.outboundDropoffDistrictCode,
            onDistrictChanged: (value) {
              registerProvider.setOutboundDropoffDistrictCode(value);
            },
            validator: Validators.required('กรุณาเลือกอำเภอ/เขต'),
          ),
          SubDistrictDropdown(
            label: 'ตำบล/แขวง',
            districtCode: registerProvider.outboundDropoffDistrictCode,
            selectedSubDistrictCode:
                registerProvider.outboundDropoffSubDistrictCode,
            onSubDistrictChanged: (value) {
              registerProvider.setOutboundDropoffSubDistrictCode(value);
            },
            validator: Validators.required('กรุณาเลือกตำบล/แขวง'),
          ),
          TextFormFielddCustom(
            controller: registerProvider.outboundDropoffLandmarkController,
            label: 'จุดสังเกต',
            hintText: 'จุดสังเกต',
            maxLines: 3,
            isRequired: false,
          ),
        ],
      ),
    );
  }

  Widget _buildInbound() {
    return BaseCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          FormHeaderWidget(title: 'รายละเอียดการเดินทาง (ขากลับ)'),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                // สำหรับหน้าจอขนาดเล็ก (มือถือ)
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 16,
                  children: [
                    buildInboundFormPickup(),
                    buildInboundFormDropoff(),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 16,
                children: [
                  Expanded(child: buildInboundFormPickup()),
                  Expanded(child: buildInboundFormDropoff()),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Container buildInboundFormPickup() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgHeaderCard,
        borderRadius: BorderRadius.circular(8),
        boxShadow: AppShadow.primaryShadow,
      ),
      child: Column(
        spacing: 16,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormHeaderWidget(
            title: 'จุดรับผู้ป่วย',
            titleTextStyle: AppTextStyles.bold.copyWith(fontSize: 18),
          ),
          TextFormFielddCustom(
            controller: registerProvider.inboundPickupLocationController,
            label: 'สถานที่รับผู้ป่วย',
            hintText: 'สถานที่ บ้านเลขที่ หมู่ที่ หมู่บ้าน อาคาร ซอย ถนน',
            maxLines: 3,
            validator: Validators.required('กรุณากรอกสถานที่รับผู้ป่วย'),
          ),
          ProvinceDropdown(
            label: 'จังหวัด',
            selectedProvinceCode: registerProvider.inboundPickupProvinceCode,
            onProvinceChanged: (value) {
              registerProvider.setInboundPickupProvinceCode(value);
            },
            validator: Validators.required('กรุณาเลือกจังหวัด'),
          ),
          DistrictDropdown(
            label: 'อำเภอ/เขต',
            provinceCode: registerProvider.inboundPickupProvinceCode,
            selectedDistrictCode: registerProvider.inboundPickupDistrictCode,
            onDistrictChanged: (value) {
              registerProvider.setInboundPickupDistrictCode(value);
            },
            validator: Validators.required('กรุณาเลือกอำเภอ/เขต'),
          ),
          SubDistrictDropdown(
            label: 'ตำบล/แขวง',
            districtCode: registerProvider.inboundPickupDistrictCode,
            selectedSubDistrictCode:
                registerProvider.inboundPickupSubDistrictCode,
            onSubDistrictChanged: (value) {
              registerProvider.setInboundPickupSubDistrictCode(value);
            },
            validator: Validators.required('กรุณาเลือกตำบล/แขวง'),
          ),
          TextFormFielddCustom(
            controller: registerProvider.inboundPickupLandmarkController,
            label: 'จุดสังเกต',
            hintText: 'จุดสังเกต',
            maxLines: 3,
            isRequired: false,
          ),
        ],
      ),
    );
  }

  Container buildInboundFormDropoff() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgHeaderCard,
        borderRadius: BorderRadius.circular(8),
        boxShadow: AppShadow.primaryShadow,
      ),
      child: Column(
        spacing: 16,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormHeaderWidget(
            title: 'จุดส่งผู้ป่วย',
            titleTextStyle: AppTextStyles.bold.copyWith(fontSize: 18),
            subTitle: 'ใช้ที่อยู่เดียวกับที่อยู่ปัจจุบัน',
            value: registerProvider.inboundDropoffSameAsCurrent,
            onChanged: (bool? value) {
              if (value == null) return;
              registerProvider.setInboundDropoffSameAsCurrent(value);
            },
          ),
          TextFormFielddCustom(
            controller: registerProvider.inboundDropoffLocationController,
            label: 'สถานที่ส่งผู้ป่วย',
            hintText: 'สถานที่ บ้านเลขที่ หมู่ที่ หมู่บ้าน อาคาร ซอย ถนน',
            maxLines: 3,
            validator: Validators.required('กรุณากรอกสถานที่ส่งผู้ป่วย'),
          ),
          ProvinceDropdown(
            label: 'จังหวัด',
            selectedProvinceCode: registerProvider.inboundDropoffProvinceCode,
            onProvinceChanged: (value) {
              registerProvider.setInboundDropoffProvinceCode(value);
            },
            validator: Validators.required('กรุณาเลือกจังหวัด'),
          ),
          DistrictDropdown(
            label: 'อำเภอ/เขต',
            provinceCode: registerProvider.inboundDropoffProvinceCode,
            selectedDistrictCode: registerProvider.inboundDropoffDistrictCode,
            onDistrictChanged: (value) {
              registerProvider.setInboundDropoffDistrictCode(value);
            },
            validator: Validators.required('กรุณาเลือกอำเภอ/เขต'),
          ),
          SubDistrictDropdown(
            label: 'ตำบล/แขวง',
            districtCode: registerProvider.inboundDropoffDistrictCode,
            selectedSubDistrictCode:
                registerProvider.inboundDropoffSubDistrictCode,
            onSubDistrictChanged: (value) {
              registerProvider.setInboundDropoffSubDistrictCode(value);
            },
            validator: Validators.required('กรุณาเลือกตำบล/แขวง'),
          ),
          TextFormFielddCustom(
            controller: registerProvider.inboundDropoffLandmarkController,
            label: 'จุดสังเกต',
            hintText: 'จุดสังเกต',
            maxLines: 3,
            isRequired: false,
          ),
        ],
      ),
    );
  }

  Widget _buildRoundTrip() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [_buildOutbound(), _buildInbound()],
    );
  }
}
