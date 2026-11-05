import 'package:flutter/material.dart';
import 'package:rodzendai_form/core/constants/app_text_styles.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/widgets/v2/register_v2_theme.dart';

/// โทนของ dialog กำหนดสีไอคอนและปุ่มหลัก
enum RegV2DialogTone { info, positive, warning, negative }

extension on RegV2DialogTone {
  Color get fg => switch (this) {
    RegV2DialogTone.info => RegV2Colors.primary,
    RegV2DialogTone.positive => RegV2Colors.positive,
    RegV2DialogTone.warning => RegV2Colors.warningText,
    RegV2DialogTone.negative => RegV2Colors.negative,
  };

  Color get bg => switch (this) {
    RegV2DialogTone.info => RegV2Colors.primarySoft,
    RegV2DialogTone.positive => RegV2Colors.positiveSoft,
    RegV2DialogTone.warning => RegV2Colors.warningSoft,
    RegV2DialogTone.negative => RegV2Colors.negativeSoft,
  };

  IconData get icon => switch (this) {
    RegV2DialogTone.info => Icons.help_outline_rounded,
    RegV2DialogTone.positive => Icons.check_circle_outline_rounded,
    RegV2DialogTone.warning => Icons.warning_amber_rounded,
    RegV2DialogTone.negative => Icons.error_outline_rounded,
  };
}

/// แถวสรุปข้อมูลใน dialog (เช่น ชื่อผู้ป่วย วันนัด)
class RegV2DialogDetail {
  const RegV2DialogDetail(this.label, this.value);

  final String label;
  final String value;
}

/// Dialog สไตล์ v2: การ์ดมุมโค้ง ไอคอนในวงกลมสีอ่อน ปุ่มตามธีม v2
///
/// ใช้แทน [AppDialogs] ในหน้าที่ครอบด้วย [registerV2Theme]
abstract final class RegV2Dialogs {
  /// ถามยืนยัน คืนค่า true เมื่อกดปุ่มหลัก, false เมื่อยกเลิก, null เมื่อปิดด้วยวิธีอื่น
  static Future<bool?> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'ยืนยัน',
    String cancelText = 'ยกเลิก',
    List<RegV2DialogDetail> details = const [],
    RegV2DialogTone tone = RegV2DialogTone.info,
    IconData? icon,
  }) {
    return _show<bool>(
      context,
      dismissible: false,
      tone: tone,
      icon: icon,
      title: title,
      message: message,
      details: details,
      primaryText: confirmText,
      secondaryText: cancelText,
    );
  }

  static Future<void> success(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'ตกลง',
    List<RegV2DialogDetail> details = const [],
  }) => _show<void>(
    context,
    tone: RegV2DialogTone.positive,
    title: title,
    message: message,
    details: details,
    primaryText: buttonText,
  );

  static Future<void> warning(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'ตกลง',
  }) => _show<void>(
    context,
    tone: RegV2DialogTone.warning,
    title: title,
    message: message,
    primaryText: buttonText,
  );

  static Future<void> error(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'ตกลง',
  }) => _show<void>(
    context,
    tone: RegV2DialogTone.negative,
    title: title,
    message: message,
    primaryText: buttonText,
  );

  static Future<T?> _show<T>(
    BuildContext context, {
    required RegV2DialogTone tone,
    required String title,
    required String message,
    required String primaryText,
    String? secondaryText,
    List<RegV2DialogDetail> details = const [],
    IconData? icon,
    bool dismissible = true,
  }) {
    // route ของ dialog อยู่นอก Theme ของหน้า จึงส่งธีมจาก context ผู้เรียกเข้าไป
    final theme = Theme.of(context);
    return showDialog<T>(
      context: context,
      barrierDismissible: dismissible,
      barrierColor: const Color(0x8A0F172A),
      builder: (ctx) => Theme(
        data: theme,
        child: _RegV2DialogBody(
          tone: tone,
          icon: icon ?? tone.icon,
          title: title,
          message: message,
          details: details,
          primaryText: primaryText,
          secondaryText: secondaryText,
        ),
      ),
    );
  }
}

class _RegV2DialogBody extends StatelessWidget {
  const _RegV2DialogBody({
    required this.tone,
    required this.icon,
    required this.title,
    required this.message,
    required this.details,
    required this.primaryText,
    this.secondaryText,
  });

  final RegV2DialogTone tone;
  final IconData icon;
  final String title;
  final String message;
  final List<RegV2DialogDetail> details;
  final String primaryText;
  final String? secondaryText;

  @override
  Widget build(BuildContext context) {
    final buttonText = AppTextStyles.medium.copyWith(fontSize: 15.5);

    return Dialog(
      backgroundColor: RegV2Colors.card,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RegV2Radius.card + 4),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 280, maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: tone.bg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 34, color: tone.fg),
                ),
              ),
              Column(
                spacing: 6,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bold.copyWith(
                      fontSize: 20,
                      color: RegV2Colors.text,
                    ),
                  ),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: RegV2Text.muted.copyWith(fontSize: 15, height: 1.5),
                  ),
                ],
              ),
              if (details.isNotEmpty) _DetailList(details),
              const SizedBox(height: 4),
              Row(
                spacing: 12,
                children: [
                  if (secondaryText != null)
                    Expanded(
                      flex: 2,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: RegV2Colors.text,
                          minimumSize: const Size(0, 48),
                          side: const BorderSide(color: RegV2Colors.border),
                          textStyle: buttonText,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              RegV2Radius.tile,
                            ),
                          ),
                        ),
                        child: Text(secondaryText!),
                      ),
                    ),
                  Expanded(
                    flex: 3,
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: FilledButton.styleFrom(
                        backgroundColor: tone == RegV2DialogTone.info
                            ? RegV2Colors.primary
                            : tone.fg,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 48),
                        textStyle: buttonText,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(RegV2Radius.tile),
                        ),
                      ),
                      child: Text(primaryText, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// กล่องสรุปข้อมูล label/value
class _DetailList extends StatelessWidget {
  const _DetailList(this.details);

  final List<RegV2DialogDetail> details;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: RegV2Colors.background,
        borderRadius: BorderRadius.circular(RegV2Radius.tile),
        border: Border.all(color: RegV2Colors.border),
      ),
      child: Column(
        children: [
          for (var i = 0; i < details.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: RegV2Colors.divider),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 12,
                children: [
                  SizedBox(
                    width: 96,
                    child: Text(
                      details[i].label,
                      style: RegV2Text.caption.copyWith(fontSize: 14),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      details[i].value,
                      style: AppTextStyles.medium.copyWith(
                        fontSize: 15,
                        height: 1.4,
                        color: RegV2Colors.text,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
