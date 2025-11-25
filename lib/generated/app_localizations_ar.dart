// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'أكفيو';

  @override
  String get stepIdea => 'الفكرة';

  @override
  String get stepStyle => 'الأسلوب';

  @override
  String get stepFinalize => 'الإنهاء';

  @override
  String get ideaStepPlaceholder =>
      'صف فكرة الفيديو الخاصة بك... على سبيل المثال، \'مدينة مستقبلية بها سيارات طائرة\'';

  @override
  String get addImage => 'إضافة صورة';

  @override
  String get imageAdded => 'تمت إضافة الصورة';

  @override
  String get buttonBack => 'رجوع';

  @override
  String get buttonNext => 'التالي';

  @override
  String get promptRequired => 'يرجى إدخال وصف للمتابعة';

  @override
  String errorMessage(String message) {
    return 'خطأ: $message';
  }

  @override
  String get myCreations => 'إبداعاتي';

  @override
  String get videoLength => 'طول الفيديو';

  @override
  String get aspectRatio => 'نسبة العرض إلى الارتفاع';

  @override
  String get voiceGender => 'نوع الصوت';

  @override
  String get male => 'ذكر';

  @override
  String get female => 'أنثى';

  @override
  String get duration => 'المدة';

  @override
  String get seconds => 'ثانية';

  @override
  String get generate => 'إنشاء';

  @override
  String get creating => 'جاري الإنشاء';

  @override
  String get generatingVideo => 'جاري إنشاء الفيديو...';

  @override
  String get preview => 'معاينة';

  @override
  String get share => 'مشاركة';

  @override
  String get download => 'تحميل';
}
