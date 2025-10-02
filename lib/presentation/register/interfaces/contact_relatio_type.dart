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
