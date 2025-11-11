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

