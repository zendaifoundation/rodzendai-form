import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';
import 'package:rodzendai_form/core/constants/app_shadow.dart';
import 'package:rodzendai_form/core/constants/app_text_styles.dart';
import 'package:rodzendai_form/core/services/places_service.dart';
import 'package:rodzendai_form/core/services/service_locator.dart';
import 'package:rodzendai_form/core/utils/env_helper.dart';
import 'package:rodzendai_form/core/utils/toast_helper.dart';
import 'package:rodzendai_form/core/utils/validators.dart';
import 'package:rodzendai_form/models/patient_response_model.dart';
import 'package:rodzendai_form/presentation/blocs/province_bloc/province_bloc.dart';
import 'package:rodzendai_form/presentation/edit_address/blocs/update_patient_bloc/update_patient_bloc.dart';
import 'package:rodzendai_form/presentation/edit_address/providers/edit_address_provider.dart';
import 'package:rodzendai_form/presentation/edit_address/widgets/google_map_widget.dart';
import 'package:rodzendai_form/presentation/register/blocs/get_latlng_bloc/get_latlng_bloc.dart';
import 'package:rodzendai_form/presentation/register/blocs/places_autocomplete_bloc/places_autocomplete_bloc.dart';
import 'package:rodzendai_form/presentation/register/widgets/custom_place_autocomplete.dart';
import 'package:rodzendai_form/presentation/register/widgets/form_header.dart';
import 'package:rodzendai_form/presentation/register_status/blocs/get_location_detail_bloc/get_location_detail_bloc.dart';
import 'package:rodzendai_form/presentation/widgets/district_dropdown.dart';
import 'package:rodzendai_form/presentation/widgets/province_dropdown.dart';
import 'package:rodzendai_form/presentation/widgets/sub_district_dropdown.dart';
import 'package:rodzendai_form/widgets/base_card_container.dart';
import 'package:rodzendai_form/widgets/button_custom.dart';
import 'package:rodzendai_form/widgets/loading_widget.dart';
import 'package:rodzendai_form/widgets/required_label.dart';
import 'package:rodzendai_form/widgets/text_form_field_custom.dart';

class EditCurrentAddressDialog extends StatelessWidget {
  const EditCurrentAddressDialog({
    super.key,
    required this.patientData,
    required this.onSaved,
  });

  final PatientModel patientData;
  final VoidCallback onSaved;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) =>
          EditAddressProvider(
              getLocationDetailBloc: ctx.read<GetLocationDetailBloc>(),
            )
            ..populateFromPatient(patientData)
            ..setAddressType(AddressType.current),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => GetLatLngBloc()),
          BlocProvider(
            create: (_) =>
                PlacesAutocompleteBloc(placesService: locator<PlacesService>()),
          ),
          BlocProvider(create: (_) => ProvinceBloc()..add(ProvinceRequested())),
          BlocProvider(create: (_) => UpdatePatientBloc()),
        ],
        child: _EditCurrentAddressDialogContent(
          patientData: patientData,
          onSaved: onSaved,
        ),
      ),
    );
  }
}

class _EditCurrentAddressDialogContent extends StatelessWidget {
  const _EditCurrentAddressDialogContent({
    required this.patientData,
    required this.onSaved,
  });

  final PatientModel patientData;
  final VoidCallback onSaved;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<EditAddressProvider>();
    final idCard = patientData.patient?.idCardNumber ?? '';

    return MultiBlocListener(
      listeners: [
        BlocListener<UpdatePatientBloc, UpdatePatientState>(
          listener: (context, state) {
            if (state is UpdatePatientSuccess) {
              ToastHelper.showSuccess(
                context: context,
                title: 'บันทึกข้อมูลเรียบร้อย',
              );
              Navigator.of(context).pop();
              onSaved();
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
      child: Builder(
        builder: (context) {
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
                  // Header (style เดียวกับ PickLocationDialog)
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.06),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.location_on, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'แก้ไขที่อยู่ปัจจุบัน',
                            style: AppTextStyles.bold.copyWith(
                            color: AppColors.primary,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                          tooltip: 'ปิด',
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Expanded(
                    child: Form(
                      key: provider.formKey,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          spacing: 16,
                          children: [
                            _buildPatientInfoCard(),
                            Consumer<EditAddressProvider>(
                              builder: (context, p, _) =>
                                  _CurrentAddressForm(provider: p),
                            ),
                            _AddressSummaryCard(),
                            _FormPickupLocation(),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Footer (style เดียวกับ PickLocationDialog)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              side: BorderSide(color: AppColors.textLighter),
                            ),
                            child: Text(
                              'ยกเลิก',
                              style: AppTextStyles.regular.copyWith(
                                color: AppColors.text,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child:
                              BlocBuilder<
                                UpdatePatientBloc,
                                UpdatePatientState
                              >(
                                builder: (context, state) {
                                  final isLoading =
                                      state is UpdatePatientLoading;
                                  return ElevatedButton(
                                    onPressed: isLoading
                                        ? null
                                        : () => _onSave(
                                            context,
                                            provider,
                                            idCard,
                                          ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: isLoading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                            ),
                                          )
                                        : Text(
                                            'บันทึก',
                                            style: AppTextStyles.bold.copyWith(
                                              color: Colors.white,
                                            ),
                                          ),
                                  );
                                },
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPatientInfoCard() {
    final patient = patientData.patient;
    return BaseCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Text(
            'ข้อมูลผู้ป่วย',
            style: AppTextStyles.bold.copyWith(
              color: AppColors.primary,
              fontSize: 16,
            ),
          ),
          const Divider(),
          _buildInfoRow(
            'ชื่อ-นามสกุล:',
            '${patient?.firstName ?? ''} ${patient?.lastName ?? ''}',
          ),
          _buildInfoRow('เลขบัตรประชาชน:', patient?.idCardNumber ?? '-'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      spacing: 8,
      children: [
        Text(
          label,
          style: AppTextStyles.regular.copyWith(
            fontSize: 14,
            color: AppColors.textLight,
          ),
        ),
        Expanded(
          child: Text(value, style: AppTextStyles.bold.copyWith(fontSize: 14)),
        ),
      ],
    );
  }

  void _onSave(
    BuildContext context,
    EditAddressProvider provider,
    String idCard,
  ) {
    if (!provider.validate()) {
      ToastHelper.showValidationError(context: context);
      return;
    }

    // ตรวจสอบว่าเลือกตำแหน่งบนแผนที่แล้วหรือยัง
    if (provider.selectedLocation == null) {
      ToastHelper.showError(
        context: context,
        title: 'กรุณาเลือกตำแหน่งบนแผนที่',
        description: 'กรุณาปักหมุดตำแหน่งรับผู้ป่วยบนแผนที่ก่อนบันทึก',
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

// ที่อยู่ปัจจุบัน
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

// Summary card
class _AddressSummaryCard extends StatefulWidget {
  @override
  State<_AddressSummaryCard> createState() => _AddressSummaryCardState();
}

class _AddressSummaryCardState extends State<_AddressSummaryCard> {
  String? _builtAddress;
  bool _isBuilding = false;

  Future<void> _buildAddress(EditAddressProvider provider) async {
    setState(() => _isBuilding = true);
    final text = await provider.getFullAddressText();
    if (mounted) {
      setState(() {
        _builtAddress = text;
        _isBuilding = false;
      });
    }
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

// FormPickupLocation
class _FormPickupLocation extends StatefulWidget {
  @override
  State<_FormPickupLocation> createState() => _FormPickupLocationState();
}

class _FormPickupLocationState extends State<_FormPickupLocation> {
  EditAddressProvider? _editProvider;
  PlacesAutocompleteBloc? _placesBloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newProvider = context.read<EditAddressProvider>();
    if (_editProvider != newProvider) {
      _editProvider?.pickupLocationController.removeListener(
        _onPickupTextChanged,
      );
      _editProvider = newProvider;
      _editProvider!.pickupLocationController.addListener(_onPickupTextChanged);
    }
  }

  @override
  void dispose() {
    _editProvider?.pickupLocationController.removeListener(
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
    final provider = _editProvider;
    if (provider == null) return;
    final text = provider.pickupLocationController.text;
    final latLng = _tryParseLatLng(text);
    if (latLng == null) return;
    // เป็นพิกัด → ปักหมุดทันที และยกเลิกการค้นหา places
    provider.onMapTap(latLng);
    provider.pickupLocationFocusNode.unfocus();
    _placesBloc?.add(const ClearPlacesEvent());
  }

  @override
  Widget build(BuildContext context) {
    final editProvider = context.read<EditAddressProvider>();
    _placesBloc = context.read<PlacesAutocompleteBloc>();

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
                      fontSize: 18,
                    ),
                  ),
                  Divider(
                    color: AppColors.secondary.withOpacity(0.16),
                    thickness: 1,
                  ),
                  // คำแนะนำ
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.warning.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.warning,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'กรุณาปักหมุดตำแหน่งรับผู้ป่วยบนแผนที่ให้ถูกต้อง',
                            style: AppTextStyles.regular.copyWith(
                              fontSize: 13,
                              color: AppColors.warning,
                            ),
                          ),
                        ),
                      ],
                    ),
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
                  Consumer<EditAddressProvider>(
                    builder: (context, p, _) {
                      final isLoading = p.isLoadingLocation;
                      return SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: isLoading
                              ? null
                              : () async {
                                  await p.getCurrentLocation();
                                  final loc = p.currentLocation;
                                  p.onMapTap(loc);
                                },
                          icon: isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.my_location),
                          label: Text(
                            isLoading
                                ? 'กำลังดึงตำแหน่ง...'
                                : 'ใช้ตำแหน่งปัจจุบัน',
                            style: AppTextStyles.regular.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            side: BorderSide(color: AppColors.primary),
                          ),
                        ),
                      );
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
                                Row(
                                  children: [
                                    Text(
                                      'ที่อยู่ที่เลือก: ',
                                      style: AppTextStyles.regular.copyWith(
                                        color: AppColors.success,
                                      ),
                                    ),
                                    Consumer<EditAddressProvider>(
                                      builder: (context, p, _) {
                                        if (p.selectedLocation != null) {
                                          return Icon(
                                            Icons.check_circle,
                                            color: AppColors.success,
                                            size: 16,
                                          );
                                        }
                                        return Icon(
                                          Icons.location_off,
                                          color: AppColors.error,
                                          size: 16,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                Consumer<EditAddressProvider>(
                                  builder: (context, p, _) => Text(
                                    p.formattedAddress ??
                                        'ยังไม่ได้เลือกตำแหน่ง',
                                    style: AppTextStyles.regular.copyWith(
                                      fontSize: 14,
                                      color: p.selectedLocation == null
                                          ? AppColors.error
                                          : AppColors.text,
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
