import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';
import 'package:rodzendai_form/core/constants/app_shadow.dart';
import 'package:rodzendai_form/core/constants/app_text_styles.dart';
import 'package:rodzendai_form/core/services/auth_service.dart';
import 'package:rodzendai_form/presentation/home_page/widgets/card_menu_item.dart';
import 'package:rodzendai_form/widgets/appbar_customer.dart';
import 'package:rodzendai_form/widgets/dialog/app_dialogs.dart';
import 'package:rodzendai_form/widgets/loading_widget.dart';
import 'package:rodzendai_form/widgets/popup_menu_button.dart';
import 'package:rodzendai_form/widgets/version_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();

    // แสดง loading ขณะกำลัง initialize
    if (authService.isLoading) {
      return Scaffold(
        backgroundColor: AppColors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 16,
            children: [
              LoadingWidget(),
              Text('กำลังโหลด...', style: AppTextStyles.regular),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      // appBar: AppBar(
      //   title: const Text(
      //     'บริการรถรับ-ส่งผู้ป่วย',
      //     style: TextStyle(
      //       fontSize: 20,
      //       color: AppColors.white,
      //       fontWeight: FontWeight.bold,
      //     ),
      //   ),
      //   backgroundColor: AppColors.primary,
      //   actions: [
      //     // Show user info if logged in
      //     if (authService.isAuthenticated)
      //       Padding(
      //         padding: const EdgeInsets.only(right: 16),
      //         child: Row(
      //           children: [
      //             if (authService.pictureUrl != null)
      //               LoadingWidget()
      //             else
      //               const CircleAvatar(
      //                 radius: 16,
      //                 child: Icon(Icons.person, size: 18),
      //               ),
      //             const SizedBox(width: 8),
      //             Text(
      //               authService.displayName ?? '-',
      //               style: const TextStyle(
      //                 color: AppColors.white,
      //                 fontSize: 14,
      //               ),
      //             ),
      //             // const SizedBox(width: 12),
      //             // ปุ่ม Logout
      //             // CustomPopupMenuButton(),
      //           ],
      //         ),
      //       ),
      //   ],
      // ),
      appBar: AppBarCustomer(
        title: 'บริการรถรับ-ส่งผู้ป่วย',
        showBackButton: false,
      ),
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              spacing: 24,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildCardHeader(),

                CardMenuItem(
                  imagePath: 'assets/images/img_register.png',
                  title: 'ลงทะเบียนรับสิทธิ์',
                  description: 'สำหรับการลงทะเบียนรับสิทธิ์',
                  onTap: () async {
                    context.go('/register-to-claim-your-rights');
                  },
                ),
                CardMenuItem(
                  imagePath: 'assets/images/img_document.png',
                  title: 'ลงทะเบียนใช้บริการ',
                  description:
                      'สำหรับการจองการใช้บริการรถรับ-ส่งผู้ป่วยตามหมายนัด',
                  onTap: () async {
                    await AppDialogs.warning(
                      context,
                      // message:
                      //     '• กรุณาจองล่วงหน้าอย่างน้อย 24 ชั่วโมง\n• ต้องมีใบนัดหมายแพทย์\n• บริการเฉพาะผู้สูงอายุ คนพิการ และผู้มีความลำบาก',
                      message:
                          '• กรุณาจองล่วงหน้าอย่างน้อย 24 ชั่วโมง\n• บริการรถพยาบาล กรุณาจองล่วงหน้าอย่างน้อย 5 วันทำการ\n• ให้บริการเฉพาะ ผู้สูงอายุ คนพิการ และผู้มีความลำบาก',
                      title: 'ข้อควรทราบ',
                      buttonText: 'เข้าใจแล้ว',
                    );
                    context.go('/register');
                  },
                ),
                CardMenuItem(
                  imagePath: 'assets/images/img_check_status.png',
                  title: 'ตรวจสอบสถานะ',
                  description: 'ค้นหาและตรวจสอบสถานะการจองด้วยเลขบัตรประชาชน',
                  onTap: () {
                    context.go('/register-status');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container _buildCardHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadow.primaryShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 8,
        children: [
          Center(
            child: Image.asset(
              'assets/images/img_logo.png',
              width: 120,
              height: 120,
            ),
          ),
          const Text(
            'ยินดีต้อนรับเข้าสู่ระบบ',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          Divider(color: AppColors.secondary.withOpacity(0.16), thickness: 1),
          const Text(
            'ลงทะเบียน รถเส้นด้าย',
            style: TextStyle(
              fontSize: 19.2,
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              height: 1.6,
            ),
          ),
          const Text(
            'บริการรถรับ-ส่งผู้ป่วยตามหมายนัด',
            style: TextStyle(
              fontSize: 17.5,
              color: AppColors.text,
              fontWeight: FontWeight.w500,
            ),
          ),
          VersionViewWidget(),
        ],
      ),
    );
  }
}
