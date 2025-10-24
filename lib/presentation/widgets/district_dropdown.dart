import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rodzendai_form/models/district_model.dart';
import 'package:rodzendai_form/presentation/blocs/district_bloc/district_bloc.dart';
import 'package:rodzendai_form/widgets/dropdown_field_customer.dart';

typedef DistrictChangedCallback = void Function(int? districtId);

class DistrictDropdown extends StatefulWidget {
  const DistrictDropdown({
    super.key,
    required this.label,
    required this.provinceCode,
    required this.selectedDistrictCode,
    required this.onDistrictChanged,
    this.validator,
    this.isLinked = false,
    this.isRequired = true,
  });

  final String label;
  final int? provinceCode;
  final int? selectedDistrictCode;
  final DistrictChangedCallback onDistrictChanged;
  final String? Function(String?)? validator;
  final bool isLinked;
  final bool isRequired;

  @override
  State<DistrictDropdown> createState() => _DistrictDropdownState();
}

class _DistrictDropdownState extends State<DistrictDropdown> {
  late final DistrictBloc _bloc;
  int? _lastRequestedprovinceCode;

  @override
  void initState() {
    super.initState();
    _bloc = DistrictBloc();
    _requestDistricts();
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant DistrictDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.provinceCode != widget.provinceCode) {
      _requestDistricts();
    }
  }

  void _requestDistricts({bool force = false}) {
    if (!mounted) return;
    final provinceCode= widget.provinceCode;
    if (provinceCode == null) {
      _lastRequestedprovinceCode = null;
      _bloc.add(const DistrictCleared());
      return;
    }
    if (!force && _lastRequestedprovinceCode == provinceCode) {
      return;
    }
    _lastRequestedprovinceCode = provinceCode;
    _bloc.add(
      DistrictRequested(
        provinceCode: provinceCode,
        selectedDistrictCode: widget.selectedDistrictCode,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasProvince = widget.provinceCode != null;

    return BlocBuilder<DistrictBloc, DistrictState>(
      bloc: _bloc,
      builder: (context, state) {
        final isLoading =
            state is DistrictLoadInProgress && hasProvince && !widget.isLinked;
        final hasError = state is DistrictLoadFailure;
        final districts =
            state is DistrictLoadSuccess ? state.districts : const <DistrictModel>[];

        final items = districts
            .where(
              (district) => district.districtCode != null && district.districtNameTh != null,
            )
            .map(
              (district) => DropdownMenuItem<int>(
                value: district.districtCode!,
                child: Text(
                  district.districtNameTh!,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
            .toList();

        final value = items.any(
          (item) => item.value == widget.selectedDistrictCode,
        )
            ? widget.selectedDistrictCode
            : null;

        final hintText = !hasProvince
            ? 'เลือกจังหวัดก่อน'
            : widget.isLinked
                ? 'ใช้ข้อมูลเดียวกับทะเบียนบ้าน'
                : isLoading
                    ? 'กำลังโหลดอำเภอ/เขต...'
                    : hasError
                        ? (state is DistrictLoadFailure
                            ? state.message
                            : 'ไม่สามารถโหลดอำเภอ/เขต')
                        : 'เลือกอำเภอ/เขต';

        final isEnabled = hasProvince &&
            !widget.isLinked &&
            items.isNotEmpty &&
            !hasError;

        final String? Function(int?)? effectiveValidator = !hasProvince || widget.isLinked
            ? null
            : (int? value) => widget.validator?.call(value?.toString());

        return DropdownFieldCustomer<int>(
          label: widget.label,
          isRequired: widget.isRequired,
          hintText: hintText,
          showSearchBox: true,
          isLoading: isLoading,
          isEnabled: isEnabled,
          items: items,
          value: value,
          onChanged: !isEnabled ? null : widget.onDistrictChanged,
          validator: effectiveValidator,
          suffixIcon: hasError && hasProvince
              ? IconButton(
                  icon: const Icon(Icons.refresh, size: 18),
                  onPressed: () => _requestDistricts(force: true),
                )
              : null,
        );
      },
    );
  }
}
