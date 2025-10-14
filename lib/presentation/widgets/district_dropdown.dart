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
    required this.provinceId,
    required this.selectedDistrictId,
    required this.onDistrictChanged,
    this.validator,
    this.isLinked = false,
    this.isRequired = true,
  });

  final String label;
  final int? provinceId;
  final int? selectedDistrictId;
  final DistrictChangedCallback onDistrictChanged;
  final String? Function(String?)? validator;
  final bool isLinked;
  final bool isRequired;

  @override
  State<DistrictDropdown> createState() => _DistrictDropdownState();
}

class _DistrictDropdownState extends State<DistrictDropdown> {
  late final DistrictBloc _bloc;
  int? _lastRequestedProvinceId;

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
    if (oldWidget.provinceId != widget.provinceId) {
      _requestDistricts();
    }
  }

  void _requestDistricts({bool force = false}) {
    if (!mounted) return;
    final provinceId = widget.provinceId;
    if (provinceId == null) {
      _lastRequestedProvinceId = null;
      _bloc.add(const DistrictCleared());
      return;
    }
    if (!force && _lastRequestedProvinceId == provinceId) {
      return;
    }
    _lastRequestedProvinceId = provinceId;
    _bloc.add(
      DistrictRequested(
        provinceId: provinceId,
        selectedDistrictId: widget.selectedDistrictId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasProvince = widget.provinceId != null;

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
              (district) => district.id != null && district.nameTh != null,
            )
            .map(
              (district) => DropdownMenuItem<int>(
                value: district.id!,
                child: Text(
                  district.nameTh!,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
            .toList();

        final value = items.any(
          (item) => item.value == widget.selectedDistrictId,
        )
            ? widget.selectedDistrictId
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
