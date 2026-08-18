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

## Git Flow

โปรเจกต์นี้ใช้ [git-flow](https://danielkummer.github.io/git-flow-cheatsheet/) เป็น branching model

### Branch หลัก

| Branch | บทบาท | Merge เข้ามาจาก |
|--------|-------|-----------------|
| `master` | production — โค้ดที่ deploy จริง ทุก commit ต้องมี tag | `release/*`, `hotfix/*`, `develop` |
| `develop` | integration — งานที่พร้อมจะปล่อยใน release ถัดไป | `feature/*`, `bugfix/*`, `release/*`, `hotfix/*` |

### Branch ชั่วคราว

| Prefix | แตกจาก | merge กลับเข้า | ใช้เมื่อ |
|--------|--------|----------------|---------|
| `feature/*` | `develop` | `develop` | เพิ่มฟีเจอร์ใหม่ |
| `bugfix/*` | `develop` | `develop` | แก้บั๊กที่ยังไม่ขึ้น production |
| `release/*` | `develop` | `master` **และ** `develop` | เตรียมปล่อยเวอร์ชัน (bump version, แก้ bug เล็กน้อย) |
| `hotfix/*` | `master` | `master` **และ** `develop` | แก้บั๊กด่วนบน production |

### กฎที่ต้องยึด

1. **ห้าม commit ตรงเข้า `master` หรือ `develop`** — ต้องผ่าน PR เสมอ
2. **`feature/*` และ `bugfix/*` ห้าม PR เข้า `master` โดยตรง** — ต้องเข้า `develop` ก่อนเสมอ
3. **ทุกครั้งที่ merge เข้า `master` ต้องติด tag** ในรูปแบบ `vX.Y.Z` ให้ตรงกับ `version:` ใน `pubspec.yaml`
4. **`release/*` และ `hotfix/*` ต้อง merge กลับเข้า `develop` ด้วย** ไม่งั้นแก้ไขจะหายไปใน release ถัดไป
5. ใช้ **merge commit** (`--no-ff`) ไม่ใช้ squash เพื่อให้เห็นประวัติ branch

### Flow: Feature / Bugfix

```bash
# 1. เริ่มงานใหม่จาก develop ที่ล่าสุด
git checkout develop
git pull origin develop
git checkout -b feature/ชื่อ-ฟีเจอร์      # หรือ bugfix/ชื่อ-บั๊ก

# 2. ทำงาน + commit
git add .
git commit -m "feat: อธิบายสิ่งที่ทำ"

# 3. push แล้วเปิด PR เข้า develop
git push -u origin feature/ชื่อ-ฟีเจอร์
gh pr create --base develop --head feature/ชื่อ-ฟีเจอร์ \
  --title "feat: ..." --body "..."

# 4. หลัง review ผ่าน merge แล้วลบ branch
gh pr merge <PR#> --merge --delete-branch
```

### Flow: Release (develop → master + tag)

```bash
# 1. bump version ใน pubspec.yaml ก่อน (เช่น 1.0.24+276)
git checkout develop
git pull origin develop
# แก้ pubspec.yaml -> version: X.Y.Z+build
git commit -am "chore: bump version to X.Y.Z+build"
git push origin develop

# 2. เปิด release PR develop -> master
gh pr create --base master --head develop \
  --title "release: vX.Y.Z — สรุปสิ่งที่ปล่อย" --body "..."

# 3. merge PR (ใช้ merge commit ไม่ squash)
gh pr merge <PR#> --merge

# 4. ติด tag บน master
git checkout master
git pull origin master
git tag -a vX.Y.Z -m "Release vX.Y.Z"
git push origin vX.Y.Z

# 5. สร้าง GitHub Release
gh release create vX.Y.Z --title "vX.Y.Z" --notes "รายละเอียดการเปลี่ยนแปลง"

# 6. sync master กลับเข้า develop (ถ้ามี commit เกิดบน master)
git checkout develop
git merge --no-ff master
git push origin develop
```

### Flow: Hotfix (แก้ด่วนบน production)

```bash
# 1. แตกจาก master
git checkout master
git pull origin master
git checkout -b hotfix/ชื่อ-ปัญหา

# 2. แก้ + bump patch version ใน pubspec.yaml แล้ว commit
git commit -am "fix: ..."
git push -u origin hotfix/ชื่อ-ปัญหา

# 3. PR เข้า master แล้ว merge + tag
gh pr create --base master --head hotfix/ชื่อ-ปัญหา --title "hotfix: ..." --body "..."
gh pr merge <PR#> --merge
git checkout master && git pull origin master
git tag -a vX.Y.Z -m "Hotfix vX.Y.Z"
git push origin vX.Y.Z

# 4. ⚠️ สำคัญ — merge กลับเข้า develop ด้วย
gh pr create --base develop --head hotfix/ชื่อ-ปัญหา --title "hotfix: ... (back-merge)" --body "..."
gh pr merge <PR#> --merge --delete-branch
```

### Versioning & Tag

- `pubspec.yaml` ใช้รูปแบบ `version: X.Y.Z+BUILD` (เช่น `1.0.24+276`)
- Tag บน git ใช้เฉพาะส่วน semver นำหน้าด้วย `v` → `v1.0.24`
- `X` major (เปลี่ยนโครงสร้างใหญ่) · `Y` minor (ฟีเจอร์ใหม่) · `Z` patch (แก้บั๊ก)
- `+BUILD` เพิ่มขึ้นทุกครั้งที่ build ไม่ต้องสนใจตอนตั้ง tag
- ต้อง bump version **ก่อน** เปิด release PR เสมอ

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
