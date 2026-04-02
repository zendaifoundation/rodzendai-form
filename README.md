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

**Deploy to Firebase Hosting (Preview Channel - ชั่วคราว):**

Preview Channel จะสร้าง URL ชั่วคราวแยกจาก production โดยไม่กระทบ live site เหมาะสำหรับ QA หรือ demo

```bash
# สร้าง preview channel ชั่วคราว (หมดอายุใน 7 วัน)
# ตั้งชื่อ <channel-name> ได้เองเช่น pr-123, feature-xyz, hotfix-abc

#production
fvm flutter build web --release --dart-define-from-file=.env && firebase hosting:channel:deploy <channel-name> --only rodzendai-form --expires 7d

#staging
fvm flutter build web --release --dart-define-from-file=.env.staging && firebase hosting:channel:deploy <channel-name> --only rodzendai-form-staging --expires 7d

#staging เสม็ด ชลบุรี
fvm flutter build web --release --dart-define-from-file=.env.staging_samed && firebase hosting:channel:deploy <channel-name> --only rodzendai-form-samed-staging --expires 7d
```

> **หมายเหตุ:** Firebase จะคืน URL ชั่วคราวในรูปแบบ `https://<site-id>--<channel-name>-xxxx.web.app`
> ลบ channel ด้วย `firebase hosting:channel:delete <channel-name> --site <site-id>`
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

