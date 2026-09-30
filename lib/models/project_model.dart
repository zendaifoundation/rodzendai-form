import 'package:rodzendai_form/models/closed_date_range.dart';

class ProjectModel {
  final String id;
  final String name;
  final String? description;
  final String? status;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? maxUsage;
  final num? pricePerTrip;
  final num? taxiPricePerTrip;
  final num? nursePricePerTrip;
  final List<ClosedDateRange> closedDates;

  ProjectModel({
    required this.id,
    required this.name,
    this.description,
    this.status,
    this.startDate,
    this.endDate,
    this.maxUsage,
    this.pricePerTrip,
    this.taxiPricePerTrip,
    this.nursePricePerTrip,
    this.closedDates = const [],
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is String && value.isEmpty) return null;
      return DateTime.tryParse(value.toString());
    }

    return ProjectModel(
      id: json['id'] as String,
      name: (json['name'] as String?) ?? '',
      description: json['description'] as String?,
      status: json['status'] as String?,
      startDate: parseDate(json['startDate']),
      endDate: parseDate(json['endDate']),
      maxUsage: (json['maxUsage'] as num?)?.toInt(),
      pricePerTrip: json['pricePerTrip'] as num?,
      taxiPricePerTrip: json['taxiPricePerTrip'] as num?,
      nursePricePerTrip: json['nursePricePerTrip'] as num?,
      closedDates: ClosedDateRange.listFromJson(json['closedDates']),
    );
  }

  bool get isActive => status == 'active';
}
