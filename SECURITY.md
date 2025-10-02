# Security: Firebase Configuration

⚠️ **IMPORTANT SECURITY NOTICE** ⚠️

## API Key Exposure

The `firebase_options.dart` file contains sensitive Firebase API keys and should **NEVER** be committed to version control.

## Setup Instructions

1. **Copy the example file:**
   ```bash
   cp lib/firebase_options.example.dart lib/firebase_options.dart
   ```

2. **Get your Firebase configuration:**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Select your project
   - Go to Project Settings > General
   - Scroll down to "Your apps" section
   - Copy your Firebase configuration

3. **Or use FlutterFire CLI (Recommended):**
   ```bash
   # Install FlutterFire CLI
   dart pub global activate flutterfire_cli

   # Configure Firebase
   flutterfire configure
   ```

4. **Replace the placeholder values** in `lib/firebase_options.dart` with your actual Firebase configuration

## If API Key Was Exposed

If your API key was already committed and pushed to GitHub:

1. **Revoke the exposed API key immediately:**
   - Go to [Google Cloud Console](https://console.cloud.google.com/)
   - Navigate to "APIs & Services" > "Credentials"
   - Find and delete the exposed API key
   - Create a new API key

2. **Clean Git history:**
   ```bash
   # Remove file from Git history (use with caution!)
   git filter-branch --force --index-filter \
     "git rm --cached --ignore-unmatch lib/firebase_options.dart" \
     --prune-empty --tag-name-filter cat -- --all

   # Force push (coordinate with team first!)
   git push origin --force --all
   ```

3. **Or use BFG Repo-Cleaner (easier method):**
   ```bash
   # Download BFG from https://rtyley.github.io/bfg-repo-cleaner/
   # Then run:
   bfg --delete-files firebase_options.dart
   git reflog expire --expire=now --all && git gc --prune=now --aggressive
   git push origin --force --all
   ```

## Best Practices

- ✅ Keep `firebase_options.dart` in `.gitignore`
- ✅ Use environment variables for CI/CD
- ✅ Implement API key restrictions in Google Cloud Console
- ✅ Monitor API key usage regularly
- ❌ Never commit API keys to version control
- ❌ Never share API keys in chat/email

## API Key Restrictions

Add these restrictions in Google Cloud Console:

1. **Application restrictions:**
   - HTTP referrers (for web)
   - Add your domain(s)

2. **API restrictions:**
   - Restrict key to only the APIs you use
   - Cloud Firestore API
   - Firebase Authentication
   - etc.

## Contact

If you have questions about security, contact the team lead.
