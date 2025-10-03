enum TransportAbility {
  independent('ช่วยเหลือตัวเองได้ (ใช้บริการรถแท็กซี่)'),
  dependent('ช่วยเหลือตัวเองไม่ได้ (ต้องใช้รถพยาบาล)');

  final String value;
  const TransportAbility(this.value);

  @override
  String toString() => value;
}
