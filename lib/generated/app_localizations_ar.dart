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
  String get buyCredits => 'شراء الرصيد';

  @override
  String get currentBalance => 'الرصيد الحالي';

  @override
  String creditBalance(int count) {
    return 'رصيد الأرصدة';
  }

  @override
  String purchaseCredits(int count, String price) {
    return 'شراء $count رصيد - $price ريال';
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
      'تعذرت معالجة الدفع عبر تابي. يرجى المحاولة مرة أخرى.';

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
  String get preparingPrompt => 'جاري تحضير الوصف...';

  @override
  String get bringingImageToLife => 'جاري تحويل صورتك إلى حياة...';

  @override
  String get creatingVideo => 'جاري إنشاء الفيديو...';

  @override
  String get generatingImage => 'جاري إنشاء الصورة...';

  @override
  String get creatingMasterpiece => 'جاري إنشاء تحفتك...';

  @override
  String get magicComplete => 'اكتمل السحر!';

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
}
