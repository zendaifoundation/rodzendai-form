enum PatientType {
  elderly('ผู้สูงอายุ (60ปีขึ้นไป)'),
  disabled('คนพิการ (มีบัตรผู้พิการ)'),
  hardship('ผู้มีความลำบาก (การเคลื่อนไหว/ทุนทรัพย์)');

  final String value;
  const PatientType(this.value);

  @override
  String toString() => value;
}
