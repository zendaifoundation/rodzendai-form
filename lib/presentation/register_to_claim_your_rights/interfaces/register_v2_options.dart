// ตัวเลือก radio ของฟอร์มลงทะเบียน v2 ตามสเปก `patient_registration_7_steps_v4`
// `value` คือค่าที่ส่งไป server, `label` คือข้อความที่แสดงผู้ใช้

import 'package:flutter/material.dart';
import 'package:rodzendai_form/presentation/register/interfaces/patient_type.dart';
import 'package:rodzendai_form/presentation/register/interfaces/transport_ability.dart';

/// คำจำกัดความของกลุ่มผู้ป่วย แสดงเป็นข้อความอธิบายก่อนตัวเลือก
extension PatientTypeV2 on PatientType {
  /// ค่า `category` ตามสเปก
  String get categoryValue => switch (this) {
    PatientType.elderly => 'elderly',
    PatientType.disabled => 'disabled',
    PatientType.hardship => 'difficulty',
  };

  String get titleV2 => switch (this) {
    PatientType.elderly => 'ผู้สูงอายุ',
    PatientType.disabled => 'คนพิการ',
    PatientType.hardship => 'ผู้มีความยากลำบาก',
  };

  String? get definition => switch (this) {
    PatientType.elderly =>
      'ผู้ที่มีอายุ 60 ปีขึ้นไป ที่ขาดผู้ดูแลหรือญาติพี่น้องที่สามารถให้การช่วยเหลือได้',
    PatientType.disabled =>
      'ผู้ที่มีความจำเป็นพิเศษที่จะต้องได้รับความช่วยเหลือด้านหนึ่งด้านใด '
          'เพื่อให้สามารถปฏิบัติกิจกรรมในชีวิตประจำวัน '
          'หรือเข้าไปมีส่วนร่วมทางสังคมได้อย่างบุคคลทั่วไป',
    PatientType.hardship => null,
  };

  /// ADL อิงกลุ่มหลักเท่านั้น
  bool get requiresAdl => this == PatientType.elderly;
}

/// `vehicle_request` — ใช้ค่า [TransportAbility] เดิม เปลี่ยนเฉพาะข้อความ
extension TransportAbilityV2 on TransportAbility {
  String get vehicleRequestValue => switch (this) {
    TransportAbility.independent => 'public',
    TransportAbility.dependent => 'ambulance',
  };

  String get titleV2 => switch (this) {
    TransportAbility.independent => 'รถบริการสาธารณะ (รถเก๋ง)',
    TransportAbility.dependent => 'รถพยาบาล',
  };

  String get summaryV2 => switch (this) {
    TransportAbility.independent => 'ช่วยเหลือตัวเองได้ และเดินทางในท่านั่งได้',
    TransportAbility.dependent => 'ผู้ป่วยติดเตียง หรือต้องเดินทางในท่านอน',
  };

  IconData get iconV2 => switch (this) {
    TransportAbility.independent => Icons.directions_car_filled_rounded,
    TransportAbility.dependent => Icons.airport_shuttle_rounded,
  };
}

/// `eligibility.d_type`
enum DisabilityType {
  seeing('seeing', 'ทางการเห็น'),
  hearing('hearing', 'ทางการได้ยินหรือสื่อความหมาย'),
  physical('physical', 'ทางการเคลื่อนไหวหรือทางร่างกาย'),
  mental('mental', 'ทางจิตใจหรือพฤติกรรม'),
  intellectual('intellectual', 'ทางสติปัญญา'),
  learning('learning', 'ทางการเรียนรู้'),
  autism('autism', 'ทางออทิสติก');

  const DisabilityType(this.value, this.label);
  final String value;
  final String label;
}

/// `eligibility.e_condition`
enum ElderlyCondition {
  adl('adl', 'ทำกิจวัตรประจำวันพื้นฐานด้วยตนเองไม่ได้'),
  chronic('chronic', 'มีปัญหาสุขภาพเรื้อรังที่ต้องดูแลต่อเนื่อง'),
  incapacity('incapacity', 'มีภาวะทุพพลภาพทางร่างกายหรือจิตใจ');

  const ElderlyCondition(this.value, this.label);
  final String value;
  final String label;
}

/// `eligibility.r_reason`
enum DifficultyReason {
  health(
    'health',
    'มีข้อจำกัดทางร่างกาย ปัญหาสุขภาพจิต หรือโรคเรื้อรังที่ส่งผลต่อการเดินทาง',
  ),
  transport(
    'transport',
    'อยู่ในพื้นที่ห่างไกลหรือทุรกันดาร หรือเข้าถึงระบบขนส่งสาธารณะได้ยาก',
  ),
  resources(
    'resources',
    'มีฐานะยากจน ไม่สามารถจ่ายค่าเดินทางไปสถานพยาบาลได้ '
        'ขาดผู้ดูแลหรือญาติที่สามารถพาไปรับบริการทางการแพทย์ '
        'มีอุปสรรคด้านการสื่อสารที่ทำให้ไม่สามารถเข้าถึงบริการได้ด้วยตนเอง',
  ),
  special(
    'special',
    'ต้องการการดูแลพิเศษระหว่างเดินทาง หรือกลัวหรือวิตกกังวลอย่างรุนแรง'
        'เกี่ยวกับการออกนอกบ้านหรือการรับบริการทางการแพทย์',
  );

  const DifficultyReason(this.value, this.label);
  final String value;
  final String label;
}

/// `eligibility.special_subtype`
enum SpecialSubtype {
  substanceTreatment('substance_treatment', 'ผู้บำบัดสารเสพติด'),
  psychiatric('psychiatric', 'ผู้ป่วยจิตเวช'),
  violenceAffected('violence_affected', 'ผู้ได้รับผลกระทบจากความรุนแรง'),
  other('other', 'อื่น ๆ');

  const SpecialSubtype(this.value, this.label);
  final String value;
  final String label;
}
