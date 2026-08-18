import 'package:flutter/material.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';
import 'package:rodzendai_form/core/constants/app_text_styles.dart';

class PdpaDetailDialog {
  static Future<void> show(BuildContext context) async {
    return await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with gradient background
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.shield_outlined,
                        color: AppColors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'นโยบายคุ้มครอง\nข้อมูลส่วนบุคคล',
                        style: AppTextStyles.bold.copyWith(
                          fontSize: 18,
                          color: AppColors.white,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPdpaSection(
                        icon: Icons.description_outlined,
                        title: 'วัตถุประสงค์ในการเก็บรวบรวมข้อมูล',
                        content:
                            '• การลงทะเบียนผู้ป่วยและให้บริการทางการแพทย์\n'
                            '• การติดต่อประสานงานและนัดหมาย\n'
                            '• การบันทึกประวัติการรักษา\n'
                            '• การปรับปรุงคุณภาพการบริการ',
                      ),
                      const SizedBox(height: 20),
                      _buildPdpaSection(
                        icon: Icons.folder_outlined,
                        title: 'ข้อมูลที่เก็บรวบรวม',
                        content:
                            '• ข้อมูลส่วนบุคคล (ชื่อ-นามสกุล, เลขบัตรประชาชน, วันเกิด)\n'
                            '• ข้อมูลติดต่อ (เบอร์โทรศัพท์, ที่อยู่, Line ID)\n'
                            '• ข้อมูลสุขภาพ (ประเภทผู้ป่วย, ความสามารถในการเดินทาง)\n'
                            '• เอกสารประกอบ (บัตรประชาชน, บัตรคนพิการ, บัตรสวัสดิการ)',
                      ),
                      const SizedBox(height: 20),
                      _buildPdpaSection(
                        icon: Icons.security_outlined,
                        title: 'การเก็บรักษาความปลอดภัย',
                        content:
                            'ข้อมูลของท่านจะถูกเก็บรักษาอย่างปลอดภัยตามมาตรฐาน '
                            'การรักษาความมั่นคงปลอดภัยด้านเทคโนโลยีสารสนเทศ '
                            'และจะไม่ถูกเปิดเผยต่อบุคคลภายนอกโดยไม่ได้รับความยินยอม '
                            'เว้นแต่เป็นไปตามที่กฎหมายกำหนด',
                      ),
                      const SizedBox(height: 20),
                      _buildPdpaSection(
                        icon: Icons.verified_user_outlined,
                        title: 'สิทธิของเจ้าของข้อมูล',
                        content:
                            'ท่านมีสิทธิในการเข้าถึง แก้ไข ลบ หรือขอสำเนาข้อมูล '
                            'ส่วนบุคคลของท่านได้ตามที่กฎหมายกำหนด',
                      ),
                    ],
                  ),
                ),
              ),
              // Footer
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      offset: const Offset(0, -2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'ตกลง',
                      style: AppTextStyles.bold.copyWith(
                        fontSize: 16,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildPdpaSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.bold.copyWith(
                    fontSize: 15,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: AppTextStyles.regular.copyWith(
              fontSize: 14,
              height: 1.6,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
