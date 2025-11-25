# Arabic Localization Implementation Guide

## Overview
Your Aqvioo app now supports full Arabic localization with **Arabic as the default language**. The implementation includes proper RTL (Right-to-Left) layout support and the Cairo font for beautiful Arabic typography.

## What Was Implemented

### 1. Dependencies Added
- **flutter_localizations**: Official Flutter localization support
- Configured in `pubspec.yaml` with `generate: true`

### 2. Font Selection: Cairo
**Cairo** was chosen as the primary font for several reasons:
- ✅ Specifically designed for Arabic text with excellent readability
- ✅ Modern, clean aesthetic that matches your app's design
- ✅ Supports both Arabic and English seamlessly
- ✅ Available through Google Fonts (no manual font file management)
- ✅ Multiple weights (regular, medium, semi-bold, bold) for UI hierarchy

### 3. Localization Files Structure
```
lib/
├── l10n/
│   ├── app_en.arb  # English translations
│   └── app_ar.arb  # Arabic translations
└── generated/
    ├── app_localizations.dart       # Main localization class
    ├── app_localizations_ar.dart    # Arabic implementation
    └── app_localizations_en.dart    # English implementation
```

### 4. Configuration Files
- **l10n.yaml**: Localization generation configuration
- **pubspec.yaml**: Dependencies and generation settings
- **lib/app.dart**: MaterialApp with localization delegates and Arabic as default locale

### 5. Translations Provided
The following strings have been translated:
- App title
- Step indicators (Idea, Style, Finalize)
- Form placeholders and hints
- Button labels (Back, Next, Add Image, etc.)
- Error messages
- Common UI elements

## How to Use Localization in Your Code

### Accessing Translations
```dart
import 'package:your_app/generated/app_localizations.dart';

// In your widget:
Text(AppLocalizations.of(context)!.appTitle)
Text(AppLocalizations.of(context)!.buttonNext)
Text(AppLocalizations.of(context)!.errorMessage('Error details'))
```

### Adding New Translations

1. **Add to English file** (`lib/l10n/app_en.arb`):
```json
{
  "newString": "Hello World",
  "@newString": {
    "description": "Greeting message"
  }
}
```

2. **Add to Arabic file** (`lib/l10n/app_ar.arb`):
```json
{
  "newString": "مرحبا بالعالم"
}
```

3. **Regenerate localization files**:
```bash
flutter gen-l10n
```

4. **Use in code**:
```dart
Text(AppLocalizations.of(context)!.newString)
```

### Strings with Parameters
For dynamic strings:

**In ARB file**:
```json
{
  "greeting": "Hello, {name}!",
  "@greeting": {
    "description": "Personalized greeting",
    "placeholders": {
      "name": {
        "type": "String"
      }
    }
  }
}
```

**In code**:
```dart
Text(AppLocalizations.of(context)!.greeting('Ahmed'))
```

## RTL Support

### Automatic RTL Layout
Flutter automatically handles RTL layout for Arabic. Key features:
- Text alignment flips automatically
- Icons and buttons position correctly
- ScrollView directions adjust
- Navigation drawer opens from the right

### Manual RTL Handling (if needed)
```dart
// Check text direction
final isRTL = Directionality.of(context) == TextDirection.rtl;

// Force RTL for specific widget
Directionality(
  textDirection: TextDirection.rtl,
  child: YourWidget(),
)
```

## Changing Default Language

### To Switch to English as Default
In `lib/app.dart`:
```dart
locale: const Locale('en'), // Change 'ar' to 'en'
```

### To Let Device Decide
```dart
// Remove the locale property entirely
// Flutter will use device's system language
```

### To Add Language Switcher
```dart
// In your settings or profile screen
ElevatedButton(
  onPressed: () {
    // You'll need to implement state management for this
    // Using Riverpod or Provider to store user's language preference
  },
  child: Text('Switch Language'),
)
```

## Testing

### Test Arabic Display
1. Run the app: `flutter run`
2. The app should display in Arabic by default
3. Check that text reads right-to-left
4. Verify icons and buttons are positioned correctly

### Test English Display
1. Change `locale: const Locale('en')` in `lib/app.dart`
2. Run the app
3. Verify English text displays correctly

### Test Both Languages
1. Remove the `locale` property from MaterialApp
2. Change device language settings
3. Verify app follows device language

## Cairo Font Alternatives

If you want to try different Arabic fonts:

### Other Excellent Arabic Fonts via Google Fonts:
- **Tajawal**: Modern, geometric design
- **Almarai**: Clean, highly readable
- **Amiri**: Traditional, elegant for formal apps
- **Changa**: Bold, modern display font
- **Markazi Text**: Perfect for body text

### To Change Font:
In `lib/core/theme/app_theme.dart`, replace:
```dart
GoogleFonts.cairo(...)
```
with:
```dart
GoogleFonts.tajawal(...)  // Or any other font
```

## Best Practices

1. **Always provide both languages**: Even with Arabic as default, maintain English translations
2. **Test with long Arabic text**: Arabic words can be longer than English
3. **Avoid hardcoded text**: Always use AppLocalizations
4. **Consider plurals**: Arabic has complex plural rules (use ICU format)
5. **Test on real devices**: RTL can behave differently on different platforms

## Troubleshooting

### Translations not showing?
```bash
flutter clean
flutter pub get
flutter gen-l10n
flutter run
```

### Font not loading?
- Check internet connection (Cairo downloads from Google Fonts)
- For offline apps, consider downloading Cairo font files manually

### RTL layout issues?
- Wrap problematic widgets with `Directionality`
- Check for hardcoded padding/margin values
- Use EdgeInsets.symmetric instead of directional insets

## Files Modified

1. `pubspec.yaml` - Added dependencies and generate flag
2. `l10n.yaml` - Localization configuration
3. `lib/app.dart` - Added localization delegates and locale settings
4. `lib/core/theme/app_theme.dart` - Changed font from Space Grotesk to Cairo
5. `lib/features/home/presentation/screens/home_screen.dart` - Replaced hardcoded strings with localized versions
6. `lib/l10n/app_en.arb` - English translations
7. `lib/l10n/app_ar.arb` - Arabic translations

## Next Steps

To localize other screens:
1. Identify all hardcoded strings
2. Add them to ARB files (both en and ar)
3. Run `flutter gen-l10n`
4. Replace hardcoded strings with AppLocalizations calls

---

**Note**: Remember to run `flutter gen-l10n` whenever you modify ARB files!
