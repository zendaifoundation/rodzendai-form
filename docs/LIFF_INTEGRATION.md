# LINE LIFF Integration Guide

## Overview

LIFF (LINE Front-end Framework) enables automatic login through LINE app without requiring a separate login page. When users open the app through LINE, they are automatically authenticated.

## Setup Steps

### 1. Create LIFF App in LINE Developers Console

1. Go to [LINE Developers Console](https://developers.line.biz/console/)
2. Create a new Provider or select existing one
3. Create a new Channel (LINE Login)
4. Go to LIFF tab
5. Click "Add" to create a new LIFF app
6. Fill in the following:
   - **LIFF app name**: Your app name (e.g., "รถเส้นด้าย")
   - **Size**: Full
   - **Endpoint URL**: Your web app URL (e.g., `https://your-domain.web.app/login`)
   - **Scope**: `profile`, `openid`
   - **Bot link feature**: Optional
7. Click "Add"
8. Copy the **LIFF ID** (format: `1234567890-abcdefgh`)

### 2. Configure Environment Variables

1. Copy `.env.example` to `.env`:
   ```bash
   cp .env.example .env
   ```

2. Add your LIFF ID to `.env`:
   ```bash
   LIFF_ID=1234567890-abcdefgh
   ```

### 3. Build with LIFF ID

Build your Flutter web app with the LIFF ID:

```bash
fvm flutter build web --release --dart-define-from-file=.env
```

Or for development:

```bash
fvm flutter run -d chrome --dart-define-from-file=.env
```

### 4. Test LIFF

**Important**: LIFF apps can only be opened from:
- LINE app (mobile)
- LINE Browser (desktop LINE app)
- Or by using the special LIFF URL

To test:
1. Get your LIFF URL: `https://liff.line.me/{LIFF_ID}`
2. Open it in LINE app or send it to yourself in LINE
3. The app will open in LINE's in-app browser

## Usage in Code

### App Flow

1. User opens LIFF URL: `https://liff.line.me/{LIFF_ID}`
2. SplashPage initializes LIFF automatically
3. If logged in → get profile → navigate to home
4. If not logged in → trigger LINE login → redirect back
5. No separate login page needed!

### Access User Data

Use AuthService throughout your app:

```dart
// In any widget
final authService = context.watch<AuthService>();

// Check if logged in
if (authService.isAuthenticated) {
  print('User: ${authService.displayName}');
  print('User ID: ${authService.userId}');
  print('Picture: ${authService.pictureUrl}');
}

// Get access token for API calls
final token = authService.getAccessToken();
```

### Initialize LIFF (Automatic in SplashPage)

```dart
import 'package:rodzendai_form/core/services/liff_service.dart';

// Initialize (usually in splash or login page)
final initialized = await LiffService.init();
if (!initialized) {
  // Handle initialization error
}
```

### Check Login Status

```dart
if (LiffService.isLoggedIn()) {
  // User is logged in
  final profile = await LiffService.getProfile();
  print('User: ${profile?.displayName}');
}
```

### Login

```dart
await LiffService.login();
// LIFF will handle the login flow and redirect back
```

### Get User Profile

```dart
final profile = await LiffService.getProfile();
if (profile != null) {
  print('User ID: ${profile.userId}');
  print('Display Name: ${profile.displayName}');
  print('Picture: ${profile.pictureUrl}');
  print('Status: ${profile.statusMessage}');
}
```

### Logout

```dart
LiffService.logout();
```

### Get Access Token

```dart
final token = LiffService.getAccessToken();
// Use this token to call LINE APIs or your backend
```

### Close LIFF Window

```dart
LiffService.closeWindow();
// Closes the LIFF app and returns to LINE chat
```

## Architecture

### Files Structure

```
lib/
├── core/
│   └── services/
│       ├── liff_service.dart      # Low-level LIFF SDK wrapper
│       └── auth_service.dart      # High-level auth state management
├── presentation/
│   ├── splash/
│   │   └── pages/
│   │       └── splash_page.dart   # LIFF initialization & auto-login
│   └── home_page/
│       └── pages/
│           └── home_page.dart     # Shows user info if logged in
└── app.dart                        # Provides AuthService to entire app
```

### Key Components

1. **LiffService** - Direct JavaScript interop with LIFF SDK
2. **AuthService** - ChangeNotifier for app-wide authentication state
3. **SplashPage** - Handles LIFF initialization and auto-login
4. **No Login Page** - Authentication happens automatically in LINE

## Router Integration

The app starts at `/splash` which handles all authentication:

```dart
// App flow
/splash → Initialize LIFF → Auto login if needed → Navigate to /
```

No manual navigation to login page required!

## Security Notes

1. **Never commit `.env` file** - It's already in `.gitignore`
2. **Validate on Backend** - Don't trust the access token on frontend only
3. **Use HTTPS** - LIFF requires secure connections
4. **Whitelist Domains** - Configure allowed domains in LINE Developers Console

## Common Issues

### 1. "LIFF SDK is not loaded"
- Make sure `web/index.html` includes the LIFF SDK script
- Check browser console for loading errors

### 2. "LIFF ID is not defined"
- Ensure you're building with `--dart-define-from-file=.env`
- Check that `.env` file exists and contains `LIFF_ID`

### 3. "Cannot open LIFF app"
- LIFF apps must be opened through LINE
- Use the LIFF URL format: `https://liff.line.me/{LIFF_ID}`
- For testing, you can use LIFF Inspector: https://liff-inspector.line.me/

### 4. Login redirects but user not logged in
- Check LIFF redirect URL matches your deployed URL
- Ensure LIFF endpoint URL is correct in developers console
- Check browser cookies are enabled

## Testing

### Development
```bash
# Build and serve locally
fvm flutter run -d chrome --dart-define-from-file=.env

# Then access via LIFF URL
https://liff.line.me/{LIFF_ID}
```

### Production
```bash
# Build
fvm flutter build web --release --dart-define-from-file=.env

# Deploy to Firebase
firebase deploy --only hosting

# Access via LIFF URL
https://liff.line.me/{LIFF_ID}
```

## References

- [LINE LIFF Documentation](https://developers.line.biz/en/docs/liff/overview/)
- [LIFF SDK Reference](https://developers.line.biz/en/reference/liff/)
- [LIFF Inspector](https://liff-inspector.line.me/)
