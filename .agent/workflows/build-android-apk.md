---
description: Build Android APK for Aqvioo app
---

# Build Android APK - Aqvioo

This workflow documents the successful Android APK build process after resolving all configuration issues.

## Prerequisites

✅ Flutter SDK installed  
✅ Android SDK installed (no Android Studio needed)  
✅ Firebase configured (`google-services.json` present)  

## Build Steps

### 1. Clean Previous Build
```bash
// turbo
flutter clean
```

### 2. Get Dependencies
```bash
// turbo
flutter pub get
```

### 3. Build Debug APK
```bash
flutter build apk --debug
```

**Expected Result:**
```
✓ Built build\app\outputs\flutter-apk\app-debug.apk
```

### 4. Build Release APK (for production)
```bash
flutter build apk --release
```

## APK Location

**Debug APK:**  
`build\app\outputs\flutter-apk\app-debug.apk`

**Release APK:**  
`build\app\outputs\flutter-apk\app-release.apk`

## Current Configuration

### Package
- **ID:** `com.aqvioo.app`
- **Name:** Aqvioo

### SDK Versions
- **compileSdk:** 35
- **targetSdk:** 34
- **minSdk:** 23

### Firebase
- ✅ firebase_core: ^4.2.1
- ✅ firebase_auth: ^6.1.2
- ✅ cloud_firestore: ^6.1.0
- ❌ firebase_storage: Not used (using Kie.AI)

### Removed Plugins
- ❌ image_gallery_saver (caused Kotlin compilation errors)

## Troubleshooting

### If Build Fails

1. **Clean and retry:**
```bash
flutter clean
flutter pub get
flutter build apk --debug
```

2. **Check for plugin issues:**
- Look for `:pluginName:compileDebugKotlin` errors
- Remove problematic plugin from `pubspec.yaml`

3. **Verify Firebase:**
- Ensure `google-services.json` exists in `android/app/`
- Check package name matches in `google-services.json`

## Testing APK

### Transfer to Android Device
1. Connect device via USB
2. Enable "Install from unknown sources"
3. Copy APK to device
4. Install and test

### Or use ADB
```bash
adb install build\app\outputs\flutter-apk\app-debug.apk
```

## Success Criteria

✅ Build completes without errors  
✅ APK file created in `build\app\outputs\flutter-apk\`  
✅ APK installs on Android device  
✅ Firebase Auth works  
✅ All UI screens functional  

## Notes

- **Build time:** ~75 seconds for debug APK
- **Firebase Storage:** Not included (using Kie.AI for video storage)
- **Image Gallery:** Custom implementation (removed image_gallery_saver)
