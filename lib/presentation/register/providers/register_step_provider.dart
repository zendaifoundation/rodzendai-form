import 'package:flutter/material.dart';
import 'package:rodzendai_form/presentation/register/providers/register_provider.dart';

/// ขั้นตอนของฟอร์มจองคิวใช้บริการ v2 (3 step) กด "จองคิวรถ" ท้าย step 3
enum RegisterBookingStep {
  patient('ข้อมูลผู้ป่วย'),
  appointment('การนัดหมาย'),
  contact('ผู้แจ้งและผู้ติดตาม');

  const RegisterBookingStep(this.title);
  final String title;
}

/// จัดการการเดินหน้า/ย้อนกลับระหว่าง step ของ [RegisterPageV2]
///
/// ข้อมูลฟอร์มทั้งหมดยังอยู่ใน [RegisterProvider] เดิม (payload / validation
/// ทางธุรกิจไม่เปลี่ยน) ตัวนี้ดูแลเฉพาะ step index, form key ของแต่ละ step
/// และ step ที่ผ่าน validate แล้ว
class RegisterStepProvider extends ChangeNotifier {
  RegisterStepProvider({required RegisterProvider registerProvider})
    : _registerProvider = registerProvider {
    for (final step in RegisterBookingStep.values) {
      _formKeys[step] = GlobalKey<FormState>();
    }
  }

  final RegisterProvider _registerProvider;

  final Map<RegisterBookingStep, GlobalKey<FormState>> _formKeys = {};
  GlobalKey<FormState> formKeyOf(RegisterBookingStep step) => _formKeys[step]!;

  List<RegisterBookingStep> get steps => RegisterBookingStep.values;

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;
  RegisterBookingStep get currentStep => steps[_currentIndex];

  bool get isFirstStep => _currentIndex == 0;
  bool get isLastStep => _currentIndex == steps.length - 1;

  /// step ที่ผ่าน validate แล้ว ใช้แสดงเครื่องหมายใน step indicator
  final Set<RegisterBookingStep> _completedSteps = {};
  bool isStepCompleted(RegisterBookingStep step) =>
      _completedSteps.contains(step);

  /// validate step ปัจจุบัน ถ้าผ่านให้ไป step ถัดไป คืนค่า false ถ้าไม่ผ่าน
  bool next() {
    if (!validateStep(currentStep)) return false;
    _completedSteps.add(currentStep);
    if (!isLastStep) {
      _currentIndex++;
      notifyListeners();
    }
    return true;
  }

  void back() {
    if (isFirstStep) return;
    _currentIndex--;
    notifyListeners();
  }

  /// กระโดดไป step ที่ต้องการ อนุญาตเฉพาะ step ก่อนหน้า
  /// หรือ step ที่ทุก step ก่อนหน้าผ่านแล้ว
  void goTo(RegisterBookingStep step) {
    final index = steps.indexOf(step);
    if (index < 0 || index == _currentIndex) return;
    final canJump =
        index < _currentIndex ||
        steps.take(index).every(_completedSteps.contains);
    if (!canJump) return;
    _currentIndex = index;
    notifyListeners();
  }

  /// ล้างสถานะ "ผ่านแล้ว" ของ step หลัง [step] เช่น เมื่อตรวจสอบเลขบัตรใหม่
  /// แล้วข้อมูลนัดหมาย/ผู้ติดตามถูกรีเซ็ต
  void invalidateAfter(RegisterBookingStep step) {
    final stale = _completedSteps.where((s) => s.index > step.index).toList();
    if (stale.isEmpty) return;
    _completedSteps.removeAll(stale);
    notifyListeners();
  }

  bool validateStep(RegisterBookingStep step) {
    final formValid = _formKeys[step]?.currentState?.validate() ?? true;
    return switch (step) {
      RegisterBookingStep.patient =>
        formValid && _registerProvider.patientData != null,
      // รายละเอียดการเดินทาง (ประเภทบริการ + จุดรับ/ส่ง) อยู่ใน step นี้
      RegisterBookingStep.appointment =>
        formValid && _registerProvider.serviceTypeSelected != null,
      _ => formValid,
    };
  }
}
