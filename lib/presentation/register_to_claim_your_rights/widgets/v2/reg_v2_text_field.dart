import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/widgets/v2/radio_card_group.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/widgets/v2/register_v2_theme.dart';

/// ช่องกรอกของ v2: หัวข้อด้านบน + TextFormField ตามธีม
class RegV2TextField extends StatelessWidget {
  const RegV2TextField({
    super.key,
    required this.label,
    this.controller,
    this.isRequired = true,
    this.hintText,
    this.helperText,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
    this.maxLines = 1,
    this.minLines,
  });

  final String label;
  final TextEditingController? controller;
  final bool isRequired;
  final String? hintText;
  final String? helperText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<String>? validator;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon;
  final int maxLines;
  final int? minLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        RegV2FieldLabel(text: label, isRequired: isRequired, fontSize: 16),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          minLines: minLines,
          style: RegV2Text.body,
          decoration: InputDecoration(
            hintText: hintText,
            helperText: helperText,
            suffixIcon: suffixIcon,
          ),
          validator: validator,
        ),
      ],
    );
  }
}

/// วางช่องกรอก 2 ช่องคู่กันเมื่อจอกว้าง จอแคบเรียงลงมา
class RegV2FieldRow extends StatelessWidget {
  const RegV2FieldRow({
    super.key,
    required this.children,
    this.breakpoint = 560,
  });

  final List<Widget> children;
  final double breakpoint;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => constraints.maxWidth >= breakpoint
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16,
              children: [for (final c in children) Expanded(child: c)],
            )
          : Column(spacing: 20, children: children),
    );
  }
}

/// หัวข้อกลุ่มข้อมูลภายใน step
class RegV2SectionHeader extends StatelessWidget {
  const RegV2SectionHeader({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 12,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: RegV2Colors.primarySoft,
            borderRadius: BorderRadius.circular(RegV2Radius.input),
          ),
          child: Icon(icon, color: RegV2Colors.primary, size: 22),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2,
            children: [
              Text(title, style: RegV2Text.sectionTitle),
              if (subtitle != null) Text(subtitle!, style: RegV2Text.caption),
            ],
          ),
        ),
      ],
    );
  }
}
