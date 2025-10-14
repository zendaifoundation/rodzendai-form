import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rodzendai_form/models/sub_district_model.dart';
import 'package:rodzendai_form/presentation/blocs/sub_district_bloc/sub_district_bloc.dart';
import 'package:rodzendai_form/widgets/dropdown_field_customer.dart';

typedef SubDistrictChangedCallback = void Function(int? subDistrictId);

class SubDistrictDropdown extends StatefulWidget {
  const SubDistrictDropdown({
    super.key,
    required this.label,
    required this.districtId,
    required this.selectedSubDistrictId,
    required this.onSubDistrictChanged,
    this.validator,
    this.isRequired = true,
  });

  final String label;
  final int? districtId;
  final int? selectedSubDistrictId;
  final SubDistrictChangedCallback onSubDistrictChanged;
  final String? Function(String?)? validator;
  final bool isRequired;

  @override
  State<SubDistrictDropdown> createState() => _SubDistrictDropdownState();
}

class _SubDistrictDropdownState extends State<SubDistrictDropdown> {
  late final SubDistrictBloc _bloc;
  int? _lastRequestedDistrictId;

  @override
  void initState() {
    super.initState();
    _bloc = SubDistrictBloc();
    _requestSubDistricts();
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SubDistrictDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.districtId != widget.districtId) {
      _requestSubDistricts();
    }
  }

  void _requestSubDistricts({bool force = false}) {
    if (!mounted) return;
    final districtId = widget.districtId;
    if (districtId == null) {
      _lastRequestedDistrictId = null;
      _bloc.add(const SubDistrictCleared());
      return;
    }
    if (!force && _lastRequestedDistrictId == districtId) {
      return;
    }
    _lastRequestedDistrictId = districtId;
    _bloc.add(
      SubDistrictRequested(
        districtId: districtId,
        selectedSubDistrictId: widget.selectedSubDistrictId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasDistrict = widget.districtId != null;

    return BlocBuilder<SubDistrictBloc, SubDistrictState>(
      bloc: _bloc,
      builder: (context, state) {
        final isLoading = state is SubDistrictLoadInProgress && hasDistrict;
        final hasError = state is SubDistrictLoadFailure;
        final subDistricts = state is SubDistrictLoadSuccess
            ? state.subDistricts
            : const <SubDistrictModel>[];

        final items = subDistricts
            .where(
              (subDistrict) =>
                  subDistrict.id != null && subDistrict.nameTh != null,
            )
            .map(
              (subDistrict) => DropdownMenuItem<int>(
                value: subDistrict.id!,
                child: Text(
                  subDistrict.nameTh!,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
            .toList();

        final value =
            items.any((item) => item.value == widget.selectedSubDistrictId)
            ? widget.selectedSubDistrictId
            : null;

        final hintText = !hasDistrict
            ? 'เลือกอำเภอ/เขตก่อน'
            : isLoading
            ? 'กำลังโหลดตำบล/แขวง...'
            : hasError
            ? (state is SubDistrictLoadFailure
                  ? state.message
                  : 'ไม่สามารถโหลดตำบล/แขวง')
            : 'เลือกตำบล/แขวง';

        final isEnabled = hasDistrict && items.isNotEmpty && !hasError;

        final String? Function(int?)? effectiveValidator = !hasDistrict
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
          onChanged: !isEnabled ? null : widget.onSubDistrictChanged,
          validator: effectiveValidator,
          suffixIcon: hasError && hasDistrict
              ? IconButton(
                  icon: const Icon(Icons.refresh, size: 18),
                  onPressed: () => _requestSubDistricts(force: true),
                )
              : null,
        );
      },
    );
  }
}
