import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'أكفيو';

  @override
  String get welcome => 'Welcome';

  @override
  String get verifyCode => 'Verify Code';

  @override
  String get enterPhoneToContinue => 'Enter your phone number to continue';

  @override
  String enterCodeSentTo(String phoneNumber) {
    return 'Enter the code sent to $phoneNumber';
  }

  @override
  String get sendOtp => 'Send OTP';

  @override
  String get verify => 'Verify';

  @override
  String get changeNumber => 'Change Number';

  @override
  String get continueAsGuest => 'Continue as Guest';

  @override
  String get back => 'Back';

  @override
  String get google => 'Google';

  @override
  String get apple => 'Apple';

  @override
  String get stepIdea => 'الفكرة';

  @override
  String get stepStyle => 'الأسلوب';

  @override
  String get stepFinalize => 'الإنهاء';

  @override
  String get ideaStepPlaceholder => 'صف فكرة الفيديو الخاصة بك... على سبيل المثال، \'مدينة مستقبلية بها سيارات طائرة\'';

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
  String get noCreationsYet => 'لا توجد إبداعات بعد';

  @override
  String get startCreating => 'ابدأ في إنشاء أول فيديو لك!';

  @override
  String get createNew => 'إنشاء جديد';

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

  @override
  String get delete => 'حذف';

  @override
  String get edit => 'تعديل';

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get dontHaveAccount => 'ليس لديك حساب؟';

  @override
  String get signUp => 'إنشاء حساب';

  @override
  String get or => 'أو';

  @override
  String get continueWithGoogle => 'المتابعة باستخدام جوجل';

  @override
  String get continueWithApple => 'المتابعة باستخدام آبل';

  @override
  String get creatingMagic => 'جاري الإنشاء بسحر...';

  @override
  String get almostDone => 'تقريباً انتهينا!';

  @override
  String get processingVideo => 'جاري معالجة الفيديو';

  @override
  String get thisWillTakeAMoment => 'سيستغرق هذا لحظة';

  @override
  String get videoPreview => 'معاينة الفيديو';

  @override
  String get playPause => 'تشغيل/إيقاف';

  @override
  String get restart => 'إعادة التشغيل';

  @override
  String get downloadVideo => 'تحميل الفيديو';

  @override
  String get shareVideo => 'مشاركة الفيديو';

  @override
  String get deleteVideo => 'حذف الفيديو';

  @override
  String get confirmDelete => 'هل أنت متأكد من حذف هذا الفيديو؟';

  @override
  String get settings => 'الإعدادات';

  @override
  String get language => 'اللغة';

  @override
  String get selectLanguage => 'اختر اللغة';

  @override
  String get english => 'English';

  @override
  String get arabic => 'العربية';

  @override
  String get theme => 'المظهر';

  @override
  String get lightMode => 'الوضع الفاتح';

  @override
  String get darkMode => 'الوضع الداكن';

  @override
  String get systemDefault => 'النظام الافتراضي';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get account => 'الحساب';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get about => 'حول';

  @override
  String get version => 'الإصدار';

  @override
  String get termsOfService => 'شروط الخدمة';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get payment => 'الدفع';

  @override
  String get proceedToPayment => 'المتابعة للدفع';

  @override
  String get paymentSuccessful => 'تم الدفع بنجاح';

  @override
  String get paymentFailed => 'فشل الدفع';

  @override
  String get total => 'الإجمالي';

  @override
  String get price => 'السعر';

  @override
  String get gallery => 'المعرض';

  @override
  String get selectMedia => 'اختر الوسائط';

  @override
  String get photos => 'الصور';

  @override
  String get videos => 'الفيديوهات';

  @override
  String get recentMedia => 'الوسائط الحديثة';

  @override
  String get loading => 'جاري التحميل...';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get success => 'نجح';

  @override
  String get failed => 'فشل';

  @override
  String get warning => 'تحذير';

  @override
  String get info => 'معلومات';

  @override
  String get confirm => 'تأكيد';

  @override
  String get close => 'إغلاق';
}
