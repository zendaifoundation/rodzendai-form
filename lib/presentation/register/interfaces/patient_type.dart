enum PatientType {
  elderly('ผู้สูงอายุ (60ปีขึ้นไป)', 'ผู้สูงอายุ'),
  disabled('คนพิการ (มีบัตรผู้พิการ)', 'คนพิการ'),
  hardship('ผู้มีความลำบาก (การเคลื่อนไหว/ทุนทรัพย์)', 'ผู้มีความลำบาก');

  final String value;
  final String valueToStore;
  const PatientType(this.value, this.valueToStore);

  @override
  String toString() => value;
}
