import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rodzendai_form/core/constants/app_text_styles.dart';
import 'package:rodzendai_form/core/utils/date_helper.dart';
import 'package:rodzendai_form/core/utils/input_formatters.dart';
import 'package:rodzendai_form/core/utils/validators.dart';
import 'package:rodzendai_form/presentation/register/interfaces/contact_relatio_type.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/blocs/check_eligibility_bloc/check_eligibility_bloc.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/providers/register_to_claim_your_rights_v2_provider.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/widgets/v2/radio_card_group.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/widgets/v2/reg_v2_dialogs.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/widgets/v2/reg_v2_text_field.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/widgets/v2/register_v2_theme.dart';
import 'package:rodzendai_form/widgets/dialog/date_picker.dart';
import 'package:rodzendai_form/widgets/dialog/loading_dialog.dart';

String? _requiredText(String? value) =>
    (value ?? '').trim().isEmpty ? 'กรุณากรอกข้อมูล' : null;

/// เบอร์ไทย 9–10 หลักหลังตัดช่องว่าง/ขีด
bool _isValidPhone(String? value) => RegExp(
  r'^\d{9,10}$',
).hasMatch((value ?? '').replaceAll(RegExp(r'[\s-]'), ''));

/// Step 3 — รายละเอียดผู้ป่วยและผู้ติดตาม
class StepPatientInfoView extends StatefulWidget {
  const StepPatientInfoView({super.key});

  @override
  State<StepPatientInfoView> createState() => _StepPatientInfoViewState();
}

class _StepPatientInfoViewState extends State<StepPatientInfoView> {
  final _checkEligibilityBloc = CheckEligibilityBloc();
  final _dateOfBirthController = TextEditingController();

  /// กัน pop ซ้ำ: LoadingDialog.hide ใช้ Navigator.pop ถ้าไม่มี dialog เปิดอยู่
  /// จะไป pop หน้าลงทะเบียนเองทิ้ง (เด้งกลับหน้าแรก)
  bool _isLoadingShown = false;

  void _showLoading() {
    if (_isLoadingShown) return;
    _isLoadingShown = true;
    LoadingDialog.show(context);
  }

  void _hideLoading() {
    if (!_isLoadingShown) return;
    _isLoadingShown = false;
    LoadingDialog.hide(context);
  }

  @override
  void dispose() {
    _checkEligibilityBloc.close();
    _dateOfBirthController.dispose();
    super.dispose();
  }

  Future<void> _pickDateOfBirth(
    RegisterToClaimYourRightsV2Provider provider,
  ) async {
    final results = await DatePickerDialogCustom.showThai(
      context,
      value: [provider.dateOfBirth],
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (results == null || results.isEmpty || results.first == null) return;
    provider.setDateOfBirth(results.first);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RegisterToClaimYourRightsV2Provider>();
    final dob = provider.dateOfBirth;
    _dateOfBirthController.text = dob == null
        ? ''
        : DateHelper.dateThai(dob.millisecondsSinceEpoch);
    final hasCompanion = provider.hasCompanion == true;

    return BlocListener<CheckEligibilityBloc, CheckEligibilityState>(
      bloc: _checkEligibilityBloc,
      listener: (context, state) async {
        switch (state) {
          case CheckEligibilityInitial():
            break;
          case CheckEligibilityLoading():
            _showLoading();
          case CheckEligibilitySuccess():
            _hideLoading();
            provider.markIdCardChecked();
          case CheckEligibilityFailure():
            _hideLoading();
            await RegV2Dialogs.error(
              context,
              title: 'ไม่สามารถลงทะเบียนได้',
              message: state.message,
            );
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 20,
        children: [
          const RegV2SectionHeader(
            icon: Icons.person_outline_rounded,
            title: 'ข้อมูลผู้ป่วย',
          ),
          _IdCardField(
            provider: provider,
            onCheck: () => _checkEligibilityBloc.add(
              CheckRegisterRequestEvent(
                idCardNumber: provider.patientIdCardController.text.trim(),
              ),
            ),
          ),
          RegV2FieldRow(
            children: [
              RegV2TextField(
                label: 'ชื่อ',
                controller: provider.patientFirstNameController,
                validator: _requiredText,
              ),
              RegV2TextField(
                label: 'นามสกุล',
                controller: provider.patientLastNameController,
                validator: _requiredText,
              ),
            ],
          ),
          RegV2FieldRow(
            children: [
              RegV2TextField(
                label: 'วันเดือนปีเกิด',
                controller: _dateOfBirthController,
                readOnly: true,
                hintText: 'เลือกวันเกิด',
                suffixIcon: const Icon(Icons.calendar_today_rounded, size: 18),
                onTap: () => _pickDateOfBirth(provider),
                validator: (_) {
                  if (dob == null) return 'กรุณาเลือกวันเกิด';
                  if (dob.isAfter(DateTime.now())) {
                    return 'วันเกิดต้องไม่เป็นวันในอนาคต';
                  }
                  return null;
                },
              ),
              RegV2TextField(
                label: 'โทรศัพท์ที่ติดต่อได้',
                isRequired: !hasCompanion,
                controller: provider.patientPhoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: InputFormatters.phone,
                hintText: '0812345678',
                helperText: hasCompanion
                    ? 'ไม่บังคับ หากมีเบอร์ผู้ติดตามแล้ว'
                    : null,
                validator: (value) {
                  if ((value ?? '').trim().isEmpty) {
                    return hasCompanion
                        ? null
                        : 'ต้องมีเบอร์ติดต่อของผู้ป่วยหรือผู้ติดตามอย่างน้อย 1 หมายเลข';
                  }
                  return _isValidPhone(value)
                      ? null
                      : 'เบอร์โทรศัพท์ต้องเป็นตัวเลข 9–10 หลัก';
                },
              ),
            ],
          ),
          RegV2TextField(
            label: 'Line ID (ถ้ามี)',
            isRequired: false,
            controller: provider.patientLineIdController,
          ),
          RegV2TextField(
            label: 'โรคหรืออาการสำคัญ (ถ้ามี)',
            isRequired: false,
            controller: provider.patientHealthNoteController,
            hintText: 'เช่น เบาหวาน ความดันโลหิตสูง ฟอกไต',
            minLines: 2,
            maxLines: 4,
          ),

          const Divider(height: 24),

          const RegV2SectionHeader(
            icon: Icons.people_outline_rounded,
            title: 'ผู้ติดตามระหว่างเดินทาง',
            subtitle: 'อาจเป็นคนละคนกับผู้ดูแลประจำ',
          ),
          RadioCardGroup<bool>(
            label: 'มีผู้ติดตามระหว่างเดินทางหรือไม่?',
            value: provider.hasCompanion,
            onChanged: provider.setHasCompanion,
            options: const [
              RadioCardOption(value: true, label: 'มีผู้ติดตาม'),
              RadioCardOption(value: false, label: 'ไม่มีผู้ติดตาม'),
            ],
          ),
          if (hasCompanion) _CompanionFields(provider),

          const Divider(height: 24),

          // RegV2TextField(
          //   label: 'ชื่อผู้แนะนำ (ถ้ามี)',
          //   isRequired: false,
          //   controller: provider.referrerNameController,
          // ),
        ],
      ),
    );
  }
}

class _IdCardField extends StatelessWidget {
  const _IdCardField({required this.provider, required this.onCheck});

  final RegisterToClaimYourRightsV2Provider provider;
  final VoidCallback onCheck;

  @override
  Widget build(BuildContext context) {
    final checked = provider.isIdCardChecked;

    final field = TextFormField(
      controller: provider.patientIdCardController,
      keyboardType: TextInputType.number,
      inputFormatters: InputFormatters.citizenId,
      style: RegV2Text.body.copyWith(letterSpacing: 1),
      decoration: InputDecoration(
        hintText: 'เลขบัตรประชาชน 13 หลัก',
        suffixIcon: checked
            ? const Icon(Icons.verified_rounded, color: RegV2Colors.positive)
            : null,
      ),
      validator: (value) =>
          Validators.validateIdCardNumber(value?.trim()) ??
          (checked ? null : 'กรุณากด "ตรวจสอบข้อมูล" ก่อนไปขั้นตอนถัดไป'),
    );

    final button = ValueListenableBuilder(
      valueListenable: provider.patientIdCardController,
      builder: (context, value, _) => SizedBox(
        height: 50,
        child: FilledButton.icon(
          onPressed: value.text.trim().length == 13 && !checked
              ? onCheck
              : null,
          icon: const Icon(Icons.search_rounded, size: 20),
          label: const Text('ตรวจสอบข้อมูล'),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        const RegV2FieldLabel(text: 'เลขประจำตัวประชาชน', fontSize: 16),
        LayoutBuilder(
          builder: (context, constraints) => constraints.maxWidth >= 480
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 12,
                  children: [
                    Expanded(child: field),
                    button,
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 10,
                  children: [field, button],
                ),
        ),
        if (checked)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: RegV2Colors.positiveSoft,
              borderRadius: BorderRadius.circular(RegV2Radius.input),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  size: 18,
                  color: RegV2Colors.positive,
                ),
                Flexible(
                  child: Text(
                    'ตรวจสอบแล้ว เลขบัตรนี้สามารถลงทะเบียนได้',
                    style: AppTextStyles.medium.copyWith(
                      fontSize: 14,
                      color: RegV2Colors.positive,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _CompanionFields extends StatelessWidget {
  const _CompanionFields(this.provider);

  final RegisterToClaimYourRightsV2Provider provider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: RegV2Colors.background,
        borderRadius: BorderRadius.circular(RegV2Radius.card),
        border: Border.all(color: RegV2Colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 20,
        children: [
          RegV2FieldRow(
            children: [
              RegV2TextField(
                label: 'ชื่อผู้ติดตาม',
                controller: provider.companionFirstNameController,
                validator: _requiredText,
              ),
              RegV2TextField(
                label: 'นามสกุลผู้ติดตาม',
                controller: provider.companionLastNameController,
                validator: _requiredText,
              ),
            ],
          ),
          RegV2FieldRow(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  const RegV2FieldLabel(text: 'ความสัมพันธ์', fontSize: 16),
                  DropdownButtonFormField<ContactRelationType>(
                    initialValue: provider.companionRelation,
                    isExpanded: true,
                    hint: Text('เลือกความสัมพันธ์', style: RegV2Text.caption),
                    style: RegV2Text.body,
                    borderRadius: BorderRadius.circular(RegV2Radius.tile),
                    items: [
                      // ผู้ติดตามไม่ใช่ตัวผู้ป่วยเอง
                      for (final relation in ContactRelationType.values.where(
                        (r) => r != ContactRelationType.self,
                      ))
                        DropdownMenuItem(
                          value: relation,
                          child: Text(relation.value),
                        ),
                    ],
                    onChanged: provider.setCompanionRelation,
                    validator: (value) =>
                        value == null ? 'กรุณาเลือกความสัมพันธ์' : null,
                  ),
                ],
              ),
              RegV2TextField(
                label: 'โทรศัพท์ผู้ติดตาม',
                controller: provider.companionPhoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: InputFormatters.phone,
                hintText: '0812345678',
                validator: (value) {
                  if ((value ?? '').trim().isEmpty) return 'กรุณากรอกข้อมูล';
                  return _isValidPhone(value)
                      ? null
                      : 'เบอร์โทรศัพท์ต้องเป็นตัวเลข 9–10 หลัก';
                },
              ),
            ],
          ),
          RegV2TextField(
            label: 'เลขบัตรประชาชนผู้ติดตาม (ถ้ามี)',
            isRequired: false,
            controller: provider.companionIdCardController,
            keyboardType: TextInputType.number,
            inputFormatters: InputFormatters.citizenId,
            validator: (value) => (value ?? '').trim().isEmpty
                ? null
                : Validators.validateIdCardNumber(value?.trim()),
          ),
        ],
      ),
    );
  }
}
