import 'package:flutter/material.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';
import 'package:rodzendai_form/core/constants/app_text_styles.dart';

/// Design tokens ของหน้าลงทะเบียน v2 (Modern SaaS / โทนฟ้าตาม [AppColors] เดิม)
/// ใช้เฉพาะ v2 เพื่อไม่กระทบหน้าอื่น
abstract final class RegV2Colors {
  // Brand — ฟ้าเดิมของแอป
  static const Color primary = AppColors.primary; // #276CE3
  static const Color primaryHover = AppColors.primaryDark; // #294D95
  static const Color primarySoft = Color(0xFFEAF1FD);
  static const Color primaryBorder = Color(0xFFBCD2F7);
  static const Color accent = AppColors.primary;

  /// Sidebar / แถบขั้นตอน
  static const Color sidebar = AppColors.primaryDark;
  static const Color sidebarMuted = Color(0xFFA9C4F5);

  // Surface
  static const Color background = AppColors.bgColor; // #F5F5F5
  static const Color card = AppColors.cardBg;
  static const Color border = AppColors.border;
  static const Color divider = Color(0xFFEEEEEE);

  // Text
  static const Color text = AppColors.text;
  static const Color textMuted = AppColors.textLight;
  static const Color textSubtle = AppColors.textLighter;

  // Semantic
  static const Color positive = AppColors.success;
  static const Color positiveSoft = Color(0xFFE3F4F1);
  static const Color negative = AppColors.error;
  static const Color negativeSoft = Color(0xFFF8E6E6);
  static const Color warning = AppColors.warning; // #E79A26
  static const Color warningText = Color(0xFFB45309);
  static const Color warningSoft = Color(0xFFFDF3E4);
  static const Color warningBorder = Color(0xFFF5D3A1);
  static const Color info = AppColors.primary;
  static const Color infoSoft = AppColors.bgHeaderCard;
  static const Color infoBorder = AppColors.border;
}

abstract final class RegV2Radius {
  static const double card = 16;
  static const double tile = 12;
  static const double input = 10;
}

abstract final class RegV2Shadows {
  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x0F0F172A), blurRadius: 12, offset: Offset(0, 2)),
    BoxShadow(color: Color(0x0A0F172A), blurRadius: 2, offset: Offset(0, 1)),
  ];
  static const List<BoxShadow> selected = [
    BoxShadow(color: Color(0x29276CE3), blurRadius: 16, offset: Offset(0, 4)),
  ];
}

abstract final class RegV2Text {
  static TextStyle get pageTitle =>
      AppTextStyles.bold.copyWith(fontSize: 22, color: RegV2Colors.text);
  static TextStyle get sectionTitle =>
      AppTextStyles.bold.copyWith(fontSize: 18, color: RegV2Colors.text);
  static TextStyle get body =>
      AppTextStyles.regular.copyWith(fontSize: 16, color: RegV2Colors.text);
  static TextStyle get muted => AppTextStyles.regular.copyWith(
    fontSize: 16,
    color: RegV2Colors.textMuted,
  );
  static TextStyle get caption => AppTextStyles.regular.copyWith(
    fontSize: 13,
    color: RegV2Colors.textSubtle,
  );
}

/// Theme ที่ครอบหน้า v2 ให้ TextFormField / ปุ่ม / ฯลฯ ใช้โทนเดียวกัน
ThemeData registerV2Theme(ThemeData base) {
  final scheme = base.colorScheme.copyWith(
    primary: RegV2Colors.primary,
    onPrimary: Colors.white,
    secondary: RegV2Colors.primaryHover,
    error: RegV2Colors.negative,
    surface: RegV2Colors.card,
  );
  OutlineInputBorder border(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(RegV2Radius.input),
        borderSide: BorderSide(color: color, width: width),
      );

  return base.copyWith(
    colorScheme: scheme,
    scaffoldBackgroundColor: RegV2Colors.background,
    dividerColor: RegV2Colors.divider,
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: RegV2Colors.primary,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      hintStyle: RegV2Text.caption.copyWith(fontSize: 15),
      helperStyle: RegV2Text.caption,
      border: border(RegV2Colors.border),
      enabledBorder: border(RegV2Colors.border),
      focusedBorder: border(RegV2Colors.primary, 1.5),
      errorBorder: border(RegV2Colors.negative),
      focusedErrorBorder: border(RegV2Colors.negative, 1.5),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: RegV2Colors.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: RegV2Colors.border,
        minimumSize: const Size(0, 48),
        textStyle: AppTextStyles.bold.copyWith(fontSize: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RegV2Radius.tile),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: RegV2Colors.text,
        minimumSize: const Size(0, 48),
        side: const BorderSide(color: RegV2Colors.border),
        textStyle: AppTextStyles.medium.copyWith(fontSize: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RegV2Radius.tile),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: RegV2Colors.primary),
    ),
  );
}

/// การ์ดพื้นฐานของ v2: มุมโค้ง 16, border อ่อน, เงาบาง
class RegV2Card extends StatelessWidget {
  const RegV2Card({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: RegV2Colors.card,
        borderRadius: BorderRadius.circular(RegV2Radius.card),
        border: Border.all(color: RegV2Colors.border),
        boxShadow: RegV2Shadows.card,
      ),
      child: child,
    );
  }
}
