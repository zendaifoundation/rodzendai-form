import 'package:flutter/material.dart';
import 'package:rodzendai_form/core/constants/app_text_styles.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/widgets/v2/register_v2_theme.dart';

class RadioCardOption<T> {
  const RadioCardOption({
    required this.value,
    required this.label,
    this.description,
    this.icon,
  });

  final T value;
  final String label;
  final String? description;
  final IconData? icon;
}

/// หัวข้อคำถาม พร้อมเครื่องหมายบังคับ
class RegV2FieldLabel extends StatelessWidget {
  const RegV2FieldLabel({
    super.key,
    required this.text,
    this.isRequired = true,
    this.fontSize = 18,
  });

  final String text;
  final bool isRequired;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: AppTextStyles.bold.copyWith(
          fontSize: fontSize,
          color: RegV2Colors.text,
        ),
        children: [
          TextSpan(text: text),
          if (isRequired)
            const TextSpan(
              text: ' *',
              style: TextStyle(color: RegV2Colors.negative),
            ),
        ],
      ),
    );
  }
}

/// ข้อความ error ใต้ช่องกรอก/กลุ่มตัวเลือก
class RegV2ErrorText extends StatelessWidget {
  const RegV2ErrorText(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 6,
      children: [
        const Icon(Icons.error_outline, size: 16, color: RegV2Colors.negative),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.regular.copyWith(
              fontSize: 14,
              color: RegV2Colors.negative,
            ),
          ),
        ),
      ],
    );
  }
}

/// กลุ่ม radio แบบการ์ด เลือกได้ 1 ค่า กดได้ทั้งแถว ไม่มีค่าเริ่มต้น
///
/// ค่าปัจจุบันมาจาก [value] (provider) เสมอ ส่วน FormField ใช้แค่แสดง error
class RadioCardGroup<T> extends StatelessWidget {
  const RadioCardGroup({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.label,
    this.description,
    this.requiredMessage = 'กรุณาเลือก 1 ข้อ',
  });

  final List<RadioCardOption<T>> options;
  final T? value;
  final ValueChanged<T> onChanged;
  final String? label;
  final String? description;
  final String requiredMessage;

  @override
  Widget build(BuildContext context) {
    return FormField<T>(
      validator: (_) => value == null ? requiredMessage : null,
      builder: (field) {
        return Semantics(
          container: true,
          label: label,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              if (label != null) RegV2FieldLabel(text: label!),
              if (description != null)
                Text(description!, style: RegV2Text.muted),
              for (final option in options)
                _RadioCard<T>(
                  option: option,
                  selected: option.value == value,
                  hasError: field.hasError,
                  onTap: () {
                    onChanged(option.value);
                    field.didChange(option.value);
                    if (field.hasError) field.validate();
                  },
                ),
              if (field.hasError) RegV2ErrorText(field.errorText!),
            ],
          ),
        );
      },
    );
  }
}

class _RadioCard<T> extends StatelessWidget {
  const _RadioCard({
    required this.option,
    required this.selected,
    required this.hasError,
    required this.onTap,
  });

  final RadioCardOption<T> option;
  final bool selected;
  final bool hasError;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected
        ? RegV2Colors.primary
        : hasError
        ? RegV2Colors.negative
        : RegV2Colors.border;

    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      button: true,
      label: option.label,
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: selected ? RegV2Colors.primarySoft : RegV2Colors.card,
          borderRadius: BorderRadius.circular(RegV2Radius.tile),
          border: Border.all(color: borderColor, width: selected ? 1.5 : 1),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(RegV2Radius.tile),
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 56),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  spacing: 12,
                  children: [
                    _RadioDot(selected: selected),
                    if (option.icon != null)
                      Icon(
                        option.icon,
                        size: 28,
                        color: selected
                            ? RegV2Colors.primary
                            : RegV2Colors.textMuted,
                      ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 2,
                        children: [
                          Text(
                            option.label,
                            style:
                                (selected
                                        ? AppTextStyles.bold
                                        : AppTextStyles.medium)
                                    .copyWith(
                                      fontSize: 18,
                                      color: RegV2Colors.text,
                                    ),
                          ),
                          if (option.description != null)
                            Text(option.description!, style: RegV2Text.muted),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(
          color: selected ? RegV2Colors.primary : RegV2Colors.textSubtle,
          width: selected ? 6.5 : 1.5,
        ),
      ),
    );
  }
}

/// กล่องข้อความอธิบาย (คำจำกัดความกลุ่ม / หมายเหตุ) ไม่ใช่คำถาม — ใช้โทนฟ้า (ข้อมูลทั่วไป)
class InfoBox extends StatelessWidget {
  const InfoBox({
    super.key,
    required this.text,
    this.icon = Icons.info_outline,
  });

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: RegV2Colors.infoSoft,
        borderRadius: BorderRadius.circular(RegV2Radius.tile),
        border: Border.all(color: RegV2Colors.infoBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Icon(icon, color: RegV2Colors.info, size: 20),
          Expanded(child: Text(text, style: RegV2Text.body)),
        ],
      ),
    );
  }
}

/// checkbox แบบการ์ด กดได้ทั้งแถว (รูปแบบเดียวกับ [RadioCardGroup])
class RegV2CheckboxTile extends StatelessWidget {
  const RegV2CheckboxTile({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.description,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String label;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: value,
      button: true,
      label: label,
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: value ? RegV2Colors.primarySoft : RegV2Colors.card,
          borderRadius: BorderRadius.circular(RegV2Radius.tile),
          border: Border.all(
            color: value ? RegV2Colors.primary : RegV2Colors.border,
            width: value ? 1.5 : 1,
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(RegV2Radius.tile),
            onTap: () => onChanged(!value),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 56),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  spacing: 12,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: value ? RegV2Colors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: value
                              ? RegV2Colors.primary
                              : RegV2Colors.textSubtle,
                          width: 1.5,
                        ),
                      ),
                      child: value
                          ? const Icon(
                              Icons.check_rounded,
                              size: 16,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 2,
                        children: [
                          Text(
                            label,
                            style:
                                (value
                                        ? AppTextStyles.bold
                                        : AppTextStyles.medium)
                                    .copyWith(
                                      fontSize: 18,
                                      color: RegV2Colors.text,
                                    ),
                          ),
                          if (description != null)
                            Text(description!, style: RegV2Text.muted),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
