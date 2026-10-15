import 'package:flutter/material.dart';
import 'package:rodzendai_form/core/constants/app_text_styles.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/widgets/v2/radio_card_group.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/widgets/v2/register_v2_theme.dart';

class ChoiceCardOption<T> {
  const ChoiceCardOption({
    required this.value,
    required this.title,
    required this.summary,
    required this.icon,
  });

  final T value;
  final String title;
  final String summary;
  final IconData icon;
}

/// ตัวเลือกแบบการ์ดใบใหญ่ (ไอคอน + ชื่อ + คำอธิบาย) เลือกได้ 1 ค่า ไม่มีค่าเริ่มต้น
///
/// จอกว้างตั้งแต่ [horizontalBreakpoint] เรียงแนวนอนสูงเท่ากัน จอแคบเรียงแนวตั้ง
class ChoiceCardGroup<T> extends StatelessWidget {
  const ChoiceCardGroup({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    required this.label,
    this.description,
    this.requiredMessage = 'กรุณาเลือก 1 ข้อ',
    this.horizontalBreakpoint = 640,
  });

  final List<ChoiceCardOption<T>> options;
  final T? value;
  final ValueChanged<T> onChanged;
  final String label;
  final String? description;
  final String requiredMessage;
  final double horizontalBreakpoint;

  @override
  Widget build(BuildContext context) {
    return FormField<T>(
      validator: (_) => value == null ? requiredMessage : null,
      builder: (field) {
        Widget card(ChoiceCardOption<T> option, {required bool compact}) =>
            _ChoiceCard(
              title: option.title,
              summary: option.summary,
              icon: option.icon,
              selected: value == option.value,
              hasError: field.hasError,
              compact: compact,
              onTap: () {
                onChanged(option.value);
                field.didChange(option.value);
                if (field.hasError) field.validate();
              },
            );

        return Semantics(
          container: true,
          label: label,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              RegV2FieldLabel(text: label),
              if (description != null)
                Text(description!, style: RegV2Text.muted),
              const SizedBox(height: 4),
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth >= horizontalBreakpoint) {
                    return IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: 16,
                        children: [
                          for (final option in options)
                            Expanded(child: card(option, compact: false)),
                        ],
                      ),
                    );
                  }
                  return Column(
                    spacing: 12,
                    children: [
                      for (final option in options) card(option, compact: true),
                    ],
                  );
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

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.title,
    required this.summary,
    required this.icon,
    required this.selected,
    required this.hasError,
    required this.compact,
    required this.onTap,
  });

  final String title;
  final String summary;
  final IconData icon;
  final bool selected;
  final bool hasError;

  /// true = จอแคบ วางไอคอนซ้าย ข้อความขวา
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected
        ? RegV2Colors.primary
        : hasError
        ? RegV2Colors.negative
        : RegV2Colors.border;

    final iconBox = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: compact ? 52 : 64,
      height: compact ? 52 : 64,
      decoration: BoxDecoration(
        color: selected ? RegV2Colors.primary : RegV2Colors.primarySoft,
        borderRadius: BorderRadius.circular(RegV2Radius.tile),
      ),
      child: Icon(
        icon,
        size: compact ? 28 : 34,
        color: selected ? Colors.white : RegV2Colors.primary,
      ),
    );

    final texts = Column(
      crossAxisAlignment: compact
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        Text(
          title,
          textAlign: compact ? TextAlign.start : TextAlign.center,
          style: AppTextStyles.bold.copyWith(
            fontSize: 18,
            color: selected ? RegV2Colors.primaryHover : RegV2Colors.text,
          ),
        ),
        Text(
          summary,
          textAlign: compact ? TextAlign.start : TextAlign.center,
          style: AppTextStyles.regular.copyWith(
            fontSize: 16,
            height: 1.4,
            color: RegV2Colors.textMuted,
          ),
        ),
      ],
    );

    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      button: true,
      label: '$title: $summary',
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: selected ? RegV2Colors.primarySoft : RegV2Colors.card,
          borderRadius: BorderRadius.circular(RegV2Radius.card),
          border: Border.all(color: borderColor, width: selected ? 2 : 1),
          boxShadow: selected ? RegV2Shadows.selected : RegV2Shadows.card,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(RegV2Radius.card),
            onTap: onTap,
            child: Stack(
              children: [
                Padding(
                  padding: compact
                      ? const EdgeInsets.fromLTRB(16, 16, 44, 16)
                      : const EdgeInsets.fromLTRB(20, 28, 20, 24),
                  child: compact
                      ? Row(
                          spacing: 16,
                          children: [
                            iconBox,
                            Expanded(child: texts),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          spacing: 16,
                          children: [iconBox, texts],
                        ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: _CheckBadge(selected: selected),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckBadge extends StatelessWidget {
  const _CheckBadge({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? RegV2Colors.primary : Colors.white,
        border: Border.all(
          color: selected ? RegV2Colors.primary : RegV2Colors.border,
          width: 1.5,
        ),
      ),
      child: selected
          ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
          : null,
    );
  }
}
