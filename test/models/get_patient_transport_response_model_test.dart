import 'package:flutter_test/flutter_test.dart';
import 'package:rodzendai_form/models/get_patient_transport_response_model.dart';

void main() {
  group('PatientTransport date parsing', () {
    // เคสจริงจาก production: single trip ที่ admin ไม่ได้กรอกขากลับ
    // ทำให้ service_date2 เป็น "" แล้ว DateTime.parse ระเบิด
    test('blank service_date2 ("") ไม่ทำให้ parse ล้ม', () {
      final json = {
        "code": "00",
        "success": true,
        "data": [
          {
            "id": "3gNXNgPDssnBOaYlglNR",
            "recorded_date": "2026-07-09",
            "travel_mode": {
              "service_date": "2026-07-09",
              "service_date2": "",
              "pickup_time2": "",
            },
          },
        ],
      };

      final model = GetPatientTransportResponseModel.fromJson(json);
      final tm = model.data!.first.travelMode!;

      expect(tm.serviceDate2, isNull);
      expect(model.data!.first.recordedDate, DateTime(2026, 7, 9));
    });

    test('ค่าว่างในทุก date field ที่ parse เป็น DateTime', () {
      final json = {
        "data": [
          {
            "recorded_date": "",
            "appointment_info": {"appointment_date": ""},
            "driver": [
              {"service_date": "", "submission_time": ""},
            ],
            "travel_mode": {"service_date2": "-"},
          },
        ],
      };

      final t = GetPatientTransportResponseModel.fromJson(json).data!.first;

      expect(t.recordedDate, isNull);
      expect(t.appointmentInfo!.appointmentDate, isNull);
      expect(t.driver!.first.serviceDate, isNull);
      expect(t.travelMode!.serviceDate2, isNull);
    });

    test('toJson ไม่ throw เมื่อ date เป็น null', () {
      final t = GetPatientTransportResponseModel.fromJson({
        "data": [
          {
            "recorded_date": "",
            "appointment_info": {"appointment_date": ""},
            "travel_mode": {"service_date2": ""},
          },
        ],
      });

      expect(() => t.toJson(), returnsNormally);
      expect(t.data!.first.toJson()["recorded_date"], isNull);
    });

    test('วันที่ปกติยัง parse ได้เหมือนเดิม', () {
      final t = GetPatientTransportResponseModel.fromJson({
        "data": [
          {
            "recorded_date": "2026-08-28",
            "appointment_info": {"appointment_date": "2026-08-28"},
            "travel_mode": {"service_date2": "2026-07-10"},
          },
        ],
      }).data!.first;

      expect(t.recordedDate, DateTime(2026, 8, 28));
      expect(t.appointmentInfo!.appointmentDate, DateTime(2026, 8, 28));
      expect(t.travelMode!.serviceDate2, DateTime(2026, 7, 10));
    });
  });
}
