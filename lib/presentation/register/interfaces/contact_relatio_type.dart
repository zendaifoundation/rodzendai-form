import 'package:collection/collection.dart';

enum ContactRelationType {
  self('ตนเอง'),
  father('บิดา'),
  mother('มารดา'),
  child('บุตร'),
  spouse('คู่สมรส'),
  relative('ญาติ'),
  friend('เพื่อน'),
  network('ภาคีเครือข่าย');

  final String value;

  const ContactRelationType(this.value);
}

extension ContactRelationTypeExtension on ContactRelationType {
  static ContactRelationType? fromValue(String? value) {
    if (value == null) return null;
    return ContactRelationType.values.firstWhereOrNull(
      (element) => element.value == value,
    );
  }
}
