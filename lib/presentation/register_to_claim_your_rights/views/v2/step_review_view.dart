import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rodzendai_form/core/constants/app_text_styles.dart';
import 'package:rodzendai_form/core/utils/date_helper.dart';
import 'package:rodzendai_form/presentation/register/interfaces/patient_type.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/interfaces/register_v2_options.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/providers/register_to_claim_your_rights_v2_provider.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/widgets/v2/register_v2_theme.dart';

/// โทนสีของ badge / ค่าที่เน้น
enum _Tone { positive, warning, negative, info }

extension on _Tone {
  Color get fg => switch (this) {
    _Tone.positive => RegV2Colors.positive,
    _Tone.warning => RegV2Colors.warningText,
    _Tone.negative => RegV2Colors.negative,
    _Tone.info => RegV2Colors.primary,
  };

  Color get bg => switch (this) {
    _Tone.positive => RegV2Colors.positiveSoft,
    _Tone.warning => RegV2Colors.warningSoft,
    _Tone.negative => RegV2Colors.negativeSoft,
    _Tone.info => RegV2Colors.primarySoft,
  };
}

/// ข้อมูลหนึ่งแถวในสรุป
class _Item {
  const _Item(
    this.label,
    this.value, {
    this.highlight = false,
    this.tone,
    this.icon,
  }) : future = null;

  /// ค่าที่ต้องโหลดชื่อจังหวัด/อำเภอ/ตำบลก่อน
  const _Item.async(this.label, Future<String> this.future)
    : value = '',
      highlight = false,
      tone = null,
      icon = null;

  final String label;
  final String? value;

  /// แสดงเป็น pill เด่น (กลุ่มผู้ป่วย / การเดินทาง / สถานะเอกสาร)
  final bool highlight;
  final _Tone? tone;
  final IconData? icon;
  final Future<String>? future;

  bool get isMissing => future == null && (value == null || value!.isEmpty);
}

/// ตรวจสอบก่อนส่งคำขอ — สรุปทุก step พร้อมสถานะและปุ่มแก้ไขแต่ละส่วน
class StepReviewView extends StatelessWidget {
  const StepReviewView({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<RegisterToClaimYourRightsV2Provider>();
    final type = p.patientType;
    String? text(TextEditingController c) =>
        c.text.trim().isEmpty ? null : c.text.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        const _ReviewNotice(),

        _ReviewSection(
          step: RegisterV2Step.category,
          icon: Icons.groups_2_outlined,
          items: [
            _Item(
              'กลุ่มผู้ป่วย',
              type?.titleV2,
              highlight: true,
              icon: Icons.person_pin_outlined,
            ),
            if (type == PatientType.disabled)
              _Item('ประเภทความพิการ', p.disabilityType?.label),
            if (type == PatientType.elderly)
              _Item('ภาวะหลัก', p.elderlyCondition?.label),
            if (type == PatientType.hardship) ...[
              _Item('สาเหตุหลัก', p.difficultyReason?.label),
              ...switch (p.difficultyReason) {
                DifficultyReason.health => [
                  _Item('รายละเอียดสุขภาพ', text(p.healthDetailsController)),
                ],
                DifficultyReason.transport => [
                  _Item(
                    'อุปสรรคการเดินทาง',
                    text(p.transportDetailsController),
                  ),
                ],
                DifficultyReason.resources => [
                  _Item(
                    'รายได้ครอบครัว/เดือน',
                    _baht(p.monthlyIncomeController.text),
                    tone: _Tone.positive,
                  ),
                  _Item(
                    'รายจ่ายครอบครัว/เดือน',
                    _baht(p.monthlyExpensesController.text),
                    tone: _Tone.negative,
                  ),
                  _Item(
                    'ภาพบ้าน',
                    p.housePhotos.isEmpty
                        ? null
                        : '${p.housePhotos.length} ภาพ',
                  ),
                ],
                DifficultyReason.special => [
                  _Item('กลุ่มดูแลพิเศษ', p.specialSubtype?.label),
                  if (p.specialSubtype == SpecialSubtype.other)
                    _Item('รายละเอียด', text(p.specialOtherDetailsController)),
                ],
                null => [],
              },
            ],
          ],
        ),

        _ReviewSection(
          step: RegisterV2Step.transport,
          icon: Icons.directions_car_outlined,
          items: [
            _Item(
              'รูปแบบการเดินทาง',
              p.transportAbility?.titleV2,
              highlight: true,
              icon: p.transportAbility?.iconV2,
            ),
          ],
        ),

        _ReviewSection(
          step: RegisterV2Step.patientInfo,
          icon: Icons.person_outline_rounded,
          items: [
            _Item(
              'ชื่อ–นามสกุล',
              [
                text(p.patientFirstNameController),
                text(p.patientLastNameController),
              ].whereType<String>().join(' '),
            ),
            _Item('เลขประจำตัวประชาชน', text(p.patientIdCardController)),
            _Item(
              'วันเกิด',
              p.dateOfBirth == null
                  ? null
                  : DateHelper.dateThai(p.dateOfBirth!.millisecondsSinceEpoch),
            ),
            _Item(
              'โทรศัพท์',
              text(p.patientPhoneController) ??
                  (p.hasCompanion == true ? '— (ใช้เบอร์ผู้ติดตาม)' : null),
            ),
            if (text(p.patientLineIdController) != null)
              _Item('Line ID', text(p.patientLineIdController)),
            if (text(p.patientHealthNoteController) != null)
              _Item('โรค/อาการสำคัญ', text(p.patientHealthNoteController)),
            _Item(
              'ผู้ติดตาม',
              p.hasCompanion == true
                  ? [
                      text(p.companionFirstNameController),
                      text(p.companionLastNameController),
                      if (p.companionRelation != null)
                        '(${p.companionRelation!.value})',
                      text(p.companionPhoneController),
                    ].whereType<String>().join(' ')
                  : p.hasCompanion == false
                  ? 'ไม่มีผู้ติดตาม'
                  : null,
            ),
            if (text(p.referrerNameController) != null)
              _Item('ผู้แนะนำ', text(p.referrerNameController)),
          ],
        ),

        _ReviewSection(
          step: RegisterV2Step.address,
          icon: Icons.home_outlined,
          items: [
            text(p.registeredAddressController) == null
                ? const _Item('ที่อยู่ตามทะเบียนบ้าน', null)
                : _Item.async(
                    'ที่อยู่ตามทะเบียนบ้าน',
                    p.registeredAddressFullText(),
                  ),
            switch (p.addressSame) {
              null => const _Item('ที่อยู่ปัจจุบัน', null),
              true => const _Item('ที่อยู่ปัจจุบัน', 'ตรงกับทะเบียนบ้าน'),
              false => _Item.async(
                'ที่อยู่ปัจจุบัน',
                p.currentAddressFullText(),
              ),
            },
          ],
        ),

        _ReviewSection(
          step: RegisterV2Step.pickupLocation,
          icon: Icons.place_outlined,
          items: [
            _Item('จุดรับ', text(p.pickupDescriptionController)),
            _Item(
              'พิกัด',
              p.hasPickupPin
                  ? '${p.pickupLatitude!.toStringAsFixed(6)}, '
                        '${p.pickupLongitude!.toStringAsFixed(6)}'
                  : null,
            ),
            if (text(p.pickupLandmarkController) != null)
              _Item('จุดสังเกต', text(p.pickupLandmarkController)),
          ],
        ),

        _ReviewSection(
          step: RegisterV2Step.documents,
          icon: Icons.description_outlined,
          pendingLabel: p.uploadDocumentLater ? 'รอเอกสาร' : null,
          items: [
            _Item(
              'สถานะเอกสาร',
              p.uploadDocumentLater ? 'รอแนบเอกสารภายหลัง' : 'แนบเอกสารแล้ว',
              highlight: true,
              tone: p.uploadDocumentLater ? _Tone.warning : _Tone.positive,
              icon: p.uploadDocumentLater
                  ? Icons.schedule_rounded
                  : Icons.task_alt_rounded,
            ),
            _Item('ไฟล์ที่แนบ', '${_documentCount(p)} ไฟล์'),
          ],
        ),

        _ReviewSection(
          step: RegisterV2Step.confirm,
          icon: Icons.verified_user_outlined,
          pendingLabel: p.requiresAdl && p.adlTotal != null ? 'รอสอบทาน' : null,
          items: [
            if (p.requiresAdl)
              _Item(
                'คะแนน ADL',
                p.adlTotal == null ? null : '${p.adlTotal} / 20',
                tone: _Tone.info,
              ),
            _Item(
              'ยืนยันข้อมูล',
              p.isConfirmationCompleted ? '✓ ยืนยันแล้ว' : null,
              tone: _Tone.positive,
            ),
          ],
        ),
      ],
    );
  }

  static int _documentCount(RegisterToClaimYourRightsV2Provider p) => p
      .filesToSubmit
      .entries
      .where((e) => e.key != 'housePhotos')
      .fold<int>(0, (sum, e) => sum + e.value.length);

  static String? _baht(String raw) {
    final value = RegisterToClaimYourRightsV2Provider.parseAmount(raw);
    if (value == null) return null;
    final fixed = value.toStringAsFixed(value % 1 == 0 ? 0 : 2);
    final parts = fixed.split('.');
    final whole = parts[0].replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
    return '${parts.length > 1 ? '$whole.${parts[1]}' : whole} บาท';
  }
}

// -----------------------------------------------------------------------------
// กล่องคำเตือนก่อนส่ง
// -----------------------------------------------------------------------------

class _ReviewNotice extends StatelessWidget {
  const _ReviewNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: RegV2Colors.warningSoft,
        borderRadius: BorderRadius.circular(RegV2Radius.card),
        border: Border.all(color: RegV2Colors.warningBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 14,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: RegV2Colors.warning.withAlpha(40),
              borderRadius: BorderRadius.circular(RegV2Radius.tile),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: RegV2Colors.warningText,
              size: 26,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                Text(
                  'การส่งคำขอยังไม่ใช่การอนุมัติสิทธิ',
                  style: AppTextStyles.bold.copyWith(
                    fontSize: 17,
                    color: RegV2Colors.warningText,
                  ),
                ),
                Text(
                  'กรุณาตรวจสอบความถูกต้องก่อนส่งคำขอ '
                  'เจ้าหน้าที่จะตรวจสอบคุณสมบัติและความเหมาะสมของรถ แล้วแจ้งผลภายหลัง',
                  style: RegV2Text.body.copyWith(
                    fontSize: 15,
                    height: 1.45,
                    color: RegV2Colors.text,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// การ์ดแต่ละส่วน
// -----------------------------------------------------------------------------

class _ReviewSection extends StatelessWidget {
  const _ReviewSection({
    required this.step,
    required this.icon,
    required this.items,
    this.pendingLabel,
  });

  final RegisterV2Step step;
  final IconData icon;
  final List<_Item> items;

  /// ข้อมูลครบแต่ยังรอดำเนินการ (badge สีส้ม)
  final String? pendingLabel;

  @override
  Widget build(BuildContext context) {
    final missing = items.where((i) => i.isMissing).length;
    final (String badgeText, _Tone badgeTone, IconData badgeIcon) = missing > 0
        ? ('ยังไม่ครบ $missing รายการ', _Tone.negative, Icons.error_outline)
        : pendingLabel != null
        ? (pendingLabel!, _Tone.warning, Icons.schedule_rounded)
        : ('ครบถ้วน', _Tone.positive, Icons.check_circle_outline);

    return Container(
      decoration: BoxDecoration(
        color: RegV2Colors.card,
        borderRadius: BorderRadius.circular(RegV2Radius.card),
        border: Border.all(
          color: missing > 0
              ? RegV2Colors.negative.withAlpha(110)
              : RegV2Colors.border,
        ),
        boxShadow: RegV2Shadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
            child: Row(
              spacing: 12,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: RegV2Colors.primarySoft,
                    borderRadius: BorderRadius.circular(RegV2Radius.tile),
                  ),
                  child: Icon(icon, color: RegV2Colors.primary, size: 22),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      Text(
                        'ขั้นตอนที่ ${(step.index + 1).toString().padLeft(2, '0')}',
                        style: AppTextStyles.medium.copyWith(
                          fontSize: 12,
                          letterSpacing: 0.3,
                          color: RegV2Colors.textSubtle,
                        ),
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            step.title,
                            style: RegV2Text.sectionTitle.copyWith(
                              fontSize: 17,
                            ),
                          ),
                          _Badge(
                            text: badgeText,
                            tone: badgeTone,
                            icon: badgeIcon,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _EditButton(
                  onPressed: () => context
                      .read<RegisterToClaimYourRightsV2Provider>()
                      .goTo(step),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: RegV2Colors.divider),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
            child: Column(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  if (i > 0)
                    const Divider(height: 1, color: RegV2Colors.divider),
                  _ItemRow(items[i]),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EditButton extends StatelessWidget {
  const _EditButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.edit_outlined, size: 16),
      label: const Text('แก้ไข'),
      style: OutlinedButton.styleFrom(
        // พื้นที่กดอย่างน้อย 44px บนมือถือ
        minimumSize: const Size(44, 40),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        foregroundColor: RegV2Colors.primary,
        side: const BorderSide(color: RegV2Colors.primaryBorder),
        textStyle: AppTextStyles.medium.copyWith(fontSize: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RegV2Radius.input),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.tone, this.icon});

  final String text;
  final _Tone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: tone.bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          if (icon != null) Icon(icon, size: 14, color: tone.fg),
          Text(
            text,
            style: AppTextStyles.medium.copyWith(fontSize: 12, color: tone.fg),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// แถวข้อมูล
// -----------------------------------------------------------------------------

class _ItemRow extends StatelessWidget {
  const _ItemRow(this.item);

  final _Item item;

  @override
  Widget build(BuildContext context) {
    final future = item.future;
    if (future != null) {
      return FutureBuilder<String>(
        future: future,
        builder: (context, snapshot) => _layout(
          _valueText(
            snapshot.connectionState == ConnectionState.done
                ? snapshot.data
                : 'กำลังโหลด…',
          ),
        ),
      );
    }
    return _layout(item.highlight ? _highlight() : _valueText(item.value));
  }

  Widget _layout(Widget value) {
    final label = Text(
      item.label,
      style: AppTextStyles.regular.copyWith(
        fontSize: 14,
        color: RegV2Colors.textMuted,
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: LayoutBuilder(
        builder: (context, constraints) => constraints.maxWidth >= 520
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 190,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: label,
                    ),
                  ),
                  Expanded(child: value),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [label, value],
              ),
      ),
    );
  }

  Widget _valueText(String? value) {
    if (value == null || value.isEmpty) return const _MissingValue();
    final tone = item.tone;
    return Text(
      value,
      style: (tone == null ? AppTextStyles.medium : AppTextStyles.bold)
          .copyWith(
            fontSize: 16,
            height: 1.4,
            color: tone?.fg ?? RegV2Colors.text,
          ),
    );
  }

  /// ค่าเด่นแสดงเป็น pill
  Widget _highlight() {
    final value = item.value;
    if (value == null || value.isEmpty) return const _MissingValue();
    final tone = item.tone ?? _Tone.info;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: tone.bg,
          borderRadius: BorderRadius.circular(RegV2Radius.input),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            if (item.icon != null) Icon(item.icon, size: 18, color: tone.fg),
            Flexible(
              child: Text(
                value,
                style: AppTextStyles.bold.copyWith(
                  fontSize: 16,
                  color: tone.fg,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MissingValue extends StatelessWidget {
  const _MissingValue();

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.centerLeft,
      child: _Badge(
        text: 'ยังไม่ได้กรอก',
        tone: _Tone.negative,
        icon: Icons.error_outline,
      ),
    );
  }
}
