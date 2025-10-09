enum TransportAbility {
  independent('ช่วยเหลือตัวเองได้ (ใช้บริการรถแท็กซี่)', 'ช่วยเหลือตัวเองได้'),
  dependent('ช่วยเหลือตัวเองไม่ได้ (ต้องใช้รถพยาบาล)', 'ช่วยเหลือตัวเองไม่ได้');

  final String value;
  final String valueToStore;

  const TransportAbility(this.value, this.valueToStore);

  @override
  String toString() => value;
}
