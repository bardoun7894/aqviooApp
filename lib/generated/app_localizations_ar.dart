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
  String get welcome => 'مرحبا';

  @override
  String get verifyCode => 'التحقق من الرمز';

  @override
  String get enterPhoneToContinue => 'أدخل رقم هاتفك للمتابعة';

  @override
  String enterCodeSentTo(String phoneNumber) {
    return 'أدخل الرمز المرسل إلى $phoneNumber';
  }

  @override
  String get sendOtp => 'إرسال رمز التحقق';

  @override
  String get verify => 'تحقق';

  @override
  String get changeNumber => 'تغيير الرقم';

  @override
  String get continueAsGuest => 'المتابعة كزائر';

  @override
  String get back => 'رجوع';

  @override
  String get google => 'جوجل';

  @override
  String get apple => 'آبل';

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
  String errorMessage(String error) {
    return 'خطأ: $error';
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

  @override
  String get step1Script => 'البرنامج النصي';

  @override
  String get step2Voice => 'الصوت';

  @override
  String get step3Video => 'الفيديو';

  @override
  String get all => 'الكل';

  @override
  String get images => 'الصور';

  @override
  String get noCreationsYetMessage => 'ابدأ في إنشاء أول فيديو لك!';

  @override
  String get selectVideo => 'اختر الفيديو';

  @override
  String get enterPassword => 'أدخل كلمة المرور';

  @override
  String get accountSettings => 'إعدادات الحساب';

  @override
  String get otpVerification => 'التحقق من رمز التحقق';

  @override
  String get enterOtp => 'أدخل رمز التحقق';

  @override
  String get resend => 'إعادة إرسال';

  @override
  String get twoFactor => 'المصادقة الثنائية';

  @override
  String get musicTrack => 'مسار موسيقي';

  @override
  String get voiceNarration => 'سرد صوتي';

  @override
  String get noMusicSelected => 'لم يتم تحديد موسيقى';

  @override
  String get noVoiceSelected => 'لم يتم تحديد صوت';

  @override
  String get selectMusicTrack => 'اختر مسار موسيقي';

  @override
  String get addVoiceNarration => 'أضف سرد صوتي';

  @override
  String get confirmation => 'تأكيد';

  @override
  String get reviewCreation => 'راجع إبداعك';

  @override
  String get titleRequired => 'العنوان مطلوب';

  @override
  String get descriptionOptional => 'الوصف (اختياري)';

  @override
  String get creationTitle => 'عنوان الإبداع';

  @override
  String get creationDescription => 'الوصف';

  @override
  String get tapToUnlock => 'اضغط لفتح القفل';

  @override
  String get appLocked => 'التطبيق مقفول';

  @override
  String get unknownError => 'خطأ غير معروف';

  @override
  String get tryAgain => 'حاول مرة أخرى';

  @override
  String get processing => 'جاري المعالجة';

  @override
  String get waitForOtp => 'في انتظار رمز التحقق';

  @override
  String get empty => 'فارغ';

  @override
  String get name => 'الاسم';

  @override
  String get created => 'تم الإنشاء';

  @override
  String get dateFormat => 'dd MMM، yyyy';

  @override
  String get deleteConfirmation => 'هل أنت متأكد؟';

  @override
  String get deleteCreationMsg => 'لا يمكن التراجع عن هذا الإجراء';

  @override
  String get yes => 'نعم';

  @override
  String get no => 'لا';

  @override
  String get copied => 'تم النسخ إلى الحافظة';

  @override
  String get error => 'خطأ';

  @override
  String get ok => 'موافق';

  @override
  String get whatToCreate => 'ماذا تريد أن تنشئ؟';

  @override
  String get describeYourIdea =>
      'صف فكرة الفيديو الخاصة بك ودع الذكاء الاصطناعي يقوم بالسحر.';

  @override
  String get enhance => 'تحسين';

  @override
  String get promptEnhanced => 'تم تحسين الوصف! ✨';

  @override
  String charsCount(int count) {
    return '$count حرف';
  }

  @override
  String get guestLoginDisabled =>
      'تم تعطيل تسجيل الدخول كضيف. يرجى تفعيل المصادقة المجهولة في وحدة تحكم Firebase.';

  @override
  String get phoneInputHint => '000 000 0000';

  @override
  String get otpInputHint => '••••••';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get enterYourName => 'أدخل اسمك';

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get phoneInputPlaceholder => '+1 (555) 123-4567';

  @override
  String get privacy => 'الخصوصية';

  @override
  String get deleteAccount => 'حذف الحساب';

  @override
  String get appName => 'أكفيو';

  @override
  String get appSubtitle => 'إنشاء محتوى بقوة الذكاء الاصطناعي';

  @override
  String get yourIdea => '📝 فكرتك';

  @override
  String get settingsSection => '⚙️ الإعدادات';

  @override
  String get outputType => 'نوع المخرجات';

  @override
  String get video => 'فيديو';

  @override
  String get image => 'صورة';

  @override
  String get style => 'الأسلوب';

  @override
  String get aspectRatio16x9 => '16:9 (أفقي)';

  @override
  String get aspectRatio9x16 => '9:16 (رأسي)';

  @override
  String get voice => 'الصوت';

  @override
  String get size => 'الحجم';

  @override
  String get costSection => '💰 التكلفة';

  @override
  String get cost => '2.99';

  @override
  String get currency => 'ر.س';

  @override
  String get loginRequired => 'تسجيل الدخول مطلوب';

  @override
  String get pleaseLoginToGenerate =>
      'يرجى تسجيل الدخول لإنشاء الفيديو الخاص بك.';

  @override
  String get generateMagic => 'إنشاء السحر';

  @override
  String get dialectSaudi => 'السعودية';

  @override
  String get dialectEgyptian => 'مصر';

  @override
  String get dialectUAE => 'الإمارات';

  @override
  String get dialectLebanese => 'لبنان';

  @override
  String get dialectJordanian => 'الأردن';

  @override
  String get dialectMoroccan => 'المغرب';

  @override
  String get sizeSquare => 'مربع (1024x1024)';

  @override
  String get sizeLandscape => 'أفقي (1920x1080)';

  @override
  String get sizePortrait => 'رأسي (1080x1920)';

  @override
  String get chooseVisualMood => 'اختر المظهر البصري للفيديو الخاص بك';

  @override
  String get selectVideoLength => 'حدد طول الفيديو';

  @override
  String get chooseVideoOrientation => 'اختر اتجاه الفيديو';

  @override
  String get configureNarratorVoice => 'قم بتكوين صوت الراوي';

  @override
  String get durationQuick => 'سريع';

  @override
  String get durationStandard => 'قياسي';

  @override
  String get bestForYouTube => 'الأفضل لـ YouTube';

  @override
  String get bestForTikTok => 'الأفضل لـ TikTok';

  @override
  String get noCreationsYetTitle => 'لا توجد إبداعات بعد';

  @override
  String get startCreatingVideos => 'ابدأ في إنشاء مقاطع فيديو رائعة!';

  @override
  String get scriptStep => 'البرنامج النصي';

  @override
  String get audioStep => 'الصوت';

  @override
  String get videoStep => 'الفيديو';

  @override
  String get backgroundGenerationInfo =>
      'يمكنك إغلاق التطبيق بأمان. سيستمر الفيديو في الإنشاء في الخلفية.';

  @override
  String get mediaGallery => 'معرض الوسائط';

  @override
  String get createNow => 'إنشاء الآن';

  @override
  String get videoDownloadSuccess =>
      'تم تحميل الفيديو إلى مجلد مؤقت!\nملاحظة: حفظ المعرض يتطلب أذونات إضافية.';

  @override
  String downloadError(String error) {
    return 'خطأ: $error';
  }

  @override
  String shareError(String error) {
    return 'فشل المشاركة: $error';
  }

  @override
  String get completeYourPayment => 'أكمل الدفع';

  @override
  String get totalAmount => 'المبلغ الإجمالي';

  @override
  String get payWithTabby => 'الدفع عبر تابي';

  @override
  String get payWithApplePay => 'الدفع عبر Apple Pay';

  @override
  String get payWithSTCPay => 'الدفع عبر STC Pay';

  @override
  String get payWithCard => 'الدفع عبر البطاقة';
}
