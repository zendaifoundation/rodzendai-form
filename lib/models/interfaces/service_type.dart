enum ServiceType {
  outbound('ขาไป', 'ขาไป (ไปโรงพยาบาล)'),
  inbound('ขากลับ', 'ขากลับ (กลับจากโรงพยาบาล)'),
  roundTrip('ขาไป-ขากลับ', 'ขาไป-ขากลับ');

  const ServiceType(this.value, this.displayName);

  final String value;
  final String displayName;

  /// แปลงจาก value string เป็น ServiceType
  static ServiceType? fromValue(String? value) {
    if (value == null || value.isEmpty) return null;

    try {
      return ServiceType.values.firstWhere((type) => type.value == value);
    } catch (e) {
      return null;
    }
  }

  /// ดึง displayName จาก value
  static String getDisplayName(String? value) {
    final type = fromValue(value);
    return type?.displayName ?? '';
  }
}
