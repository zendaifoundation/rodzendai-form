import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rodzendai_form/core/utils/validators.dart';
import 'package:rodzendai_form/models/interfaces/service_type.dart';
import 'package:rodzendai_form/presentation/register/providers/register_provider.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/widgets/v2/choice_card_group.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/widgets/v2/radio_card_group.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/widgets/v2/reg_v2_text_field.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/widgets/v2/register_v2_theme.dart';
import 'package:rodzendai_form/presentation/widgets/district_dropdown.dart';
import 'package:rodzendai_form/presentation/widgets/province_dropdown.dart';
import 'package:rodzendai_form/presentation/widgets/sub_district_dropdown.dart';

/// ไอคอน/คำอธิบายของแต่ละประเภทบริการ (แสดงใน step 4 และหน้าสรุป)
extension ServiceTypeV2 on ServiceType {
  IconData get iconV2 => switch (this) {
    ServiceType.outbound => Icons.local_hospital_rounded,
    ServiceType.inbound => Icons.home_rounded,
    ServiceType.roundTrip => Icons.sync_alt_rounded,
  };

  String get summaryV2 => switch (this) {
    ServiceType.outbound => 'รับจากบ้านไปส่งโรงพยาบาล',
    ServiceType.inbound => 'รับจากโรงพยาบาลกลับบ้าน',
    ServiceType.roundTrip => 'ทั้งขาไปและขากลับ',
  };
}

/// รายละเอียดการเดินทาง — ประเภทบริการ และจุดรับ/ส่งของแต่ละเที่ยว (ใช้ใน step การนัดหมาย)
class TripDetailsSection extends StatelessWidget {
  const TripDetailsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RegisterProvider>();
    final serviceType = provider.serviceTypeSelected;
    final showOutbound =
        serviceType == ServiceType.outbound ||
        serviceType == ServiceType.roundTrip;
    final showInbound =
        serviceType == ServiceType.inbound ||
        serviceType == ServiceType.roundTrip;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 24,
      children: [
        const RegV2SectionHeader(
          icon: Icons.directions_car_outlined,
          title: 'รายละเอียดการเดินทาง',
        ),
        ChoiceCardGroup<ServiceType>(
          label: 'ความต้องการใช้บริการ',
          description: 'เลือกเที่ยวที่ต้องการให้รถรับ–ส่ง',
          requiredMessage: 'กรุณาเลือกความต้องการใช้บริการ',
          value: serviceType,
          onChanged: provider.setServiceTypeSelected,
          options: [
            for (final type in ServiceType.values)
              ChoiceCardOption(
                value: type,
                title: type.displayName,
                summary: type.summaryV2,
                icon: type.iconV2,
              ),
          ],
        ),
        if (serviceType != null)
          const InfoBox(
            text:
                'ที่อยู่ฝั่งโรงพยาบาลจะถูกเติมให้อัตโนมัติตามโรงพยาบาล/คลินิกที่เลือกด้านบน '
                'แก้ไขได้หากไม่ตรง',
          ),
        if (showOutbound)
          _LegSection(
            key: const ValueKey('leg_outbound'),
            title: 'ขาไป',
            subtitle: 'บ้าน → โรงพยาบาล',
            icon: Icons.arrow_circle_right_outlined,
            tone: _LegTone.outbound,
            pickup: _LocationFields(
              title: 'จุดรับผู้ป่วย',
              icon: Icons.my_location_rounded,
              placeLabel: 'สถานที่รับผู้ป่วย',
              placeController: provider.outboundPickupLocationController,
              provinceCode: provider.outboundPickupProvinceCode,
              districtCode: provider.outboundPickupDistrictCode,
              subDistrictCode: provider.outboundPickupSubDistrictCode,
              onProvinceChanged: provider.setOutboundPickupProvinceCode,
              onDistrictChanged: provider.setOutboundPickupDistrictCode,
              onSubDistrictChanged: provider.setOutboundPickupSubDistrictCode,
              landmarkController: provider.outboundPickupLandmarkController,
              sameAsCurrent: provider.outboundPickupSameAsCurrent,
              onSameAsCurrentChanged: provider.setOutboundPickupSameAsCurrent,
            ),
            dropoff: _LocationFields(
              title: 'จุดส่งผู้ป่วย',
              icon: Icons.flag_outlined,
              placeLabel: 'สถานที่ส่งผู้ป่วย',
              placeController: provider.outboundDropoffLocationController,
              provinceCode: provider.outboundDropoffProvinceCode,
              districtCode: provider.outboundDropoffDistrictCode,
              subDistrictCode: provider.outboundDropoffSubDistrictCode,
              onProvinceChanged: provider.setOutboundDropoffProvinceCode,
              onDistrictChanged: provider.setOutboundDropoffDistrictCode,
              onSubDistrictChanged: provider.setOutboundDropoffSubDistrictCode,
              landmarkController: provider.outboundDropoffLandmarkController,
            ),
          ),
        if (showInbound)
          _LegSection(
            key: const ValueKey('leg_inbound'),
            title: 'ขากลับ',
            subtitle: 'โรงพยาบาล → บ้าน',
            icon: Icons.arrow_circle_left_outlined,
            tone: _LegTone.inbound,
            pickup: _LocationFields(
              title: 'จุดรับผู้ป่วย',
              icon: Icons.my_location_rounded,
              placeLabel: 'สถานที่รับผู้ป่วย',
              placeController: provider.inboundPickupLocationController,
              provinceCode: provider.inboundPickupProvinceCode,
              districtCode: provider.inboundPickupDistrictCode,
              subDistrictCode: provider.inboundPickupSubDistrictCode,
              onProvinceChanged: provider.setInboundPickupProvinceCode,
              onDistrictChanged: provider.setInboundPickupDistrictCode,
              onSubDistrictChanged: provider.setInboundPickupSubDistrictCode,
              landmarkController: provider.inboundPickupLandmarkController,
            ),
            dropoff: _LocationFields(
              title: 'จุดส่งผู้ป่วย',
              icon: Icons.flag_outlined,
              placeLabel: 'สถานที่ส่งผู้ป่วย',
              placeController: provider.inboundDropoffLocationController,
              provinceCode: provider.inboundDropoffProvinceCode,
              districtCode: provider.inboundDropoffDistrictCode,
              subDistrictCode: provider.inboundDropoffSubDistrictCode,
              onProvinceChanged: provider.setInboundDropoffProvinceCode,
              onDistrictChanged: provider.setInboundDropoffDistrictCode,
              onSubDistrictChanged: provider.setInboundDropoffSubDistrictCode,
              landmarkController: provider.inboundDropoffLandmarkController,
              sameAsCurrent: provider.inboundDropoffSameAsCurrent,
              onSameAsCurrentChanged: provider.setInboundDropoffSameAsCurrent,
            ),
          ),
      ],
    );
  }
}

/// โทนสีของเที่ยว — ขาไปฟ้า ขากลับส้ม ให้ผู้ใช้แยกได้ทันทีว่าไม่ใช่ฟอร์มซ้ำ
enum _LegTone {
  outbound(
    accent: RegV2Colors.primary,
    text: RegV2Colors.primaryHover,
    soft: RegV2Colors.primarySoft,
    border: RegV2Colors.primaryBorder,
  ),
  inbound(
    accent: RegV2Colors.warning,
    text: RegV2Colors.warningText,
    soft: RegV2Colors.warningSoft,
    border: RegV2Colors.warningBorder,
  );

  const _LegTone({
    required this.accent,
    required this.text,
    required this.soft,
    required this.border,
  });

  final Color accent;
  final Color text;
  final Color soft;
  final Color border;
}

/// กรอบของหนึ่งเที่ยว (ขาไป / ขากลับ) มีจุดรับและจุดส่ง
/// ทั้งกรอบย้อมสีตาม [tone] เพื่อแยกขาไป/ขากลับให้ชัด
class _LegSection extends StatelessWidget {
  const _LegSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.tone,
    required this.pickup,
    required this.dropoff,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final _LegTone tone;
  final Widget pickup;
  final Widget dropoff;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tone.soft,
        borderRadius: BorderRadius.circular(RegV2Radius.card),
        border: Border.all(color: tone.border, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          Row(
            spacing: 12,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: tone.accent,
                  borderRadius: BorderRadius.circular(RegV2Radius.input),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(
                      title,
                      style: RegV2Text.sectionTitle.copyWith(color: tone.text),
                    ),
                    Text(subtitle, style: RegV2Text.caption),
                  ],
                ),
              ),
            ],
          ),
          LayoutBuilder(
            builder: (context, constraints) => constraints.maxWidth >= 720
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 16,
                    children: [
                      Expanded(child: pickup),
                      Expanded(child: dropoff),
                    ],
                  )
                : Column(spacing: 16, children: [pickup, dropoff]),
          ),
        ],
      ),
    );
  }
}

/// ชุดกรอกสถานที่: สถานที่, จังหวัด, อำเภอ, ตำบล, จุดสังเกต
class _LocationFields extends StatelessWidget {
  const _LocationFields({
    required this.title,
    required this.icon,
    required this.placeLabel,
    required this.placeController,
    required this.provinceCode,
    required this.districtCode,
    required this.subDistrictCode,
    required this.onProvinceChanged,
    required this.onDistrictChanged,
    required this.onSubDistrictChanged,
    required this.landmarkController,
    this.sameAsCurrent,
    this.onSameAsCurrentChanged,
  });

  final String title;
  final IconData icon;
  final String placeLabel;
  final TextEditingController placeController;
  final int? provinceCode;
  final int? districtCode;
  final int? subDistrictCode;
  final ValueChanged<int?> onProvinceChanged;
  final ValueChanged<int?> onDistrictChanged;
  final ValueChanged<int?> onSubDistrictChanged;
  final TextEditingController landmarkController;

  /// null = ไม่มีตัวเลือก "ใช้ที่อยู่ปัจจุบันของผู้ป่วย"
  final bool? sameAsCurrent;
  final ValueChanged<bool>? onSameAsCurrentChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RegV2Colors.card,
        borderRadius: BorderRadius.circular(RegV2Radius.card),
        border: Border.all(color: RegV2Colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          Row(
            spacing: 8,
            children: [
              Icon(icon, size: 20, color: RegV2Colors.textMuted),
              Text(title, style: RegV2Text.sectionTitle.copyWith(fontSize: 16)),
            ],
          ),
          if (sameAsCurrent != null && onSameAsCurrentChanged != null)
            RegV2CheckboxTile(
              label: 'ใช้ที่อยู่ปัจจุบันของผู้ป่วย',
              value: sameAsCurrent!,
              onChanged: onSameAsCurrentChanged!,
            ),
          RegV2TextField(
            label: placeLabel,
            controller: placeController,
            hintText: 'สถานที่ บ้านเลขที่ หมู่ที่ หมู่บ้าน อาคาร ซอย ถนน',
            minLines: 2,
            maxLines: 4,
            validator: Validators.required('กรุณากรอก$placeLabel'),
          ),
          ProvinceDropdown(
            label: 'จังหวัด',
            selectedProvinceCode: provinceCode,
            onProvinceChanged: onProvinceChanged,
            validator: Validators.required('กรุณาเลือกจังหวัด'),
          ),
          DistrictDropdown(
            label: 'อำเภอ/เขต',
            provinceCode: provinceCode,
            selectedDistrictCode: districtCode,
            onDistrictChanged: onDistrictChanged,
            validator: Validators.required('กรุณาเลือกอำเภอ/เขต'),
          ),
          SubDistrictDropdown(
            label: 'ตำบล/แขวง',
            districtCode: districtCode,
            selectedSubDistrictCode: subDistrictCode,
            onSubDistrictChanged: onSubDistrictChanged,
            validator: Validators.required('กรุณาเลือกตำบล/แขวง'),
          ),
          RegV2TextField(
            label: 'จุดสังเกต (ถ้ามี)',
            isRequired: false,
            controller: landmarkController,
            hintText: 'เช่น ตรงข้ามร้านสะดวกซื้อ ประตูสีเขียว',
            minLines: 1,
            maxLines: 3,
          ),
        ],
      ),
    );
  }
}
