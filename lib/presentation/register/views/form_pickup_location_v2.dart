import 'package:flutter/material.dart';
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
    // return MultiBlocProvider(
    //   providers: [
    //     BlocProvider(create: (context) => GetLatLngBloc()),
    //     BlocProvider(
    //       create: (context) =>
    //           PlacesAutocompleteBloc(placesService: locator<PlacesService>()),
    //     ),
    //   ],
    //   child: BlocListener<GetLatLngBloc, GetLatLngState>(
    //     listener: (context, state) {
    //       if (state is GetLatLngSuccess) {
    //         log(
    //           '✅ GetLatLngSuccess: lat=//${state.latitude}, lng=${state.longitude}',
    //         );
    //         final location = LatLng(state.latitude, state.longitude);
    //         registerProvider.onMapTap(location);
    //       } else if (state is GetLatLngFailure) {
    //         log('❌ GetLatLngFailure: ${state.message}');
    //       }
    //     },
    //     child: BlocListener<GetLocationDetailBloc, GetLocationDetailState>(
    //       listener: (context, state) async {
    //         switch (state) {
    //           case GetLocationDetailInitial():
    //             break;
    //           case GetLocationDetailLoading():
    //             break;
    //           case GetLocationDetailSuccess():
    //             registerProvider.setFormattedAddress(
    //               state.addressDetail.formattedAddress,
    //             );
    //             break;
    //           case GetLocationDetailFailure():
    //             break;
    //         }
    //       },
    //       child: BaseCardContainer(
    //         child: Column(
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           spacing: 16,
    //           children: [

    //             // Row(
    //             //   mainAxisAlignment: MainAxisAlignment.end,
    //             //   children: [
    //             //     Checkbox(
    //             //       value: registerProvider.sameAsRegistered,
    //             //       onChanged: (value) async {
    //             //         if (value == null) return;
    //             //         registerProvider.setSameAsRegistered(value);

    //             //         if (registerProvider.patientData?.addresses?.current !=
    //             //             null) {
    //             //           log(
    //             //             'current address: ${registerProvider.patientData?.addresses?.current?.toJson()}',
    //             //           );
    //             //           if (value) {
    //             //             String currentAddress = await registerProvider
    //             //                 .getCurrentAddressFullText();
    //             //             registerProvider
    //             //                     .registerPickupLocationController
    //             //                     .text =
    //             //                 currentAddress;
    //             //             context.read<GetLatLngBloc>().add(
    //             //               GetLatLngFromAddressEvent(
    //             //                 address: currentAddress,
    //             //               ),
    //             //             );
    //             //           }
    //             //         } else {
    //             //           context.read<GetLatLngBloc>().add(
    //             //             GetLatLngFromAddressEvent(
    //             //               address: registerProvider
    //             //                   .registerPickupLocationController
    //             //                   .text
    //             //                   .trim(),
    //             //             ),
    //             //           );
    //             //         }
    //             //       },
    //             //       activeColor: AppColors.primary,
    //             //       checkColor: AppColors.white,
    //             //       side: BorderSide(color: AppColors.textLighter, width: 2),
    //             //     ),
    //             //     Text(
    //             //       'ใช้ข้อมูลผู้แจ้ง/ผู้ติดต่อ',
    //             //       style: AppTextStyles.regular,
    //             //     ),
    //             //   ],
    //             // ),
    //             // CustomPlaceAutocomplete(
    //             //   controller: registerProvider.registerPickupLocationController,
    //             //   focusNode: registerProvider.pickupLocationFocusNode,
    //             //   onSelected: (prediction) {
    //             //     log('📍 Selected place: ');

    //             //     final description = prediction['description'];
    //             //     if (description != null) {
    //             //       registerProvider.setFormattedAddress(description);
    //             //       registerProvider.registerPickupLocationController.text =
    //             //           description;
    //             //     }

    //             //     final placeId = prediction['place_id'];
    //             //     if (placeId != null) {
    //             //       context.read<GetLatLngBloc>().add(
    //             //         GetLatLngFromPlaceIdEvent(placeId: placeId),
    //             //       );
    //             //     }
    //             //   },
    //             // ),
    //             // GoogleMapWidget(),
    //             // Container(
    //             //   width: double.infinity,
    //             //   padding: EdgeInsets.all(16),
    //             //   decoration: BoxDecoration(
    //             //     color: AppColors.bgColor,
    //             //     borderRadius: BorderRadius.circular(8),
    //             //     boxShadow: AppShadow.primaryShadow,
    //             //   ),
    //             //   child:
    //             //       BlocBuilder<
    //             //         GetLocationDetailBloc,
    //             //         GetLocationDetailState
    //             //       >(
    //             //         builder: (context, state) {
    //             //           if (state is GetLocationDetailLoading) {
    //             //             return LoadingWidget();
    //             //           }
    //             //           return Column(
    //             //             crossAxisAlignment: CrossAxisAlignment.start,
    //             //             spacing: 8,
    //             //             children: [
    //             //               Text(
    //             //                 'ที่อยู่ปัจจุบัน: ',
    //             //                 style: AppTextStyles.regular.copyWith(
    //             //                   color: AppColors.success,
    //             //                 ),
    //             //               ),
    //             //               Text(
    //             //                 registerProvider.formattedAddress ??
    //             //                     'ไม่มีข้อมูล',
    //             //                 style: AppTextStyles.regular.copyWith(
    //             //                   fontSize: 14,
    //             //                 ),
    //             //               ),
    //             //             ],
    //             //           );
    //             //         },
    //             //       ),
    //             // ),
    //           ],
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }

  Widget _buildOutbound() {
    return BaseCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          FormHeaderWidget(title: 'รายละเอียดการเดินทาง (ขาไป)'),
          TextFormFielddCustom(
            controller: registerProvider.outboundPickupLocationController,
            label: 'สถานที่รับผู้ป่วย',
            hintText: 'สถานที่ บ้านเลขที่ หมู่ที่ หมู่บ้าน อาคาร ซอย ถนน',
            maxLines: 3,
            validator: Validators.required('กรุณากรอกสถานที่รับผู้ป่วย'),
          ),
          ProvinceDropdown(
            label: 'จังหวัด',
            selectedProvinceCode: registerProvider.outboundProvinceCode,
            onProvinceChanged: (value) {
              registerProvider.setOutboundProvinceCode(value);
            },
            validator: Validators.required('กรุณาเลือกจังหวัด'),
          ),
          DistrictDropdown(
            label: 'อำเภอ/เขต',
            provinceCode: registerProvider.outboundProvinceCode,
            selectedDistrictCode: registerProvider.outboundDistrictCode,
            onDistrictChanged: (value) {
              registerProvider.setOutboundDistrictCode(value);
            },
            validator: Validators.required('กรุณาเลือกอำเภอ/เขต'),
          ),
          SubDistrictDropdown(
            label: 'ตำบล/แขวง',
            districtCode: registerProvider.outboundDistrictCode,
            selectedSubDistrictCode: registerProvider.outboundSubDistrictCode,
            onSubDistrictChanged: (value) {
              registerProvider.setOutboundSubDistrictCode(value);
            },
            validator: Validators.required('กรุณาเลือกตำบล/แขวง'),
          ),
          TextFormFielddCustom(
            controller: registerProvider.outboundLandmarkController,
            label: 'จุดสังเกต',
            hintText: 'จุดสังเกต',
            maxLines: 3,
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
          TextFormFielddCustom(
            controller: registerProvider.inboundPickupLocationController,
            label: 'สถานที่รับผู้ป่วย',
            hintText: 'สถานที่ บ้านเลขที่ หมู่ที่ หมู่บ้าน อาคาร ซอย ถนน',
            maxLines: 3,
            validator: Validators.required('กรุณากรอกสถานที่รับผู้ป่วย'),
          ),
          ProvinceDropdown(
            label: 'จังหวัด',
            selectedProvinceCode: registerProvider.inboundProvinceCode,
            onProvinceChanged: (value) {
              registerProvider.setInboundProvinceCode(value);
            },
            validator: Validators.required('กรุณาเลือกจังหวัด'),
          ),
          DistrictDropdown(
            label: 'อำเภอ/เขต',
            provinceCode: registerProvider.inboundProvinceCode,
            selectedDistrictCode: registerProvider.inboundDistrictCode,
            onDistrictChanged: (value) {
              registerProvider.setInboundDistrictCode(value);
            },
            validator: Validators.required('กรุณาเลือกอำเภอ/เขต'),
          ),
          SubDistrictDropdown(
            label: 'ตำบล/แขวง',
            districtCode: registerProvider.inboundDistrictCode,
            selectedSubDistrictCode: registerProvider.inboundSubDistrictCode,
            onSubDistrictChanged: (value) {
              registerProvider.setInboundSubDistrictCode(value);
            },
            validator: Validators.required('กรุณาเลือกตำบล/แขวง'),
          ),
          TextFormFielddCustom(
            controller: registerProvider.inboundLandmarkController,
            label: 'จุดสังเกต',
            hintText: 'จุดสังเกต',
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildRoundTrip() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          // สำหรับหน้าจอขนาดเล็ก (มือถือ)
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [_buildOutbound(), _buildInbound()],
          );
        } else {
          // สำหรับหน้าจอขนาดใหญ่ (แท็บเล็ตหรือเดสก์ท็อป)
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildOutbound()),
              SizedBox(width: 16), // ช่องว่างระหว่างคอลัมน์
              Expanded(child: _buildInbound()),
            ],
          );
        }
      },
    );
  }
}
