# LIFF Development & Testing Guide

## วิธีทดสอบ LIFF ใน Development

### ตัวเลือก 1: ใช้ LIFF Inspector (แนะนำ) ⭐

LIFF Inspector เป็นเครื่องมือจาก LINE สำหรับทดสอบ LIFF app ในเบราว์เซอร์ปกติ

#### ขั้นตอน:

1. **รัน Flutter dev server**:
   ```bash
   fvm flutter run -d chrome --dart-define-from-file=.env
   ```
   หรือ
   ```bash
   fvm flutter run -d web-server --web-port=8080 --dart-define-from-file=.env
   ```

2. **เปิด LIFF Inspector**:
   - ไปที่: https://liff-inspector.line.me/
   - ใส่ **LIFF ID** ของคุณ
   - ใส่ **Endpoint URL**: `http://localhost:8080` (หรือ port ที่ใช้)
   - กด "Open LIFF app"

3. **ทดสอบ**:
   - LIFF Inspector จะจำลอง environment ของ LINE app
   - สามารถทดสอบ login, get profile, ฯลฯ ได้เหมือนใน LINE จริง

#### ข้อดี:
- ✅ ไม่ต้อง deploy
- ✅ ทดสอบได้ในเบราว์เซอร์ปกติ
- ✅ Hot reload ใช้งานได้
- ✅ เห็น debug logs ใน DevTools

---

### ตัวเลือก 2: ใช้ ngrok เพื่อ Expose Local Server

#### ขั้นตอน:

1. **ติดตั้ง ngrok**:
   ```bash
   brew install ngrok
   # หรือดาวน์โหลดจาก https://ngrok.com/
   ```

2. **รัน Flutter dev server**:
   ```bash
   fvm flutter run -d web-server --web-port=8080 --dart-define-from-file=.env
   ```

3. **เปิด ngrok tunnel**:
   ```bash
   ngrok http 8080
   ```

4. **คัดลอก HTTPS URL** ที่ ngrok ให้มา เช่น:
   ```
   https://abc123.ngrok.io
   ```

5. **อัพเดท LIFF Endpoint URL** ใน LINE Developers Console:
   - ไปที่ LIFF settings
   - เปลี่ยน Endpoint URL เป็น `https://abc123.ngrok.io`
   - Save

6. **เปิดใน LINE**:
   ```
   https://liff.line.me/{LIFF_ID}
   ```

#### ข้อดี:
- ✅ ทดสอบได้ใน LINE app จริง
- ✅ ได้ผลลัพธ์เหมือนจริงที่สุด

#### ข้อเสีย:
- ❌ ต้องเปลี่ยน Endpoint URL ทุกครั้ง (ngrok URL เปลี่ยนทุกครั้งที่รัน free version)
- ❌ ช้ากว่า local development

---

### ตัวเลือก 3: Mock LIFF สำหรับ Development

สร้างโหมด development ที่ไม่ต้องใช้ LIFF จริง

#### แก้ไข `liff_service.dart`:

```dart
import 'dart:js_util' as js_util;
import 'package:flutter/foundation.dart';

class LiffService {
  // เพิ่ม development mode
  static const bool _isDevelopment = bool.fromEnvironment('DEV_MODE', defaultValue: false);
  
  static const String _liffId = String.fromEnvironment(
    'LIFF_ID',
    defaultValue: 'YOUR_LIFF_ID_HERE',
  );

  static bool _isInitialized = false;
  static LiffProfile? _profile;

  /// Initialize LIFF
  static Future<bool> init() async {
    if (_isInitialized) return true;

    // Development mode - skip real LIFF
    if (_isDevelopment) {
      debugPrint('🔧 Development mode: Using mock LIFF');
      _isInitialized = true;
      _profile = LiffProfile(
        userId: 'U1234567890abcdef1234567890abcdef',
        displayName: 'Test User',
        pictureUrl: 'https://via.placeholder.com/150',
        statusMessage: 'Testing...',
      );
      return true;
    }

    // Production mode - use real LIFF
    try {
      if (!kIsWeb) {
        debugPrint('LIFF is only available on web platform');
        return false;
      }

      if (!_isLiffAvailable()) {
        debugPrint('LIFF SDK is not loaded');
        return false;
      }

      await _liffInit(_liffId);
      _isInitialized = true;
      debugPrint('LIFF initialized successfully');
      return true;
    } catch (e) {
      debugPrint('Error initializing LIFF: $e');
      return false;
    }
  }

  /// Check if user is logged in
  static bool isLoggedIn() {
    if (_isDevelopment) return true; // Mock logged in
    if (!_isInitialized || !kIsWeb) return false;
    return _liffIsLoggedIn();
  }

  /// Get user profile
  static Future<LiffProfile?> getProfile() async {
    if (_isDevelopment) return _profile; // Return mock profile
    
    if (_profile != null) return _profile;

    if (!_isInitialized) {
      final initialized = await init();
      if (!initialized) return null;
    }

    if (!isLoggedIn()) return null;

    try {
      final profileData = await _liffGetProfile();
      _profile = LiffProfile.fromJson(profileData);
      return _profile;
    } catch (e) {
      debugPrint('Error getting profile: $e');
      return null;
    }
  }

  // ... rest of the code
}
```

#### รันด้วย Development Mode:

```bash
fvm flutter run -d chrome --dart-define=DEV_MODE=true --dart-define-from-file=.env
```

#### ข้อดี:
- ✅ ไม่ต้องพึ่ง LIFF จริง
- ✅ Hot reload เร็วมาก
- ✅ ทดสอบ UI ได้ง่าย

#### ข้อเสีย:
- ❌ ไม่ได้ทดสอบ LIFF integration จริง
- ❌ ต้องระวังอย่าลืมปิด DEV_MODE ตอน deploy

---

## สรุป - แนะนำตามสถานการณ์

| สถานการณ์ | วิธีที่แนะนำ |
|-----------|-------------|
| **ทดสอบ UI และ Logic** | Mock LIFF (DEV_MODE) |
| **ทดสอบ LIFF Integration** | LIFF Inspector |
| **ทดสอบใน LINE จริง** | ngrok + LINE app |
| **ก่อน Production** | Deploy ไป staging + เทสใน LINE |

---

## Tips

### 1. ใช้ Environment Variables

สร้างไฟล์ `.env.dev`:
```bash
# Development
LIFF_ID=your-liff-id-here
DEV_MODE=true
```

สร้างไฟล์ `.env.prod`:
```bash
# Production
LIFF_ID=your-liff-id-here
DEV_MODE=false
```

รัน:
```bash
# Development
fvm flutter run -d chrome --dart-define-from-file=.env.dev

# Production
fvm flutter build web --release --dart-define-from-file=.env.prod
```

### 2. ดู LIFF Logs

เปิด Browser DevTools → Console เพื่อดู:
- LIFF initialization status
- User profile data
- Error messages

### 3. LIFF Inspector Shortcuts

ใน LIFF Inspector คุณสามารถ:
- Mock different user profiles
- Test different LIFF features
- Simulate errors
- Test on different screen sizes

---

## Troubleshooting

### ปัญหา: "LIFF SDK is not loaded" ใน localhost

**แก้ไข**: ตรวจสอบว่า `web/index.html` มี LIFF SDK script:
```html
<script charset="utf-8" src="https://static.line-scdn.net/liff/edge/2/sdk.js"></script>
```

### ปัญหา: ngrok URL หมดอายุ

**แก้ไข**: 
- ใช้ ngrok paid plan เพื่อได้ fixed domain
- หรือใช้ LIFF Inspector แทน

### ปัญหา: CORS errors ใน localhost

**แก้ไข**: ใช้ `--web-browser-flag="--disable-web-security"`:
```bash
fvm flutter run -d chrome --dart-define-from-file=.env --web-browser-flag="--disable-web-security"
```

⚠️ **คำเตือน**: อย่าใช้ flag นี้กับ production!

---

## Quick Start (แนะนำ)

```bash
# 1. รัน dev server
fvm flutter run -d web-server --web-port=8080 --dart-define-from-file=.env

# 2. เปิดเบราว์เซอร์ใหม่
open http://localhost:8080

# 3. เปิด LIFF Inspector
open https://liff-inspector.line.me/

# 4. ใน LIFF Inspector:
#    - LIFF ID: your-liff-id
#    - Endpoint URL: http://localhost:8080
#    - Click "Open LIFF app"
```

Happy coding! 🚀
