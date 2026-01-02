# App Store Rejection Fix - December 2025

## Summary
This document details the issues reported by Apple during the App Store review and the fixes applied.

---

## Problem 1: App Crashes on iPad Launch (Guideline 2.1)

### Symptom
> "After we launched the app we were presented with an error page."  
> Device: iPad Air 11-inch (M3), iPadOS 26.2

### Root Cause
In `lib/main.dart`, the function `usePathUrlStrategy()` from `flutter_web_plugins` was called unconditionally:

```dart
// BEFORE (Problematic)
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy(); // ❌ This throws on native iOS/iPadOS
  // ...
}
```

This function is **only valid for Flutter Web**. On native iOS/iPadOS, it caused an unhandled exception, which was caught by the global `try-catch` block in `main()` and displayed an "Initialization Error" screen.

### Fix Applied
Wrapped the call in a `kIsWeb` check so it only runs on the web platform:

```dart
// AFTER (Fixed)
import 'package:flutter/foundation.dart'; // for kIsWeb

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    usePathUrlStrategy(); // ✅ Only runs on web now
  }
  // ...
}
```

**File Modified:** `lib/main.dart` (lines 18-20)

---

## Problem 2: Invalid Screenshots (Guideline 2.3.3)

### Symptom
> "The 6.7-inch iPhone and 13-inch iPad screenshots do not show the actual app in use."

### Root Cause
The uploaded screenshots were primarily splash screens or login screens, not demonstrating the app's main features.

### Fix Required (Manual Action)
You must upload **new screenshots** to App Store Connect that show:
- ✅ Home/Dashboard screen
- ✅ Content creation interface
- ✅ Gallery / "My Creations" screen
- ✅ Any unique feature being actively used

**Do NOT use:**
- ❌ Splash screens only
- ❌ Login screens only

---

## Current Blocker: Disk Full

The iOS build cannot complete because the disk is at 100% capacity (only 29 MB free).

### How to Free Space
Run these commands to clear caches:

```bash
# Clear Xcode DerivedData (already done)
rm -rf ~/Library/Developer/Xcode/DerivedData

# Clear old iOS Simulators
xcrun simctl delete unavailable

# Clear Gradle caches (Android builds)
rm -rf ~/.gradle/caches

# Clear CocoaPods cache
rm -rf ~/Library/Caches/CocoaPods

# Clear Homebrew cache
brew cleanup
```

After freeing 5–10 GB, re-run the build:
```bash
flutter build ios --release
```

---

## Files Changed

| File | Change |
|------|--------|
| `lib/main.dart` | Added `if (kIsWeb)` guard around `usePathUrlStrategy()` |
| `lib/firebase_options.dart` | Updated Android App ID from placeholder to actual value |

---

## Next Steps for Resubmission

1. **Free disk space** (see above)
2. **Build the iOS release:**
   ```bash
   flutter build ios --release
   ```
3. **Archive and upload** via Xcode or Transporter
4. **Take new screenshots** on Simulator (iPhone 15 Pro Max, iPad Pro 13")
5. **Upload screenshots** to App Store Connect
6. **Submit for review** and respond to the reviewer:
   > "Fixed the startup crash in the new build. Updated screenshots to show core app functionality."

---

## Version Info
- **App Version:** 1.0.0+6
- **Bundle ID (iOS):** `com.aqvioo.akvioo`
- **Package Name (Android):** `com.aqvioo.app`
- **Fix Date:** December 31, 2025
