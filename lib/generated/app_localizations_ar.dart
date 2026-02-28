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
  String get backToLogin => 'العودة لتسجيل الدخول';

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
  String get alreadyGenerating =>
      'جاري الإنشاء! يرجى الانتظار حتى اكتمال العملية الحالية.';

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
  String get guestCreditsUsed => 'لقد استهلكت رصيد الزائر المجاني.';

  @override
  String get guestUpgradePrompt =>
      'سجّل الدخول أو أنشئ حسابًا للحصول على رصيد إضافي ومتابعة الإنشاء.';

  @override
  String get guestLimitExceeded =>
      'تم استخدام وضع الزائر مسبقًا على هذا الجهاز. يرجى تسجيل الدخول أو إنشاء حساب.';

  @override
  String get accountCreatedSuccessfully => 'تم إنشاء الحساب بنجاح';

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
  String get processing => 'قيد المعالجة';

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
  String get currency => '﷼';

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
  String get payWithTap => 'الدفع عبر تاب';

  @override
  String get payWithApplePay => 'الدفع عبر Apple Pay';

  @override
  String get payWithSTCPay => 'الدفع عبر STC Pay';

  @override
  String get payWithCard => 'الدفع عبر البطاقة';

  @override
  String get emailOrPhone => 'البريد الإلكتروني أو الهاتف';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get continueButton => 'متابعة';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get alreadyHaveAccount => 'هل لديك حساب بالفعل؟';

  @override
  String get phone => 'الهاتف';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get joinAndStartCreating => 'انضم وابدأ في إنشاء مقاطع فيديو رائعة';

  @override
  String get styleHeader => 'الأسلوب';

  @override
  String get durationHeader => 'المدة';

  @override
  String get aspectRatioHeader => 'نسبة العرض';

  @override
  String get voiceSettingsHeader => 'إعدادات الصوت';

  @override
  String get sizeHeader => 'الحجم';

  @override
  String get quick => 'سريع';

  @override
  String get standard => 'قياسي';

  @override
  String get horizontal => 'أفقي';

  @override
  String get vertical => 'رأسي';

  @override
  String get square => 'مربع';

  @override
  String get landscape => 'أفقي';

  @override
  String get portrait => 'رأسي';

  @override
  String get recentProjects => 'المشاريع الأخيرة';

  @override
  String get viewAll => 'عرض الكل';

  @override
  String get createMagic => 'إنشاء السحر';

  @override
  String get productAd => 'إعلان منتج';

  @override
  String get socialReel => 'ريل تواصل';

  @override
  String get render3D => 'تصيير ثلاثي الأبعاد';

  @override
  String get avatar => 'أفاتار';

  @override
  String get advancedSettings => 'إعدادات متقدمة';

  @override
  String get credits => 'الرصيد';

  @override
  String get viewLibrary => 'عرض المكتبة';

  @override
  String get modelVersion => 'الإصدار 4.0';

  @override
  String get generating => 'جاري الإنشاء...';

  @override
  String get quickSuggestions => 'اقتراحات سريعة';

  @override
  String get buyCredits => 'إضافة رصيد';

  @override
  String get currentBalance => 'الرصيد الحالي';

  @override
  String creditBalance(int count) {
    return 'رصيد الأرصدة';
  }

  @override
  String purchaseCredits(int count, String price) {
    return 'إضافة $count ﷼ - $price ريال';
  }

  @override
  String videosOrImages(String videos, String images) {
    return '$videos فيديو أو $images صورة';
  }

  @override
  String get popularBadge => 'الأكثر شعبية';

  @override
  String get bestValueBadge => 'أفضل قيمة';

  @override
  String get tabbyInstallments => 'قسّم مشترياتك إلى 4 دفعات بدون فوائد';

  @override
  String get paymentsOf => '4 دفعات بقيمة';

  @override
  String get tabbyBenefits =>
      '• ادفع الدفعة الأولى الآن\n• الدفعات الـ 3 المتبقية كل أسبوعين\n• لا فوائد، لا رسوم';

  @override
  String get continueToTabby => 'المتابعة إلى تابي';

  @override
  String get tapPaymentInfo => 'دفع آمن عبر بطاقة ائتمان/خصم من تاب';

  @override
  String get tapPaymentMethods =>
      'مدعوم: فيزا، ماستركارد، مدى، أمريكان إكسبريس';

  @override
  String get balanceToAdd => 'الرصيد المضاف';

  @override
  String get continueToPayment => 'المتابعة للدفع';

  @override
  String get addedToBalance => 'تمت إضافته لرصيدك';

  @override
  String get securePaymentTap => 'دفع آمن عبر تاب';

  @override
  String get securePaymentApple => 'دفع آمن عبر Apple';

  @override
  String get confirmPurchaseTitle => 'تأكيد الشراء';

  @override
  String get confirmPurchaseInfo => 'سيتم الدفع عبر Apple Pay لهذا الشراء.';

  @override
  String get packageDetails => 'تفاصيل الباقة';

  @override
  String generatesApprox(String videos, String images) {
    return 'تنتج تقريباً $videos فيديو أو $images صور';
  }

  @override
  String get confirmAndPay => 'تأكيد والدفع';

  @override
  String firstPayment(String amount) {
    return 'الدفعة الأولى: $amount ريال';
  }

  @override
  String get paymentSuccessTitle => 'تم الدفع بنجاح!';

  @override
  String creditsAdded(int count) {
    return 'تمت إضافة $count رصيد إلى حسابك';
  }

  @override
  String get startCreatingButton => 'ابدأ الإنشاء';

  @override
  String get paymentFailedTitle => 'فشل الدفع';

  @override
  String get paymentFailedMessage =>
      'تعذرت معالجة الدفع. يرجى المحاولة مرة أخرى.';

  @override
  String get purchaseButton => 'شراء';

  @override
  String get restorePurchases => 'استعادة';

  @override
  String get purchasesRestored => 'تم استعادة المشتريات بنجاح';

  @override
  String get restoreFailed => 'فشل استعادة المشتريات';

  @override
  String get securePaymentTabby => 'اشترِ الآن وادفع لاحقاً بأمان عبر تابي';

  @override
  String get insufficientCredits => 'رصيد غير كافٍ';

  @override
  String needCreditsMessage(int count, String type) {
    return 'تحتاج إلى $count رصيد لإنشاء $type.';
  }

  @override
  String yourBalance(int count) {
    return 'رصيدك: $count رصيد';
  }

  @override
  String get enhancingIdea => 'جاري تحسين فكرتك...';

  @override
  String get enhancingVideoIdea => 'جاري تحسين فكرة الفيديو...';

  @override
  String get enhancingImageIdea => 'جاري تحسين فكرة الصورة...';

  @override
  String get preparingPrompt => 'جاري تحضير الوصف...';

  @override
  String get preparingVideoPrompt => 'جاري تحضير وصف الفيديو...';

  @override
  String get preparingImagePrompt => 'جاري تحضير وصف الصورة...';

  @override
  String get bringingImageToLife => 'جاري تحويل صورتك إلى حياة...';

  @override
  String get creatingVideo => 'جاري إنشاء الفيديو...';

  @override
  String get generatingImage => 'جاري إنشاء الصورة...';

  @override
  String get creatingMasterpiece => 'جاري إنشاء تحفتك...';

  @override
  String get creatingVideoMasterpiece => 'جاري إنشاء تحفة الفيديو...';

  @override
  String get creatingImageMasterpiece => 'جاري إنشاء تحفة الصورة...';

  @override
  String get magicComplete => 'اكتمل السحر!';

  @override
  String get videoComplete => 'اكتمل الفيديو!';

  @override
  String get imageComplete => 'اكتملت الصورة!';

  @override
  String get generatingVideoTitle => 'جاري إنشاء الفيديو';

  @override
  String get generatingImageTitle => 'جاري إنشاء الصورة';

  @override
  String get library => 'المكتبة';

  @override
  String get allCreations => 'جميع الإبداعات';

  @override
  String get playVideo => 'تشغيل الفيديو';

  @override
  String get viewImage => 'عرض الصورة';

  @override
  String createdOn(String date) {
    return 'تم الإنشاء في $date';
  }

  @override
  String get checkLaterInMyCreations => 'تحقق لاحقاً في إبداعاتي';

  @override
  String get creator => 'منشئ';

  @override
  String get speechRecognitionNotAvailable => 'التعرف على الصوت غير متاح';

  @override
  String get microphonePermissionRequired => 'يجب منح إذن الميكروفون';

  @override
  String failedToEnhancePrompt(Object error) {
    return 'فشل في تحسين الوصف: $error';
  }

  @override
  String get moreStyles => 'المزيد من الأنماط';

  @override
  String get showLess => 'عرض أقل';

  @override
  String get enhancing => 'جاري التحسين...';

  @override
  String get didNotReceiveCode => 'لم تستلم الرمز؟';

  @override
  String get weSentCodeTo => 'لقد أرسلنا رمزًا إلى';

  @override
  String youWillGenerate(Object label) {
    return 'سوف تقوم بإنشاء $label';
  }

  @override
  String get yourGallery => 'معرضك';

  @override
  String get emptyGalleryDescription =>
      'ابدأ في إنشاء مقاطع فيديو وصور مذهلة بواسطة الذكاء الاصطناعي ببضع نقرات فقط';

  @override
  String get createYourFirst => 'أنشئ أول فيديو لك';

  @override
  String get generatingMagic => 'جاري إنشاء السحر...';

  @override
  String get generationTimedOut => 'انتهت مهلة الإنشاء';

  @override
  String get cinematic => 'سينمائي';

  @override
  String get realEstate => 'عقارات';

  @override
  String get educational => ' تعليمي';

  @override
  String get corporate => 'شركات';

  @override
  String get gaming => 'ألعاب';

  @override
  String get musicVideo => 'فيديو موسيقي';

  @override
  String get documentary => 'وثائقي';

  @override
  String get adminDashboard => 'لوحة المعلومات';

  @override
  String get adminUsers => 'المستخدمون';

  @override
  String get adminContent => 'المحتوى';

  @override
  String get adminPayments => 'المدفوعات';

  @override
  String get adminSettings => 'الإعدادات';

  @override
  String get dashboardMetrics => 'مقاييس لوحة المعلومات';

  @override
  String get totalUsers => 'إجمالي المستخدمين';

  @override
  String get totalVideos => 'إجمالي الفيديوهات';

  @override
  String get totalRevenue => 'إجمالي الإيرادات';

  @override
  String get videosGenerated => 'فيديوهات تم إنشاؤها';

  @override
  String get activeGenerations => 'عمليات الإنشاء النشطة';

  @override
  String get successRate => 'معدل النجاح';

  @override
  String get recentUsers => 'المستخدمون الأخيرون';

  @override
  String get recentVideos => 'الفيديوهات الأخيرة';

  @override
  String get recentTransactions => 'المعاملات الأخيرة';

  @override
  String get userList => 'قائمة المستخدمين';

  @override
  String get searchByEmail => 'ابحث برسالة بريد إلكترونية أو اسم مستخدم';

  @override
  String get phoneNumberLabel => 'الهاتف';

  @override
  String get creditsLabel => 'الأرصدة';

  @override
  String get statusLabel => 'الحالة';

  @override
  String get actionLabel => 'إجراء';

  @override
  String get banUser => 'حظر المستخدم';

  @override
  String get unbanUser => 'إلغاء حظر المستخدم';

  @override
  String get viewDetails => 'عرض التفاصيل';

  @override
  String get contentManagement => 'إدارة المحتوى';

  @override
  String get searchByPrompt => 'ابحث بالطلب أو اسم المستخدم';

  @override
  String get typeFilter => 'النوع';

  @override
  String get statusFilter => 'الحالة';

  @override
  String get allTypes => 'جميع الأنواع';

  @override
  String get allStatus => 'جميع الحالات';

  @override
  String get completed => 'مكتمل';

  @override
  String get contentPreview => 'معاينة';

  @override
  String get copyUrl => 'نسخ الرابط';

  @override
  String get userInformation => 'معلومات المستخدم';

  @override
  String get joined => 'انضم في';

  @override
  String get adjustCredits => 'ضبط الأرصدة';

  @override
  String get amount => 'المبلغ';

  @override
  String get reason => 'السبب';

  @override
  String get bonus => 'مكافأة';

  @override
  String get refund => 'استرجاع';

  @override
  String get correction => 'تصحيح';

  @override
  String get other => 'آخر';

  @override
  String get notes => 'ملاحظات (اختياري)';

  @override
  String get accountStatus => 'حالة الحساب';

  @override
  String get active => 'نشط';

  @override
  String get banned => 'محظور';

  @override
  String get bannedOn => 'تم الحظر في';

  @override
  String get banReason => 'السبب';

  @override
  String get recentCreations => 'الإبداعات الأخيرة';

  @override
  String get noCreations => 'لا توجد إبداعات حتى الآن';

  @override
  String get paymentsList => 'قائمة المدفوعات';

  @override
  String get paymentId => 'معرّف الدفع';

  @override
  String get paymentStatus => 'الحالة';

  @override
  String get paymentDate => 'التاريخ';

  @override
  String get transactionId => 'معرّف المعاملة';

  @override
  String get adminLogout => 'تسجيل الخروج';

  @override
  String get adminProfile => 'ملف المسؤول';

  @override
  String get adminEmail => 'البريد الإلكتروني';

  @override
  String get adminRole => 'الدور';

  @override
  String get adminPermissions => 'الصلاحيات';

  @override
  String get switchToApp => 'التبديل إلى التطبيق';

  @override
  String get administrator => 'مسؤول النظام';

  @override
  String get areYouSure => 'هل أنت متأكد؟';

  @override
  String get deleteContentMsg => 'سيتم حذف هذا المحتوى بشكل دائم';

  @override
  String get confirmBan => 'هل أنت متأكد من حظر هذا المستخدم؟';

  @override
  String get unbanConfirm => 'هل أنت متأكد من إلغاء حظر هذا المستخدم؟';

  @override
  String get userNotFound => 'لم يتم العثور على المستخدم';

  @override
  String get contentNotFound => 'لم يتم العثور على المحتوى';

  @override
  String get creditsAdjusted => 'تم ضبط الأرصدة بنجاح';

  @override
  String get userBanned => 'تم حظر المستخدم';

  @override
  String get userUnbanned => 'تم إلغاء حظر المستخدم';

  @override
  String get contentDeleted => 'تم حذف المحتوى بنجاح';

  @override
  String get errorAdjustingCredits => 'خطأ في ضبط الأرصدة';

  @override
  String get errorBanningUser => 'خطأ في حظر المستخدم';

  @override
  String get errorLoadingUsers => 'خطأ في تحميل المستخدمين';

  @override
  String get errorLoadingContent => 'خطأ في تحميل المحتوى';

  @override
  String get profileUpdatedSuccess => 'تم تحديث الملف الشخصي بنجاح';

  @override
  String get profileUpdateFailed => 'فشل تحديث الملف الشخصي';

  @override
  String get helpSupport => 'المساعدة والدعم';

  @override
  String get accountSettingsTitle => 'إعدادات الحساب';

  @override
  String get enhanceCinematic => 'بإضاءة سينمائية وتصحيح ألوان احترافي';

  @override
  String get enhance4K => 'بجودة 4K مذهلة وجو درامي';

  @override
  String get enhanceMusic => 'مع موسيقى ملحمية وانتقالات سلسة';

  @override
  String get enhanceDynamic => 'بلمسات ديناميكية وألوان زاهية';

  @override
  String get enhanceHollywood => 'بجودة إنتاج سينمائية';

  @override
  String get enhancePremium => 'بجودة ممتازة وتكوين فني';

  @override
  String get enterName => 'أدخل اسمك';

  @override
  String get enterPhone => 'أدخل رقم هاتفك';

  @override
  String get logoutConfirmationTitle => 'تسجيل الخروج';

  @override
  String get logoutConfirmationMessage => 'هل أنت متأكد أنك تريد تسجيل الخروج؟';

  @override
  String get deleteAccountTitle => 'حذف الحساب';

  @override
  String get deleteAccountMessage =>
      'لا يمكن التراجع عن هذا الإجراء. سيتم حذف جميع بياناتك بشكل دائم.';

  @override
  String get paymentMobileOnly => 'المدفوعات متاحة فقط على تطبيق الجوال';

  @override
  String get imagePreview => 'معاينة الصورة';

  @override
  String get videoPreviewTitle => 'معاينة الفيديو';

  @override
  String get saveToPhotos => 'حفظ';

  @override
  String get remix => 'إعادة إنشاء';

  @override
  String get loop => 'تكرار';

  @override
  String get noLoop => 'بدون تكرار';

  @override
  String get prompt => 'الوصف';

  @override
  String get noPromptAvailable => 'لا يوجد وصف متاح';

  @override
  String get promptDetails => 'تفاصيل الوصف';

  @override
  String get tryAgainWithPrompt => 'حاول مرة أخرى بهذا الوصف';

  @override
  String get generateNewVideo => 'إنشاء فيديو جديد؟';

  @override
  String get generateNewContent => 'إنشاء محتوى جديد؟';

  @override
  String get chooseVariation => 'اختر كيف تريد إنشاء نسخة جديدة';

  @override
  String get useSamePrompt => 'استخدام نفس الوصف';

  @override
  String get enhancePrompt => 'تحسين الوصف';

  @override
  String get newPrompt => 'وصف جديد';

  @override
  String get savedToPhotos => 'تم الحفظ في الصور بنجاح!';

  @override
  String get failedToSave => 'فشل الحفظ في الصور. هل تم رفض الإذن؟';

  @override
  String shareFailed(Object error) {
    return 'فشلت المشاركة: $error';
  }

  @override
  String get listView => 'قائمة';

  @override
  String get gridView => 'شبكة';

  @override
  String get styleCinematic => 'سينمائي';

  @override
  String get styleAnimation => 'رسوم متحركة';

  @override
  String get styleMinimal => 'بسيط';

  @override
  String get styleModern => 'عصري';

  @override
  String get styleCorporate => 'احترافي';

  @override
  String get styleSocialMedia => 'سوشيال ميديا';

  @override
  String get styleVintage => 'كلاسيكي';

  @override
  String get styleFantasy => 'خيالي';

  @override
  String get styleDocumentary => 'وثائقي';

  @override
  String get styleHorror => 'رعب';

  @override
  String get styleComedy => 'كوميدي';

  @override
  String get styleSciFi => 'خيال علمي';

  @override
  String get styleNoir => 'نوار';

  @override
  String get styleDreamlike => 'حالم';

  @override
  String get styleRetro => 'ريترو';

  @override
  String get styleTealFrame => 'إطار أزرق مخضر';

  @override
  String get styleNavyExecutive => 'كحلي تنفيذي';

  @override
  String get styleForestGreen => 'أخضر طبيعي';

  @override
  String get styleRoyalPurple => 'بنفسجي ملكي';

  @override
  String get styleSunsetOrange => 'برتقالي غروب';

  @override
  String get stylePromptCinematic =>
      'بأسلوب سينمائي مع إضاءة درامية وتكوين احترافي';

  @override
  String get stylePromptAnimation =>
      'بأسلوب رسوم متحركة مع ألوان نابضة بالحياة وحركة سلسة';

  @override
  String get stylePromptMinimal => 'بأسلوب بسيط ونظيف مع تكوينات مبسطة';

  @override
  String get stylePromptModern => 'بأسلوب عصري ومعاصر';

  @override
  String get stylePromptCorporate => 'بأسلوب احترافي للشركات';

  @override
  String get stylePromptSocialMedia =>
      'بأسلوب جذاب لوسائل التواصل الاجتماعي مع طاقة ديناميكية';

  @override
  String get stylePromptVintage =>
      'بأسلوب كلاسيكي مع جماليات قديمة ومظهر فيلم عتيق';

  @override
  String get stylePromptFantasy => 'بأسلوب خيالي مع عناصر سحرية وأجواء أسطورية';

  @override
  String get stylePromptDocumentary => 'بأسلوب وثائقي مع نهج واقعي ورصدي';

  @override
  String get stylePromptHorror => 'بأسلوب رعب مع أجواء مظلمة ومزاج مشوق';

  @override
  String get stylePromptComedy => 'بأسلوب كوميدي مع طاقة مرحة وخفيفة';

  @override
  String get stylePromptSciFi =>
      'بأسلوب خيال علمي مع تقنية مستقبلية وجماليات متقدمة';

  @override
  String get stylePromptNoir => 'بأسلوب فيلم نوار مع تباين عالي وظلال درامية';

  @override
  String get stylePromptDreamlike => 'بأسلوب حالم مع أجواء سريالية وأثيرية';

  @override
  String get stylePromptRetro => 'بأسلوب ريترو من الثمانينات والتسعينات';

  @override
  String get stylePromptTealFrame =>
      'بإطار أزرق مخضر احترافي مع تخطيط بطاقات نظيف وزوايا مستديرة وظلال ناعمة على خلفية فاتحة';

  @override
  String get stylePromptNavyExecutive =>
      'بأسلوب كحلي تنفيذي مع لمسات ذهبية وتكوين رسمي وأناقة مؤسسية';

  @override
  String get stylePromptForestGreen =>
      'بلوحة ألوان خضراء مستوحاة من الطبيعة مع أشكال عضوية ونغمات ترابية وأجواء هادئة';

  @override
  String get stylePromptRoyalPurple =>
      'بأسلوب بنفسجي ملكي أنيق مع تدرجات فاخرة وطباعة راقية وإحساس فاخر';

  @override
  String get stylePromptSunsetOrange =>
      'بتدرج برتقالي غروب دافئ مع طاقة نابضة بالحياة وإضاءة الساعة الذهبية ومزاج ملهم';

  @override
  String get supportTitle => 'المساعدة والدعم';

  @override
  String get supportSubtitle =>
      'نحن هنا للمساعدة! تواصل معنا لأي استفسارات أو مشاكل.';

  @override
  String get emailUs => 'راسلنا عبر البريد الإلكتروني';

  @override
  String get responseTime => 'وقت الاستجابة';

  @override
  String get responseTimeValue => 'خلال 24-48 ساعة';

  @override
  String get faqTitle => 'الأسئلة الشائعة';

  @override
  String get faqQuestion1 => 'كيف أنشئ فيديو؟';

  @override
  String get faqAnswer1 =>
      'ببساطة أدخل فكرتك في حقل النص، اختر الأسلوب والإعدادات المفضلة لديك، ثم اضغط على \'إنشاء\'. سيقوم الذكاء الاصطناعي بإنشاء الفيديو الخاص بك تلقائياً.';

  @override
  String get faqQuestion2 => 'كيف يعمل نظام الرصيد؟';

  @override
  String get faqAnswer2 =>
      'يُستخدم الرصيد لإنشاء الفيديوهات والصور. كل عملية إنشاء تكلف مبلغاً معيناً من الرصيد بناءً على نوع المخرجات والإعدادات.';

  @override
  String get faqQuestion3 => 'هل يمكنني استرداد أموالي؟';

  @override
  String get faqAnswer3 =>
      'يرجى التواصل مع فريق الدعم لطلبات الاسترداد. نقوم بمراجعة كل حالة على حدة.';

  @override
  String get privacyPolicyTitle => 'سياسة الخصوصية';

  @override
  String get privacyIntro => 'مقدمة';

  @override
  String get privacyIntroContent =>
      'نحن في Aqvioo نحترم خصوصية مستخدمينا ونسعى لحماية بياناتهم الشخصية. تهدف هذه السياسة إلى توضيح كيفية جمع المعلومات واستخدامها وحمايتها عند استخدامك لتطبيقنا.';

  @override
  String get privacySection1Title => '١. المعلومات التي نجمعها';

  @override
  String get privacySection1Content =>
      'نجمع بعض المعلومات الضرورية فقط لتشغيل خدمات التطبيق وتحسين التجربة، وتشمل:\n\nالمعلومات التي يقدمها المستخدم طوعًا:\n• النصوص أو الأفكار التي يكتبها المستخدم لإنشاء الفيديو أو الصورة\n• الصور أو الملفات التي يرفعها المستخدم داخل التطبيق\n• معلومات الاتصال (مثل البريد الإلكتروني) عند التواصل معنا للدعم الفني\n\nالمعلومات التقنية (تلقائيًا):\n• نوع الجهاز ونظام التشغيل وإصدار التطبيق\n• بيانات الاستخدام العامة (عدد مرات الاستخدام، الأخطاء، مدة الجلسة)\n\nلا نجمع أي بيانات تحدد هوية المستخدم بشكل مباشر بدون إذنه.';

  @override
  String get privacySection2Title => '٢. استخدام المعلومات';

  @override
  String get privacySection2Content =>
      'نستخدم المعلومات التي يتم جمعها من أجل:\n• إنشاء المحتوى المطلوب (النصوص، الفيديوهات، الصوتيات)\n• تحسين أداء التطبيق وتجربة المستخدم\n• تقديم الدعم الفني والرد على الاستفسارات\n• إرسال إشعارات أو تحديثات متعلقة بالتطبيق (عند تفعيلها من المستخدم)\n\nنؤكد أن جميع البيانات التي يتم إدخالها لغرض إنشاء الفيديو لا تُستخدم لأغراض تسويقية أو مشاركة خارجية.';

  @override
  String get privacySection3Title => '٣. مشاركة البيانات';

  @override
  String get privacySection3Content =>
      'نحن لا نشارك أي بيانات شخصية مع أطراف ثالثة.';

  @override
  String get privacySection4Title => '٤. حفظ البيانات وأمنها';

  @override
  String get privacySection4Content =>
      '• يتم الاحتفاظ بالبيانات مؤقتًا فقط أثناء عملية إنشاء الفيديو أو الصورة\n• لا نقوم بتخزين أي ملفات أو نصوص للمستخدم بعد الانتهاء من العملية\n• نستخدم بروتوكولات أمان وتشفير لحماية جميع البيانات أثناء النقل بين المستخدم والخوادم';

  @override
  String get privacySection5Title => '٥. عمليات الدفع';

  @override
  String get privacySection5Content =>
      '• تتم جميع عمليات الدفع من خلال مزودي خدمات آمنة مثل Apple Pay، STC Pay، Visa، MasterCard، Mada\n• نحن لا نخزن أي معلومات بطاقات ائتمان أو بيانات مالية داخل التطبيق\n• جميع المعاملات تخضع لسياسات الأمان الخاصة بمزودي الدفع';

  @override
  String get privacySection6Title => '٦. حقوق المستخدم';

  @override
  String get privacySection6Content =>
      'للمستخدم الحق في:\n• طلب حذف بياناته أو الصور والنصوص التي أرسلها\n• إيقاف استخدام التطبيق في أي وقت دون أي التزام\n• التواصل معنا لطلب توضيحات أو شكاوى عبر البريد الإلكتروني';

  @override
  String get privacySection7Title => '٧. التعديلات على سياسة الخصوصية';

  @override
  String get privacySection7Content =>
      'قد نقوم بتحديث هذه السياسة من وقت لآخر بما يتناسب مع التحديثات التقنية أو القانونية. سيتم إشعار المستخدمين بأي تغييرات جوهرية من خلال التطبيق أو البريد الإلكتروني.';

  @override
  String get privacySection8Title => '٨. الاتصال بنا';

  @override
  String get privacySection8Content =>
      'إذا كان لديك أي استفسار أو ملاحظة حول سياسة الخصوصية، يمكنك التواصل معنا عبر:\nAqvioo@outlook.sa';

  @override
  String get notificationVideoReadyTitle => 'الفيديو جاهز!';

  @override
  String get notificationVideoReadyBody => 'تم إنشاء الفيديو بنجاح.';

  @override
  String get notificationImageReadyTitle => 'الصورة جاهزة!';

  @override
  String get notificationImageReadyBody => 'تم إنشاء الصورة بنجاح.';

  @override
  String get notificationGenerationFailedTitle => 'فشل الإنشاء';

  @override
  String get notificationTimeoutTitle => 'انتهت مهلة الإنشاء';

  @override
  String get notificationTimeoutBody => 'يرجى المحاولة مرة أخرى لاحقًا.';

  @override
  String get saveChanges => 'حفظ التغييرات';
}
