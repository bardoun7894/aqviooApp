# Current Translations Reference

## Available Translations

| Key | English | Arabic (العربية) |
|-----|---------|------------------|
| `appTitle` | Aqvioo | أكفيو |
| `stepIdea` | Idea | الفكرة |
| `stepStyle` | Style | الأسلوب |
| `stepFinalize` | Finalize | الإنهاء |
| `ideaStepPlaceholder` | Describe your video idea... e.g., 'A futuristic city with flying cars' | صف فكرة الفيديو الخاصة بك... على سبيل المثال، 'مدينة مستقبلية بها سيارات طائرة' |
| `addImage` | Add Image | إضافة صورة |
| `imageAdded` | Image Added | تمت إضافة الصورة |
| `buttonBack` | Back | رجوع |
| `buttonNext` | Next | التالي |
| `promptRequired` | Please enter a prompt to continue | يرجى إدخال وصف للمتابعة |
| `errorMessage` | Error: {message} | خطأ: {message} |
| `myCreations` | My Creations | إبداعاتي |
| `videoLength` | Video Length | طول الفيديو |
| `aspectRatio` | Aspect Ratio | نسبة العرض إلى الارتفاع |
| `voiceGender` | Voice Gender | نوع الصوت |
| `male` | Male | ذكر |
| `female` | Female | أنثى |
| `duration` | Duration | المدة |
| `seconds` | seconds | ثانية |
| `generate` | Generate | إنشاء |
| `creating` | Creating | جاري الإنشاء |
| `generatingVideo` | Generating your video... | جاري إنشاء الفيديو... |
| `preview` | Preview | معاينة |
| `share` | Share | مشاركة |
| `download` | Download | تحميل |

## Usage Examples

### Simple String
```dart
// English: "Back" / Arabic: "رجوع"
Text(AppLocalizations.of(context)!.buttonBack)
```

### String with Parameter
```dart
// English: "Error: Connection failed" / Arabic: "خطأ: فشل الاتصال"
Text(AppLocalizations.of(context)!.errorMessage('Connection failed'))
```

### In Different Widgets

#### Button Text
```dart
ElevatedButton(
  onPressed: () {},
  child: Text(AppLocalizations.of(context)!.buttonNext),
)
```

#### TextField Hint
```dart
TextField(
  decoration: InputDecoration(
    hintText: AppLocalizations.of(context)!.ideaStepPlaceholder,
  ),
)
```

#### AppBar Title
```dart
AppBar(
  title: Text(AppLocalizations.of(context)!.appTitle),
)
```

## Adding More Screens

When localizing additional screens, follow this pattern:

### 1. Identify Strings
List all user-facing text in the screen

### 2. Add to English ARB
```json
{
  "screenName_elementName": "English Text",
  "@screenName_elementName": {
    "description": "Description of where/how it's used"
  }
}
```

### 3. Add to Arabic ARB
```json
{
  "screenName_elementName": "النص العربي"
}
```

### 4. Regenerate and Use
```bash
flutter gen-l10n
```

Then in code:
```dart
Text(AppLocalizations.of(context)!.screenName_elementName)
```

## Naming Conventions

Recommended patterns for translation keys:

- **General UI**: `buttonName`, `labelName`, `titleName`
- **Screen-specific**: `screenName_element` (e.g., `home_welcome`, `profile_edit`)
- **Messages**: `errorXxx`, `successXxx`, `warningXxx`
- **Actions**: `actionXxx` (e.g., `actionSave`, `actionCancel`)
- **Status**: `statusXxx` (e.g., `statusLoading`, `statusComplete`)

## Quick Reference for Developers

### Import
```dart
import 'package:akvioo/generated/app_localizations.dart';
```

### Access
```dart
AppLocalizations.of(context)!.keyName
```

### Check Current Locale
```dart
final locale = Localizations.localeOf(context);
if (locale.languageCode == 'ar') {
  // Arabic-specific logic
}
```

### Check Text Direction
```dart
final isRTL = Directionality.of(context) == TextDirection.rtl;
```

---

**Last Updated**: November 2024
**Total Translations**: 24 strings across English and Arabic
