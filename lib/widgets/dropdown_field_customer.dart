import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';
import 'package:rodzendai_form/core/constants/app_text_styles.dart';
import 'package:rodzendai_form/widgets/loading_widget.dart';
import 'package:rodzendai_form/widgets/required_label.dart';

class DropdownItem {
  final String id;
  final String? display;

  DropdownItem({required this.id, this.display});
}

class DropdownFieldCustomer<T> extends StatelessWidget {
  final String? label;
  final String? hintText;
  final bool isRequired;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? Function(T?)? validator;
  final Widget? suffixIcon;
  final bool showSearchBox;
  final bool isLoading;
  final bool isEnabled;
  final double? popupMaxHeight;

  const DropdownFieldCustomer({
    super.key,
    required this.label,
    this.hintText,
    this.isRequired = false,
    this.value,
    required this.items,
    this.onChanged,
    this.validator,
    this.suffixIcon,
    this.showSearchBox = false,
    this.isLoading = false,
    this.isEnabled = true,
    this.popupMaxHeight,
  });

  @override
  Widget build(BuildContext context) {
    // Convert DropdownMenuItem<T> to DropdownItem
    final dropdownItems = items.map((menuItem) {
      return DropdownItem(
        id: menuItem.value.toString(),
        display: _extractTextFromChild(menuItem.child),
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        if (label != null)
          RequiredLabel(text: label ?? '-', isRequired: isRequired),

        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 48),
          child: DropdownSearch<DropdownItem>(
            items: (context, filter) => dropdownItems,
            selectedItem: value == null
                ? null
                : dropdownItems
                      .where((element) => element.id == value.toString())
                      .firstOrNull,
            itemAsString: (item) => item.display ?? '-',
            onChanged: isEnabled && !isLoading
                ? (item) {
                    // Find the original value from items
                    final originalItem = items.firstWhere(
                      (menuItem) => menuItem.value.toString() == item?.id,
                      orElse: () => items.first,
                    );
                    onChanged?.call(originalItem.value);
                  }
                : null,
            enabled: isLoading ? false : isEnabled,
            validator: (item) => validator?.call(
              item == null
                  ? null
                  : items
                        .firstWhere(
                          (menuItem) => menuItem.value.toString() == item.id,
                        )
                        .value,
            ),
            compareFn: (item1, item2) => item1.id == item2.id,
            suffixProps: DropdownSuffixProps(
              dropdownButtonProps: DropdownButtonProps(
                iconClosed: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: LoadingWidget(),
                      )
                    : const Icon(Icons.arrow_drop_down),
                iconOpened: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: LoadingWidget(),
                      )
                    : const Icon(Icons.arrow_drop_up),
              ),
            ),
            decoratorProps: DropDownDecoratorProps(
              decoration: InputDecoration(
                hintText: hintText,
                hintMaxLines: 1,
                hintStyle: AppTextStyles.regular.copyWith(
                  color: AppColors.textLighter,
                  fontSize: 14,
                ),
                filled: true,
                fillColor: AppColors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                floatingLabelAlignment: FloatingLabelAlignment.center,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.border, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.border, width: 1),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.red, width: 1.5),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.red, width: 1),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.border, width: 1),
                ),
                suffixIcon: suffixIcon,
                errorStyle: AppTextStyles.regular.copyWith(
                  fontSize: 12,
                  color: Colors.red,
                ),
              ),
            ),
            dropdownBuilder: (context, selectedItem) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Text(
                  selectedItem?.display ?? '',
                  style: AppTextStyles.regular.copyWith(
                    color: selectedItem != null
                        ? AppColors.text
                        : AppColors.textLighter,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            },
            popupProps: PopupProps.menu(
              constraints: BoxConstraints(
                maxHeight: showSearchBox
                    ? 340
                    : popupMaxHeight ?? (items.length * 48.0).clamp(0, 300),
                minHeight: 96,
              ),
              emptyBuilder: (context, searchEntry) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'ไม่พบข้อมูล',
                      style: AppTextStyles.regular.copyWith(
                        color: AppColors.textLight,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              },
              errorBuilder: (context, searchEntry, exception) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'เกิดข้อผิดพลาดในการค้นหา',
                      style: AppTextStyles.regular.copyWith(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              },
              showSearchBox: showSearchBox,
              searchFieldProps: TextFieldProps(
                style: AppTextStyles.regular.copyWith(
                  color: AppColors.text,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'ค้นหา...',
                  hintStyle: AppTextStyles.regular.copyWith(
                    color: AppColors.textLighter,
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: AppColors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.primary, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.border, width: 1),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.red, width: 1),
                  ),
                ),
              ),
              menuProps: MenuProps(
                clipBehavior: Clip.antiAlias,
                backgroundColor: Colors.white,
                borderRadius: BorderRadius.circular(12),
                elevation: 4,
                shadowColor: Colors.black.withOpacity(0.3),
              ),
              scrollbarProps: const ScrollbarProps(
                radius: Radius.circular(8),
                thumbVisibility: true,
              ),
              listViewProps: const ListViewProps(
                padding: EdgeInsets.symmetric(vertical: 4),
              ),
              itemBuilder: (context, item, isDisabled, isSelected) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.display ?? '-',
                    style: AppTextStyles.regular.copyWith(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.text.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  String _extractTextFromChild(Widget child) {
    if (child is Text) {
      return child.data ?? '';
    } else if (child is Container && child.child != null) {
      return _extractTextFromChild(child.child!);
    }
    return '';
  }
}
