import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';
import 'package:rodzendai_form/core/constants/app_text_styles.dart';
import 'package:rodzendai_form/core/constants/app_shadow.dart';
import 'package:rodzendai_form/core/utils/env_helper.dart';
import 'package:rodzendai_form/core/utils/toast_helper.dart';
import 'package:rodzendai_form/core/utils/validators.dart';
import 'package:rodzendai_form/core/services/places_service.dart';
import 'package:rodzendai_form/core/services/service_locator.dart';
import 'package:rodzendai_form/presentation/blocs/province_bloc/province_bloc.dart';
import 'package:rodzendai_form/presentation/edit_address/providers/edit_address_provider.dart';
import 'package:rodzendai_form/presentation/edit_address/widgets/form_pickup_location.dart';
import 'package:rodzendai_form/presentation/edit_address/blocs/get_patient_bloc/get_patient_bloc.dart';
import 'package:rodzendai_form/presentation/edit_address/blocs/update_patient_bloc/update_patient_bloc.dart';
import 'package:rodzendai_form/presentation/register/blocs/get_latlng_bloc/get_latlng_bloc.dart';
import 'package:rodzendai_form/presentation/register/blocs/places_autocomplete_bloc/places_autocomplete_bloc.dart';
import 'package:rodzendai_form/presentation/register/widgets/form_header.dart';
import 'package:rodzendai_form/presentation/register_status/blocs/get_location_detail_bloc/get_location_detail_bloc.dart';
import 'package:rodzendai_form/presentation/widgets/district_dropdown.dart';
import 'package:rodzendai_form/presentation/widgets/province_dropdown.dart';
import 'package:rodzendai_form/presentation/widgets/sub_district_dropdown.dart';
import 'package:rodzendai_form/widgets/appbar_customer.dart';
import 'package:rodzendai_form/widgets/base_card_container.dart';
import 'package:rodzendai_form/widgets/button_custom.dart';
import 'package:rodzendai_form/widgets/text_form_field_custom.dart';

class EditAddressPage extends StatelessWidget {
  const EditAddressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => EditAddressProvider(
        getLocationDetailBloc: ctx.read<GetLocationDetailBloc>(),
      ),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => GetLatLngBloc()),
          BlocProvider(
            create: (_) =>
                PlacesAutocompleteBloc(placesService: locator<PlacesService>()),
          ),
          BlocProvider(create: (_) => ProvinceBloc()..add(ProvinceRequested())),
          BlocProvider(create: (_) => GetPatientBloc()),
          BlocProvider(create: (_) => UpdatePatientBloc()),
        ],
        child: const _EditAddressView(),
      ),
    );
  }
}

class _EditAddressView extends StatelessWidget {
  const _EditAddressView();

  @override
  Widget build(BuildContext context) {
    final provider = context.read<EditAddressProvider>();

    return MultiBlocListener(
      listeners: [
        BlocListener<GetPatientBloc, GetPatientState>(
          listener: (context, state) {
            if (state is GetPatientSuccess) {
              provider.populateFromPatient(state.patient);
              ToastHelper.showSuccess(
                context: context,
                title: 'พบข้อมูลผู้ป่วย',
                description:
                    'พบข้อมูลผู้ป่วย:คุณ${state.patient.patient?.firstName ?? ''} ${state.patient.patient?.lastName ?? ''}',
              );
            } else if (state is GetPatientFailure) {
              ToastHelper.showError(
                context: context,
                title: 'ไม่พบข้อมูลผู้ป่วย',
                description: state.message,
              );
            }
          },
        ),
        BlocListener<UpdatePatientBloc, UpdatePatientState>(
          listener: (context, state) {
            if (state is UpdatePatientSuccess) {
              ToastHelper.showSuccess(
                context: context,
                title: 'บันทึกข้อมูลเรียบร้อย',
              );
            } else if (state is UpdatePatientFailure) {
              ToastHelper.showError(
                context: context,
                title: 'บันทึกข้อมูลไม่สำเร็จ',
                description: state.message,
              );
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.bgColor,
        appBar: AppBarCustomer(title: 'แก้ไขที่อยู่', showBackButton: true),
        body: Form(
          key: provider.formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              spacing: 16,
              children: [
                // ---- บัตรประชาชน ----
                BaseCardContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 16,
                    children: [
                      FormHeaderWidget(title: 'ข้อมูลผู้ป่วย'),
                      TextFormFielddCustom(
                        label: 'เลขบัตรประชาชน',
                        isRequired: true,
                        hintText: 'กรอกเลขบัตรประชาชน 13 หลัก',
                        controller: provider.idCardController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(13),
                        ],
                        validator: Validators.validateIdCardNumber,
                      ),
                      BlocBuilder<GetPatientBloc, GetPatientState>(
                        builder: (context, state) {
                          return ButtonCustom(
                            text: 'ค้นหาข้อมูลผู้ป่วย',
                            isLoading: state is GetPatientLoading,
                            icon: const Icon(
                              Icons.search,
                              color: Colors.white,
                              size: 18,
                            ),
                            onPressed: () {
                              final idCard = provider.idCardController.text
                                  .trim();
                              final error = Validators.validateIdCardNumber(
                                idCard,
                              );
                              if (error != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(error),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              context.read<GetPatientBloc>().add(
                                GetPatientByIdCardEvent(idCardNumber: idCard),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // ---- เลือกประเภทที่อยู่ ----
                BaseCardContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 12,
                    children: [
                      FormHeaderWidget(
                        title: 'เลือกประเภทที่อยู่ที่ต้องการแก้ไข',
                      ),
                      Consumer<EditAddressProvider>(
                        builder: (context, p, _) => Column(
                          children: AddressType.values.map((type) {
                            return RadioListTile<AddressType>(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                type == AddressType.registered
                                    ? 'ที่อยู่ตามทะเบียนบ้าน'
                                    : 'ที่อยู่ปัจจุบัน',
                                style: AppTextStyles.regular,
                              ),
                              value: type,
                              groupValue: p.selectedAddressType,
                              activeColor: AppColors.primary,
                              onChanged: (value) {
                                if (value != null) p.setAddressType(value);
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),

                // ---- ฟอร์มที่อยู่ ----
                Consumer<EditAddressProvider>(
                  builder: (context, p, _) {
                    if (p.selectedAddressType == AddressType.registered) {
                      return _RegisteredAddressForm(provider: p);
                    }
                    return _CurrentAddressForm(provider: p);
                  },
                ),

                // แสดงข้อมูลที่แก้ไขแล้วเพื่อยืนยันบนแผนที่
                const _AddressSummaryCard(),

                // ---- สถานที่รับผู้ป่วย ----
                const FormPickupLocationEditAddress(),

                // ---- ปุ่มบันทึก ----
                BlocBuilder<UpdatePatientBloc, UpdatePatientState>(
                  builder: (context, updateState) {
                    return Consumer<EditAddressProvider>(
                      builder: (context, p, _) => ButtonCustom(
                        text: 'บันทึก',
                        isLoading: updateState is UpdatePatientLoading,
                        onPressed: updateState is UpdatePatientLoading
                            ? null
                            : () => _onSave(context, p),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ), // Scaffold
    ); // MultiBlocListener
  }

  void _onSave(BuildContext context, EditAddressProvider provider) {
    if (!provider.validate()) return;
    final idCard = provider.idCardController.text.trim();
    if (idCard.isEmpty) {
      ToastHelper.showError(
        context: context,
        title: 'กรุณากรอกเลขบัตรประชาชนก่อนบันทึก',
      );
      return;
    }
    final payload = provider.toPayload();
    log('📦 EditAddress payload: $payload');
    context.read<UpdatePatientBloc>().add(
      UpdatePatientSubmitEvent(idCardNumber: idCard, updateData: payload),
    );
  }
}

// ---------------------------------------------------------------------------
// ที่อยู่ตามทะเบียนบ้าน
// ---------------------------------------------------------------------------
class _RegisteredAddressForm extends StatelessWidget {
  const _RegisteredAddressForm({required this.provider});
  final EditAddressProvider provider;

  @override
  Widget build(BuildContext context) {
    return BaseCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          FormHeaderWidget(title: 'ที่อยู่ตามทะเบียนบ้าน'),
          TextFormFielddCustom(
            label: 'ที่อยู่ตามทะเบียนบ้าน',
            isRequired: true,
            hintText: 'บ้านเลขที่ หมู่ที่ หมู่บ้าน อาคาร ซอย ถนน',
            maxLines: null,
            minLines: 3,
            controller: provider.registeredAddressController,
            validator: Validators.required('กรุณากรอกข้อมูล'),
          ),
          ProvinceDropdown(
            label: 'จังหวัด',
            selectedProvinceCode: provider.registeredProvinceCode,
            onProvinceChanged: provider.setRegisteredProvinceCode,
            allowedProvinceCodes: EnvHelper.allowedProvinceCode != null
                ? [EnvHelper.allowedProvinceCode ?? '']
                : [],
            validator: Validators.required('กรุณาเลือกจังหวัด'),
          ),
          DistrictDropdown(
            label: 'อำเภอ/เขต',
            provinceCode: provider.registeredProvinceCode,
            selectedDistrictCode: provider.registeredDistrictCode,
            onDistrictChanged: provider.setRegisteredDistrictCode,
            allowedDistrictCodes: EnvHelper.allowedDistrictCode != null
                ? [EnvHelper.allowedDistrictCode ?? '']
                : [],
            validator: Validators.required('กรุณาเลือกอำเภอ/เขต'),
          ),
          SubDistrictDropdown(
            label: 'ตำบล/แขวง',
            districtCode: provider.registeredDistrictCode,
            selectedSubDistrictCode: provider.registeredSubDistrictCode,
            onSubDistrictChanged: provider.setRegisteredSubDistrictCode,
            allowedSubDistrictCodes: EnvHelper.allowedSubDistrictCodes,
            validator: Validators.required('กรุณาเลือกตำบล/แขวง'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ที่อยู่ปัจจุบัน
// ---------------------------------------------------------------------------
class _CurrentAddressForm extends StatelessWidget {
  const _CurrentAddressForm({required this.provider});
  final EditAddressProvider provider;

  @override
  Widget build(BuildContext context) {
    return BaseCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          FormHeaderWidget(title: 'ที่อยู่ปัจจุบัน'),
          TextFormFielddCustom(
            label: 'ที่อยู่ปัจจุบัน',
            isRequired: true,
            hintText: 'บ้านเลขที่ หมู่ที่ หมู่บ้าน อาคาร ซอย ถนน',
            maxLines: null,
            minLines: 3,
            controller: provider.currentAddressController,
            validator: Validators.required('กรุณากรอกข้อมูล'),
          ),
          ProvinceDropdown(
            label: 'จังหวัด',
            selectedProvinceCode: provider.currentProvinceCode,
            onProvinceChanged: provider.setCurrentProvinceCode,
            allowedProvinceCodes: EnvHelper.allowedProvinceCode != null
                ? [EnvHelper.allowedProvinceCode ?? '']
                : [],
            validator: Validators.required('กรุณาเลือกจังหวัด'),
          ),
          DistrictDropdown(
            label: 'อำเภอ/เขต',
            provinceCode: provider.currentProvinceCode,
            selectedDistrictCode: provider.currentDistrictCode,
            onDistrictChanged: provider.setCurrentDistrictCode,
            allowedDistrictCodes: EnvHelper.allowedDistrictCode != null
                ? [EnvHelper.allowedDistrictCode ?? '']
                : [],
            validator: Validators.required('กรุณาเลือกอำเภอ/เขต'),
          ),
          SubDistrictDropdown(
            label: 'ตำบล/แขวง',
            districtCode: provider.currentDistrictCode,
            selectedSubDistrictCode: provider.currentSubDistrictCode,
            onSubDistrictChanged: provider.setCurrentSubDistrictCode,
            allowedSubDistrictCodes: EnvHelper.allowedSubDistrictCodes,
            validator: Validators.required('กรุณาเลือกตำบล/แขวง'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Summary card — แสดงที่อยู่ที่กรอกแล้ว + ปุ่มค้นหาบนแผนที่
// ---------------------------------------------------------------------------
class _AddressSummaryCard extends StatefulWidget {
  const _AddressSummaryCard();

  @override
  State<_AddressSummaryCard> createState() => _AddressSummaryCardState();
}

class _AddressSummaryCardState extends State<_AddressSummaryCard> {
  String? _builtAddress;
  bool _isBuilding = false;

  Future<void> _buildAddress(EditAddressProvider provider) async {
    setState(() => _isBuilding = true);
    final text = await provider.getFullAddressText();
    if (mounted)
      setState(() {
        _builtAddress = text;
        _isBuilding = false;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EditAddressProvider>(
      builder: (context, provider, _) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: AppShadow.primaryShadow,
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              Text(
                'ที่อยู่ที่กรอกไว้',
                style: AppTextStyles.bold.copyWith(color: AppColors.primary),
              ),
              const Divider(height: 1),
              if (_builtAddress != null)
                Text(
                  _builtAddress!.isEmpty
                      ? 'กรุณากรอกข้อมูลที่อยู่ก่อน'
                      : _builtAddress!,
                  style: AppTextStyles.regular.copyWith(fontSize: 14),
                )
              else
                Text(
                  'กดปุ่มด้านล่างเพื่อดูที่อยู่และค้นหาบนแผนที่',
                  style: AppTextStyles.regular.copyWith(
                    fontSize: 13,
                    color: AppColors.textLighter,
                  ),
                ),
              ButtonCustom(
                text: 'ค้นหาตำแหน่งบนแผนที่',
                isLoading: _isBuilding,
                icon: const Icon(
                  Icons.location_on,
                  color: Colors.white,
                  size: 18,
                ),
                onPressed: () async {
                  await _buildAddress(provider);
                  if (!mounted ||
                      _builtAddress == null ||
                      _builtAddress!.isEmpty)
                    return;
                  provider.pickupLocationController.text = _builtAddress!;
                  if (mounted) {
                    context.read<GetLatLngBloc>().add(
                      GetLatLngFromAddressEvent(address: _builtAddress!),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
