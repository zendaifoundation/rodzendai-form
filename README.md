# rodzendai_form

A Flutter application for patient transport registration and status checking.

## 🚨 Security Notice

**IMPORTANT:** Before running this project, you must configure Firebase. See [SECURITY.md](SECURITY.md) for detailed instructions.

## Getting Started

### Prerequisites

- Flutter SDK ^3.9.2
- Dart SDK
- Firebase Project

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/zendaifoundation/rodzendai-form.git
   cd rodzendai-form
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase:**
   ```bash
   # Copy the example file
   cp lib/firebase_options.example.dart lib/firebase_options.dart
   
   # Then edit lib/firebase_options.dart with your Firebase credentials
   # OR use FlutterFire CLI (recommended):
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

4. **Run the app:**
   ```bash
   # For Web
   flutter run -d chrome
   
   # For macOS
   flutter run -d macos
   ```

## Deployment

**Deploy to Firebase Hosting (Sandbox):**
```bash
#sandbox
fvm flutter clean && fvm flutter build web --release --dart-define-from-file=.env.sandbox && firebase deploy --only hosting:rodzendai-form-sandbox
#staging
fvm flutter clean && fvm flutter build web --release --dart-define-from-file=.env.staging && firebase deploy --only hosting:rodzendai-form-staging
#production
fvm flutter clean && fvm flutter build web --release --dart-define-from-file=.env && firebase deploy --only hosting:rodzendai-form
```
```bash เสม็ด ชลบุรี
#sandbox
fvm flutter clean && fvm flutter build web --release --dart-define-from-file=.env.sandbox_samed && firebase deploy --only hosting:rodzendai-form-samed-sandbox
#staging
fvm flutter clean && fvm flutter build web --release --dart-define-from-file=.env.staging_samed && firebase deploy --only hosting:rodzendai-form-samed-staging
#production
fvm flutter clean && fvm flutter build web --release --dart-define-from-file=.env_samed && firebase deploy --only hosting:rodzendai-form-samed
```

```bash พัทยา ชลบุรี
#sandbox
fvm flutter clean && fvm flutter build web --release --dart-define-from-file=.env.sandbox_pattaya && firebase deploy --only hosting:rodzendai-form-pattaya-sandbox
#staging
fvm flutter clean && fvm flutter build web --release --dart-define-from-file=.env.staging_pattaya && firebase deploy --only hosting:rodzendai-form-pattaya-staging
#production
fvm flutter clean && fvm flutter build web --release --dart-define-from-file=.env_pattaya && firebase deploy --only hosting:rodzendai-form-pattaya
```

```bash เทศบาลเมืองแสนสุข ชลบุรี
#sandbox
fvm flutter clean && fvm flutter build web --release --dart-define-from-file=.env.sandbox_saensuk && firebase deploy --only hosting:rodzendai-form-saensuk-sandbox
#staging
fvm flutter clean && fvm flutter build web --release --dart-define-from-file=.env.staging_saensuk && firebase deploy --only hosting:rodzendai-form-saensuk-staging
#production
fvm flutter clean && fvm flutter build web --release --dart-define-from-file=.env_tessaban_saensuk && firebase deploy --only hosting:rodzendai-form-tessaban-saensuk
```

```bash เทศบาลเมืองอ่างศิลา ชลบุรี
#sandbox
fvm flutter clean && fvm flutter build web --release --dart-define-from-file=.env.sandbox_angsila && firebase deploy --only hosting:rodzendai-form-tessaban-angsila-sandbox
#staging
fvm flutter clean && fvm flutter build web --release --dart-define-from-file=.env.staging_angsila && firebase deploy --only hosting:rodzendai-form-tessaban-angsila-staging
#production
fvm flutter clean && fvm flutter build web --release --dart-define-from-file=.env_tessaban_angsila && firebase deploy --only hosting:rodzendai-form-tessaban-angsila
```

## Customer Configurations

ตารางสรุป customer code และพื้นที่ที่อนุญาต (ตั้งใน `.env_*` แต่ละไฟล์):

| Customer | CUSTOMER_CODE |
|----------|---------------|
| กรุงเทพมหานคร | `bangkok` |
| พัทยา | `pattaya` |
| เกาะเสม็ด | `samed` |
| เทศบาลเมืองแสนสุข | `tessaban_saensuk` |
| เทศบาลเมืองอ่างศิลา | `tessaban_angsila` |

### การเพิ่มลูกค้าใหม่

1. สร้างไฟล์ `.env_<customer>`, `.env.staging_<customer>`, `.env.sandbox_<customer>` (copy จากของลูกค้าเดิม แล้วแก้ `CUSTOMER_CODE`, `ALLOWED_PROVINCE_CODE`, `ALLOWED_DISTRICT_CODE`, `ALLOWED_SUB_DISTRICT_CODE`, `LIFF_ID`)
2. สร้าง Firebase Hosting target: `rodzendai-form-<customer>`, `rodzendai-form-<customer>-staging`, `rodzendai-form-<customer>-sandbox`
3. เพิ่ม partner logo (optional): วางไฟล์ใน `assets/images/img_logo_<customer>.png` แล้วเพิ่ม mapping ที่ [home_page.dart](lib/presentation/home_page/pages/home_page.dart) (ตัวแปร `partnerLogos`)
4. เพิ่ม block คำสั่ง deploy ใน README นี้

## Project Structure

```
lib/
├── core/
│   ├── constants/      # App constants (colors, text styles, etc.)
│   ├── network/        # Network configurations
│   ├── routes/         # App routing
│   └── services/       # Services
├── presentation/
│   ├── home_page/      # Home page
│   ├── register/       # Registration flow
│   ├── register_status/ # Check registration status
│   └── splash/         # Splash screen
├── repositories/       # Data repositories
├── widgets/            # Reusable widgets
└── main.dart          # App entry point
```

## Features

- ✅ Patient transport registration
- ✅ Registration status checking
- ✅ Firebase Firestore integration
- ✅ Responsive design
- ✅ Form validation

## Firebase Collections

### `patient_transports`
```json
{
  "patientIdCard": "1234567890123",
  "appointmentDate": "2025-10-02",
  "fullName": "ชื่อ นามสกุล",
  "hospital": "โรงพยาบาล",
  "appointmentTime": "09:00",
  "status": "confirmed",
  "createdAt": Timestamp,
  "updatedAt": Timestamp
}
```

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Security Guidelines](SECURITY.md)

## Contributing

Please read [SECURITY.md](SECURITY.md) before contributing to ensure you don't accidentally commit sensitive information.

## License

This project is private and confidential.




| Customer | CUSTOMER_CODE |
|----------|---------------|
| กรุงเทพมหานคร | `bangkok` |
| พัทยา | `pattaya` |
| เกาะเสม็ด | `samed` |
| เทศบาลเมืองแสนสุข | `tessaban_saensuk` |
| เทศบาลเมืองอ่างศิลา | `tessaban_angsila` |




## Update splash logo ก่อน deploy ทุกครั้ง ตาม partner

รูป splash อยู่ที่ `assets/images/img_splash_<partner>.png` ต้องเป็นรูป composite (logo รถเซนได + logo partner วางคู่กันในรูปเดียว) เพราะ `flutter_native_splash` จะนำรูปนี้ไปวางตรงกลาง splash ตรง ๆ โดยไม่ composite อะไรเพิ่มให้

หลังแก้ไขรูปแล้ว ให้ generate splash ใหม่ตาม partner ที่จะ deploy:

```bash
# พัทยา
dart run flutter_native_splash:create --path=flutter_native_splash_pattaya.yaml

# เกาะเสม็ด
dart run flutter_native_splash:create --path=flutter_native_splash_samed.yaml

# เทศบาลเมืองอ่างศิลา
dart run flutter_native_splash:create --path=flutter_native_splash_tessaban_angsila.yaml

# เทศบาลเมืองแสนสุข
dart run flutter_native_splash:create --path=flutter_native_splash_tessaban_saensuk.yaml

# default (ไม่มี partner)
dart run flutter_native_splash:create
```

หรือใช้ script wrapper ที่ generate splash + build web ในคำสั่งเดียว:

```bash
./scripts/build_web.sh pattaya
./scripts/build_web.sh samed
./scripts/build_web.sh default
```
