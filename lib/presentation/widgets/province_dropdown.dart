import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rodzendai_form/models/province_model.dart';
import 'package:rodzendai_form/presentation/blocs/province_bloc/province_bloc.dart';
import 'package:rodzendai_form/widgets/dropdown_field_customer.dart';

typedef ProvinceChangedCallback = void Function(int? provinceId);

class ProvinceDropdown extends StatelessWidget {
  const ProvinceDropdown({
    super.key,
    required this.label,
    required this.selectedProvinceId,
    required this.onProvinceChanged,
    this.isLinked = false,
    this.validator,
    this.isRequired = true,
  });

  final String label;
  final int? selectedProvinceId;
  final ProvinceChangedCallback onProvinceChanged;
  final bool isLinked;
  final String? Function(String?)? validator;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProvinceBloc, ProvinceState>(
      builder: (context, state) {
        final isLoading =
            state is ProvinceLoadInProgress || state is ProvinceInitial;
        final hasError = state is ProvinceLoadFailure;
        final provinces = state is ProvinceLoadSuccess
            ? state.provinces
            : const <ProvinceModel>[];

        final items = provinces
            .where((province) => province.id != null && province.nameTh != null)
            .map(
              (province) => DropdownMenuItem<int>(
                value: province.id!,
                child: Text(province.nameTh!, overflow: TextOverflow.ellipsis),
              ),
            )
            .toList();

        final value = items.any((item) => item.value == selectedProvinceId)
            ? selectedProvinceId
            : null;

        final hintText = isLinked
            ? 'ใช้จังหวัดเดียวกับทะเบียนบ้าน'
            : isLoading
            ? 'กำลังโหลดจังหวัด...'
            : hasError
            ? (state is ProvinceLoadFailure
                  ? state.message
                  : 'ไม่สามารถโหลดจังหวัด')
            : 'เลือกจังหวัด';

        final isEnabled = !isLinked && items.isNotEmpty && !hasError;
        final String? Function(int?)? effectiveValidator = isLinked
            ? null
            : (int? value) => validator?.call(value?.toString());

        return DropdownFieldCustomer<int>(
          label: label,
          isRequired: isRequired,
          hintText: hintText,
          showSearchBox: true,
          isLoading: isLoading,
          isEnabled: isEnabled,
          items: items,
          value: value,
          onChanged: !isEnabled
              ? null
              : (selected) => onProvinceChanged(selected),
          validator: effectiveValidator,
          suffixIcon: hasError
              ? IconButton(
                  icon: const Icon(Icons.refresh, size: 18),
                  onPressed: () {
                    context.read<ProvinceBloc>().add(
                      ProvinceRequested(selectedProvinceId: selectedProvinceId),
                    );
                  },
                )
              : null,
        );
      },
    );
  }
}
