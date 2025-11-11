import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';
import 'package:rodzendai_form/core/constants/app_text_styles.dart';
import 'package:rodzendai_form/presentation/register/widgets/form_header.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/providers/register_to_claim_your_rights_provider.dart';
import 'package:rodzendai_form/widgets/base_card_container.dart';
import 'package:rodzendai_form/widgets/dialog/app_dialogs.dart';
import 'package:rodzendai_form/widgets/radio_group_field.dart';

class FormBarthelActivityAdl extends StatelessWidget {
  const FormBarthelActivityAdl({super.key});

  // คำถาม Barthel ADL Index (10 ข้อ)
  static const List<BarthelQuestion> _barthelQuestions = [
    BarthelQuestion(
      id: 1,
      title: '1. รับประทานอาหารเมื่อเตรียมสํารับไว้ให้เรียบร้อยต่อหน้า',
      options: [
        BarthelOption(score: 0, label: 'ไม่สามารถตักอาหารเข้าปากได้'),
        BarthelOption(
          score: 1,
          label:
              'ตักอาหารเองได้ แต่ต้องมีคนช่วย เช่น ช่วยใช้ช้อนตักเตรียมให้/ตัดเป็นชิ้นเล็กๆให้',
        ),
        BarthelOption(score: 2, label: 'ตักอาหารและช่วยตัวเองได้เป็นปกติ'),
      ],
    ),
    BarthelQuestion(
      id: 2,
      title:
          '2. การล้างหน้า หวีผม แปรงฟัน โกนหนวดในระยะเวลา 24-48 ชั่วโมงที่ผ่านมา',
      options: [
        BarthelOption(score: 0, label: 'ต้องการความช่วยเหลือ'),
        BarthelOption(
          score: 1,
          label: 'ทำได้เอง (รวมทั้งที่ทำได้เองถ้าเตรียมอุปกรณ์ไว้ให้)',
        ),
      ],
    ),
    BarthelQuestion(
      id: 3,
      title: '3. ลุกนั่งจากที่นอน หรือจากเตียงไปยังเก้าอี้',
      options: [
        BarthelOption(
          score: 0,
          label:
              'ไม่สามารถนั่งได้ (นั่งแล้วจะล้มเสมอ) หรือต้องใช้อคน 2 คนช่วยกันยกขึ้น ',
        ),
        BarthelOption(
          score: 1,
          label:
              'ต้องใช้คนแข็งแรงหรือมีทักษะ 1 คน/ใช้คนทั่วไป 2 คนพยุงดันขึ้นมาจึงจะนั่งอยู่ได้',
        ),
        BarthelOption(
          score: 2,
          label:
              'ต้องการความช่วยเหลือบ้าง เช่นช่วยพยุงเล็กน้อย/ต้องมีคนดูแลเพื่อความปลอดภัย',
        ),
        BarthelOption(score: 3, label: 'ทำได้เอง'),
      ],
    ),
    BarthelQuestion(
      id: 4,
      title: '4. การใช้ห้องน้ำ',
      options: [
        BarthelOption(score: 0, label: 'ช่วยตัวเองไม่ได้'),
        BarthelOption(
          score: 1,
          label: 'ทำเองได้บ้างต้องการความช่วยเหลือในบางสิ่ง',
        ),
        BarthelOption(score: 2, label: 'ช่วยเหลือตัวเองได้ดี'),
      ],
    ),
    BarthelQuestion(
      id: 5,
      title: '5. การเคลื่อนที่ภายในห้องหรือบ้าน',
      options: [
        BarthelOption(score: 0, label: 'เคลื่อนที่ไปไหนไม่ได้'),
        BarthelOption(
          score: 1,
          label:
              'ใช้รถเข็นช่วยให้เคลื่อนที่ได้เอง (ไม่ต้องมีคนเข็นให้) เข้าห้องน้ำหรือประตูได้',
        ),
        BarthelOption(
          score: 2,
          label: 'เดินหรือเคลื่อนที่โดยมีคนช่วย เช่น พยุง ',
        ),
        BarthelOption(score: 3, label: 'เดินหรือเคลื่อนที่ได้เอง'),
      ],
    ),
    BarthelQuestion(
      id: 6,
      title: '6. การสวมใส่เสื้อผ้า',
      options: [
        BarthelOption(
          score: 0,
          label: 'ต้องมีคนสวมใส่ให้ ช่วยตัวเองแทบไม่ได้หรือได้น้อย',
        ),
        BarthelOption(
          score: 1,
          label: 'ช่วยตัวเองได้ประมาณร้อยละ 50 ที่เหลือต้องมีคนช่วย',
        ),
        BarthelOption(
          score: 2,
          label:
              'ช่วยตัวเองได้ดี (รวมทั้งการติดกระดุม รูดซิป ใส่เสื้อผ้าที่ดัดแปลงให้เหมาะสมก็ได้) ',
        ),
      ],
    ),
    BarthelQuestion(
      id: 7,
      title: '7. การขึ้นลงบันได 1 ชั้น',
      options: [
        BarthelOption(score: 0, label: 'ไม่สามารถทำได้'),
        BarthelOption(score: 1, label: 'ต้องการคนช่วย'),
        BarthelOption(
          score: 2,
          label:
              'ขึ้นลงได้เอง (ถ้าต้องใช้อุปกรณ์ช่วยเดิน เช่น Walker จะต้องเอาขึ้นลงได้ด้วย)',
        ),
      ],
    ),
    BarthelQuestion(
      id: 8,
      title: '8. การอาบน้ำ',
      options: [
        BarthelOption(score: 0, label: 'ต้องมีคนช่วยหรือทำให้'),
        BarthelOption(score: 1, label: 'อาบน้ำาได้เอง'),
      ],
    ),
    BarthelQuestion(
      id: 9,
      title: '9. การกลั้นการถ่ายอุจจาระ ใน 1 สัปดาห์ที่ผ่านมา ',
      options: [
        BarthelOption(
          score: 0,
          label: 'กลั้นไม่ได้ หรือต้องการการสวนอุจจาระอยู่เสมอ ',
        ),
        BarthelOption(
          score: 1,
          label: 'กลั้นไม่ได้บางครั้ง (ไม่เกิน 1 ครั้งต่อสัปดาห์)',
        ),
        BarthelOption(score: 2, label: 'กลั้นได้เป็นปกติ'),
      ],
    ),
    BarthelQuestion(
      id: 10,
      title: '10. การกลั้นปัสสาวะในระยะ 1 สัปดาห์ที่ผ่านมา ',
      options: [
        BarthelOption(
          score: 0,
          label: 'กลั้นไม่ได้ หรือใส่สายสวนปัสสาวะ แต่ไม่สามารถดูแลเองได้',
        ),
        BarthelOption(
          score: 1,
          label: 'กลั้นไม่ได้บางครั้ง (ไม่เกินวันละ 1 ครั้ง)',
        ),
        BarthelOption(score: 2, label: 'กลั้นได้เป็นปกติ'),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BaseCardContainer(
      child: Consumer<RegisterToClaimYourRightsProvider>(
        builder: (context, registerProvider, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              FormHeaderWidget(
                title:
                    'แบบประเมินกิจวัตรประจําวัน ดัชนีบาร์เธลเอดีแอล (Barthel Activities of Daily Living : ADL)',
              ),
              Text(
                'กรุณาเลือกระดับความสามารถในการทำกิจกรรมประจำวัน',
                style: AppTextStyles.regular.copyWith(
                  fontSize: 14,
                  color: AppColors.textLight,
                ),
              ),

              // Questions
              ..._barthelQuestions.map((question) {
                return _buildQuestionCard(context, question, registerProvider);
              }),

              // Total Score and Result
              _buildScoreResult(context, registerProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildQuestionCard(
    BuildContext context,
    BarthelQuestion question,
    RegisterToClaimYourRightsProvider provider,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          Text(
            question.title,
            style: AppTextStyles.medium.copyWith(fontSize: 16),
          ),
          RadioGroupField<int>(
            key: ValueKey(
              'barthel_${question.id}_${provider.barthelResetCount}',
            ),
            label: '',
            isRequired: true,
            value: provider.getBarthelScore(question.id),
            options: question.options
                .map(
                  (option) =>
                      RadioOption(value: option.score, label: option.label),
                )
                .toList(),
            onChanged: (int? value) {
              if (value != null) {
                provider.setBarthelScore(question.id, value);
              }
            },
            validator: (value) {
              if (value == null) {
                return 'กรุณาเลือกคำตอบ';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildScoreResult(
    BuildContext context,
    RegisterToClaimYourRightsProvider provider,
  ) {
    final totalScore = provider.getTotalBarthelScore();
    final isEligible = totalScore <= 11;
    final hasAnsweredAll =
        _barthelQuestions.length == provider.barthelScores.length;

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: hasAnsweredAll
            ? (isEligible ? AppColors.success : AppColors.error).withOpacity(
                0.1,
              )
            : AppColors.bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasAnsweredAll
              ? (isEligible ? AppColors.success : AppColors.error)
              : AppColors.secondary.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          // Score Display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ผลการประเมิณ',
                style: AppTextStyles.bold.copyWith(fontSize: 18),
              ),
              // Text(
              //   '$totalScore / 100',
              //   style: AppTextStyles.bold.copyWith(
              //     fontSize: 28,
              //     color: hasAnsweredAll
              //         ? (isEligible ? AppColors.success : AppColors.error)
              //         : AppColors.textLight,
              //   ),
              // ),
            ],
          ),

          // Result Message
          if (hasAnsweredAll) ...[
            Divider(color: AppColors.secondary.withOpacity(0.2)),
            Row(
              children: [
                Icon(
                  isEligible ? Icons.check_circle : Icons.cancel,
                  color: isEligible ? AppColors.success : AppColors.error,
                  size: 28,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      Text(
                        isEligible ? 'ใช้บริการได้' : 'ไม่เข้าเกณฑ์',
                        style: AppTextStyles.bold.copyWith(
                          fontSize: 18,
                          color: isEligible
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                      Text(
                        // isEligible
                        //     ? 'คะแนนน้อยกว่าหรือเท่ากับ 11 คะแนน สามารถใช้บริการได้'
                        //     : 'คะแนนมากกว่า 11 คะแนน ไม่สามารถใช้บริการได้',
                        isEligible
                            ? 'สามารถใช้บริการได้'
                            : 'ไม่สามารถใช้บริการได้',
                        style: AppTextStyles.regular.copyWith(
                          fontSize: 14,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Reset Button for ineligible cases
            if (!isEligible) ...[
              SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showResetConfirmation(context, provider);
                  },
                  icon: Icon(Icons.refresh, color: AppColors.white),
                  label: Text(
                    'ทำแบบประเมินใหม่',
                    style: AppTextStyles.medium.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ] else ...[
            // Incomplete message
            Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.textLight, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'กรุณาตอบคำถามให้ครบทุกข้อ (${provider.barthelScores.length}/${_barthelQuestions.length})',
                    style: AppTextStyles.regular.copyWith(
                      fontSize: 14,
                      color: AppColors.textLight,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showResetConfirmation(
    BuildContext context,
    RegisterToClaimYourRightsProvider provider,
  ) async {
    bool? isConfirm = await AppDialogs.confirm(
      context,
      title: 'ยืนยันการทำแบบประเมินใหม่',
      message: 'คุณต้องการล้างคำตอบทั้งหมดและทำแบบประเมินใหม่หรือไม่',
    );
    if (isConfirm == true) {
      provider.resetBarthelScores();
    }
    // showDialog(
    //   context: context,
    //   builder: (BuildContext context) {
    //     return AlertDialog(
    //       title: Text('ยืนยันการทำแบบประเมินใหม่', style: AppTextStyles.bold),
    //       content: Text(
    //         'คุณต้องการล้างคำตอบทั้งหมดและทำแบบประเมินใหม่หรือไม่?',
    //         style: AppTextStyles.regular,
    //       ),
    //       actions: [
    //         TextButton(
    //           onPressed: () => Navigator.of(context).pop(),
    //           child: Text(
    //             'ยกเลิก',
    //             style: AppTextStyles.medium.copyWith(
    //               color: AppColors.textLight,
    //             ),
    //           ),
    //         ),
    //         ElevatedButton(
    //           onPressed: () {
    //             provider.resetBarthelScores();
    //             Navigator.of(context).pop();
    //           },
    //           style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
    //           child: Text(
    //             'ยืนยัน',
    //             style: AppTextStyles.medium.copyWith(color: AppColors.white),
    //           ),
    //         ),
    //       ],
    //     );
    //   },
    // );
  }
}

// Models for Barthel ADL
class BarthelQuestion {
  final int id;
  final String title;
  final List<BarthelOption> options;

  const BarthelQuestion({
    required this.id,
    required this.title,
    required this.options,
  });
}

class BarthelOption {
  final int score;
  final String label;

  const BarthelOption({required this.score, required this.label});
}
