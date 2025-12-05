// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Aqvioo';

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
  String get backToLogin => 'Back to login';

  @override
  String get google => 'Google';

  @override
  String get apple => 'Apple';

  @override
  String get stepIdea => 'Idea';

  @override
  String get stepStyle => 'Style';

  @override
  String get stepFinalize => 'Finalize';

  @override
  String get ideaStepPlaceholder =>
      'Describe your video idea... e.g., \'A futuristic city with flying cars\'';

  @override
  String get addImage => 'Add Image';

  @override
  String get imageAdded => 'Image Added';

  @override
  String get buttonBack => 'Back';

  @override
  String get buttonNext => 'Next';

  @override
  String get promptRequired => 'Please enter a prompt to continue';

  @override
  String errorMessage(String error) {
    return 'Error: $error';
  }

  @override
  String get myCreations => 'My Creations';

  @override
  String get noCreationsYet => 'No creations yet';

  @override
  String get startCreating => 'Start creating your first video!';

  @override
  String get createNew => 'Create New';

  @override
  String get videoLength => 'Video Length';

  @override
  String get aspectRatio => 'Aspect Ratio';

  @override
  String get voiceGender => 'Voice Gender';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get duration => 'Duration';

  @override
  String get seconds => 'seconds';

  @override
  String get generate => 'Generate';

  @override
  String get creating => 'Creating';

  @override
  String get generatingVideo => 'Generating your video...';

  @override
  String get preview => 'Preview';

  @override
  String get share => 'Share';

  @override
  String get download => 'Download';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get login => 'Login';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get signUp => 'Sign Up';

  @override
  String get or => 'OR';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get continueWithApple => 'Continue with Apple';

  @override
  String get creatingMagic => 'Creating Magic...';

  @override
  String get almostDone => 'Almost Done!';

  @override
  String get processingVideo => 'Processing your video';

  @override
  String get thisWillTakeAMoment => 'This will take a moment';

  @override
  String get videoPreview => 'Video Preview';

  @override
  String get playPause => 'Play/Pause';

  @override
  String get restart => 'Restart';

  @override
  String get downloadVideo => 'Download Video';

  @override
  String get shareVideo => 'Share Video';

  @override
  String get deleteVideo => 'Delete Video';

  @override
  String get confirmDelete => 'Are you sure you want to delete this video?';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get english => 'English';

  @override
  String get arabic => 'Arabic';

  @override
  String get theme => 'Theme';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get systemDefault => 'System Default';

  @override
  String get notifications => 'Notifications';

  @override
  String get account => 'Account';

  @override
  String get profile => 'Profile';

  @override
  String get logout => 'Logout';

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get payment => 'Payment';

  @override
  String get proceedToPayment => 'Proceed to Payment';

  @override
  String get paymentSuccessful => 'Payment Successful';

  @override
  String get paymentFailed => 'Payment Failed';

  @override
  String get total => 'Total';

  @override
  String get price => 'Price';

  @override
  String get gallery => 'Gallery';

  @override
  String get selectMedia => 'Select Media';

  @override
  String get photos => 'Photos';

  @override
  String get videos => 'Videos';

  @override
  String get recentMedia => 'Recent Media';

  @override
  String get loading => 'Loading...';

  @override
  String get retry => 'Retry';

  @override
  String get success => 'Success';

  @override
  String get failed => 'Failed';

  @override
  String get warning => 'Warning';

  @override
  String get info => 'Information';

  @override
  String get confirm => 'Confirm';

  @override
  String get close => 'Close';

  @override
  String get step1Script => 'Script';

  @override
  String get step2Voice => 'Voice';

  @override
  String get step3Video => 'Video';

  @override
  String get all => 'All';

  @override
  String get images => 'Images';

  @override
  String get noCreationsYetMessage => 'Start creating your first video!';

  @override
  String get selectVideo => 'Select Video';

  @override
  String get enterPassword => 'Enter Password';

  @override
  String get accountSettings => 'Account Settings';

  @override
  String get otpVerification => 'OTP Verification';

  @override
  String get enterOtp => 'Enter OTP';

  @override
  String get resend => 'Resend';

  @override
  String get twoFactor => 'Two-Factor Authentication';

  @override
  String get musicTrack => 'Music Track';

  @override
  String get voiceNarration => 'Voice Narration';

  @override
  String get noMusicSelected => 'No Music Selected';

  @override
  String get noVoiceSelected => 'No Voice Selected';

  @override
  String get selectMusicTrack => 'Select Music Track';

  @override
  String get addVoiceNarration => 'Add Voice Narration';

  @override
  String get confirmation => 'Confirmation';

  @override
  String get reviewCreation => 'Review Your Creation';

  @override
  String get titleRequired => 'Title is required';

  @override
  String get descriptionOptional => 'Description (optional)';

  @override
  String get creationTitle => 'Creation Title';

  @override
  String get creationDescription => 'Description';

  @override
  String get tapToUnlock => 'Tap to Unlock';

  @override
  String get appLocked => 'App Locked';

  @override
  String get unknownError => 'Unknown Error';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get processing => 'Processing';

  @override
  String get waitForOtp => 'Waiting for OTP code';

  @override
  String get empty => 'Empty';

  @override
  String get name => 'Name';

  @override
  String get created => 'Created';

  @override
  String get dateFormat => 'MMM dd, yyyy';

  @override
  String get deleteConfirmation => 'Are you sure?';

  @override
  String get deleteCreationMsg => 'This action cannot be undone';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get copied => 'Copied to clipboard';

  @override
  String get error => 'Error';

  @override
  String get ok => 'OK';

  @override
  String get whatToCreate => 'What would you like to create?';

  @override
  String get describeYourIdea =>
      'Describe your video idea and let AI do the magic.';

  @override
  String get enhance => 'Enhance';

  @override
  String get promptEnhanced => 'Prompt enhanced! ✨';

  @override
  String charsCount(int count) {
    return '$count chars';
  }

  @override
  String get guestLoginDisabled =>
      'Guest login is disabled. Please enable Anonymous Auth in Firebase Console.';

  @override
  String get phoneInputHint => '000 000 0000';

  @override
  String get otpInputHint => '••••••';

  @override
  String get fullName => 'Full Name';

  @override
  String get enterYourName => 'Enter your name';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get phoneInputPlaceholder => '+1 (555) 123-4567';

  @override
  String get privacy => 'Privacy';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get appName => 'Aqvioo';

  @override
  String get appSubtitle => 'AI-Powered Content Creation';

  @override
  String get yourIdea => '📝 Your Idea';

  @override
  String get settingsSection => '⚙️ Settings';

  @override
  String get outputType => 'Output Type';

  @override
  String get video => 'Video';

  @override
  String get image => 'Image';

  @override
  String get style => 'Style';

  @override
  String get aspectRatio16x9 => '16:9 (Horizontal)';

  @override
  String get aspectRatio9x16 => '9:16 (Vertical)';

  @override
  String get voice => 'Voice';

  @override
  String get size => 'Size';

  @override
  String get costSection => '💰 Cost';

  @override
  String get cost => '2.99';

  @override
  String get currency => 'ر.س';

  @override
  String get loginRequired => 'Login Required';

  @override
  String get pleaseLoginToGenerate => 'Please login to generate your video.';

  @override
  String get generateMagic => 'Generate Magic';

  @override
  String get dialectSaudi => 'Saudi';

  @override
  String get dialectEgyptian => 'Egyptian';

  @override
  String get dialectUAE => 'UAE';

  @override
  String get dialectLebanese => 'Lebanese';

  @override
  String get dialectJordanian => 'Jordanian';

  @override
  String get dialectMoroccan => 'Moroccan';

  @override
  String get sizeSquare => 'Square (1024x1024)';

  @override
  String get sizeLandscape => 'Landscape (1920x1080)';

  @override
  String get sizePortrait => 'Portrait (1080x1920)';

  @override
  String get chooseVisualMood => 'Choose the visual mood of your video';

  @override
  String get selectVideoLength => 'Select video length';

  @override
  String get chooseVideoOrientation => 'Choose video orientation';

  @override
  String get configureNarratorVoice => 'Configure narrator voice';

  @override
  String get durationQuick => 'Quick';

  @override
  String get durationStandard => 'Standard';

  @override
  String get bestForYouTube => 'Best for YouTube';

  @override
  String get bestForTikTok => 'Best for TikTok';

  @override
  String get noCreationsYetTitle => 'No creations yet';

  @override
  String get startCreatingVideos => 'Start creating amazing videos!';

  @override
  String get scriptStep => 'Script';

  @override
  String get audioStep => 'Audio';

  @override
  String get videoStep => 'Video';

  @override
  String get backgroundGenerationInfo =>
      'You can safely exit the app. Your video will continue generating in the background.';

  @override
  String get mediaGallery => 'Media Gallery';

  @override
  String get createNow => 'Create Now';

  @override
  String get videoDownloadSuccess =>
      'Video downloaded to temp folder!\nNote: Gallery save requires additional permissions.';

  @override
  String downloadError(String error) {
    return 'Error: $error';
  }

  @override
  String shareError(String error) {
    return 'Share failed: $error';
  }

  @override
  String get completeYourPayment => 'Complete Your Payment';

  @override
  String get totalAmount => 'Total Amount';

  @override
  String get payWithTabby => 'Pay with Tabby';

  @override
  String get payWithApplePay => 'Pay with Apple Pay';

  @override
  String get payWithSTCPay => 'Pay with STC Pay';

  @override
  String get payWithCard => 'Pay with Card';

  @override
  String get emailOrPhone => 'Email or Phone';

  @override
  String get signIn => 'Sign In';

  @override
  String get continueButton => 'Continue';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get phone => 'Phone';

  @override
  String get createAccount => 'Create Account';

  @override
  String get joinAndStartCreating => 'Join and start creating amazing videos';

  @override
  String get styleHeader => 'Style';

  @override
  String get durationHeader => 'Duration';

  @override
  String get aspectRatioHeader => 'Aspect Ratio';

  @override
  String get voiceSettingsHeader => 'Voice Settings';

  @override
  String get sizeHeader => 'Size';

  @override
  String get quick => 'Quick';

  @override
  String get standard => 'Standard';

  @override
  String get horizontal => 'Horizontal';

  @override
  String get vertical => 'Vertical';

  @override
  String get square => 'Square';

  @override
  String get landscape => 'Landscape';

  @override
  String get portrait => 'Portrait';

  @override
  String get recentProjects => 'Recent Projects';

  @override
  String get viewAll => 'View All';

  @override
  String get createMagic => 'Create Magic';

  @override
  String get productAd => 'Product Ad';

  @override
  String get socialReel => 'Social Reel';

  @override
  String get render3D => '3D Render';

  @override
  String get avatar => 'Avatar';

  @override
  String get advancedSettings => 'Advanced Settings';

  @override
  String get credits => 'Credits';

  @override
  String get viewLibrary => 'View Library';

  @override
  String get modelVersion => 'Model v4.0';

  @override
  String get generating => 'Generating...';

  @override
  String get quickSuggestions => 'Quick Suggestions';

  @override
  String get buyCredits => 'Buy Credits';

  @override
  String get currentBalance => 'Current Balance';

  @override
  String creditBalance(int count) {
    return 'Credit Balance';
  }

  @override
  String purchaseCredits(int count, String price) {
    return 'Purchase $count Credits - $price SAR';
  }

  @override
  String videosOrImages(String videos, String images) {
    return '$videos videos or $images images';
  }

  @override
  String get popularBadge => 'Popular';

  @override
  String get bestValueBadge => 'Best Value';

  @override
  String get tabbyInstallments =>
      'Split your purchase into 4 interest-free payments';

  @override
  String get paymentsOf => '4 payments of';

  @override
  String get tabbyBenefits =>
      '• Pay the first installment now\n• Remaining 3 payments every 2 weeks\n• No interest, no fees';

  @override
  String get continueToTabby => 'Continue to Tabby';

  @override
  String firstPayment(String amount) {
    return 'First payment: $amount SAR';
  }

  @override
  String get paymentSuccessTitle => 'Payment Successful!';

  @override
  String creditsAdded(int count) {
    return '$count credits have been added to your account';
  }

  @override
  String get startCreatingButton => 'Start Creating';

  @override
  String get paymentFailedTitle => 'Payment Failed';

  @override
  String get paymentFailedMessage =>
      'Unable to process payment with Tabby. Please try again.';

  @override
  String get securePaymentTabby => 'Secure buy now, pay later with Tabby';

  @override
  String get insufficientCredits => 'Insufficient Credits';

  @override
  String needCreditsMessage(int count, String type) {
    return 'You need $count credits to generate a $type.';
  }

  @override
  String yourBalance(int count) {
    return 'Your balance: $count credits';
  }

  @override
  String get enhancingIdea => 'Enhancing your idea...';

  @override
  String get preparingPrompt => 'Preparing your prompt...';

  @override
  String get bringingImageToLife => 'Bringing your image to life...';

  @override
  String get creatingVideo => 'Creating your video...';

  @override
  String get generatingImage => 'Generating your image...';

  @override
  String get creatingMasterpiece => 'Creating your masterpiece...';

  @override
  String get magicComplete => 'Magic Complete!';

  @override
  String get library => 'Library';

  @override
  String get allCreations => 'All Creations';

  @override
  String get playVideo => 'Play Video';

  @override
  String get viewImage => 'View Image';

  @override
  String createdOn(String date) {
    return 'Created on $date';
  }

  @override
  String get checkLaterInMyCreations => 'Check later in My Creations';

  @override
  String get creator => 'Creator';

  @override
  String get speechRecognitionNotAvailable =>
      'Speech recognition not available';

  @override
  String get microphonePermissionRequired =>
      'Microphone permission is required';

  @override
  String failedToEnhancePrompt(Object error) {
    return 'Failed to enhance prompt: $error';
  }

  @override
  String get moreStyles => 'More Styles';

  @override
  String get showLess => 'Show Less';

  @override
  String get enhancing => 'Enhancing...';

  @override
  String get didNotReceiveCode => 'Didn\'t receive the code? ';

  @override
  String get weSentCodeTo => 'We sent a code to';

  @override
  String youWillGenerate(Object label) {
    return 'You will generate $label';
  }

  @override
  String get yourGallery => 'YOUR GALLERY';

  @override
  String get emptyGalleryDescription =>
      'Start creating amazing AI-generated videos and images with just a few taps';

  @override
  String get createYourFirst => 'Create Your First';

  @override
  String get generatingMagic => 'Generating Magic...';

  @override
  String get generationTimedOut => 'Generation timed out';

  @override
  String get cinematic => 'Cinematic';

  @override
  String get realEstate => 'Real Estate';

  @override
  String get educational => 'Educational';

  @override
  String get corporate => 'Corporate';

  @override
  String get gaming => 'Gaming';

  @override
  String get musicVideo => 'Music Video';

  @override
  String get documentary => 'Documentary';

  @override
  String get adminDashboard => 'Dashboard';

  @override
  String get adminUsers => 'Users';

  @override
  String get adminContent => 'Content';

  @override
  String get adminPayments => 'Payments';

  @override
  String get adminSettings => 'Settings';

  @override
  String get dashboardMetrics => 'Dashboard Metrics';

  @override
  String get totalUsers => 'Total Users';

  @override
  String get totalVideos => 'Total Videos';

  @override
  String get totalRevenue => 'Total Revenue';

  @override
  String get videosGenerated => 'Videos Generated';

  @override
  String get activeGenerations => 'Active Generations';

  @override
  String get successRate => 'Success Rate';

  @override
  String get recentUsers => 'Recent Users';

  @override
  String get recentVideos => 'Recent Videos';

  @override
  String get recentTransactions => 'Recent Transactions';

  @override
  String get userList => 'User List';

  @override
  String get searchByEmail => 'Search by email or username';

  @override
  String get phoneNumberLabel => 'Phone';

  @override
  String get creditsLabel => 'Credits';

  @override
  String get statusLabel => 'Status';

  @override
  String get actionLabel => 'Action';

  @override
  String get banUser => 'Ban User';

  @override
  String get unbanUser => 'Unban User';

  @override
  String get viewDetails => 'View Details';

  @override
  String get contentManagement => 'Content Management';

  @override
  String get searchByPrompt => 'Search by prompt or user';

  @override
  String get typeFilter => 'Type';

  @override
  String get statusFilter => 'Status';

  @override
  String get allTypes => 'All Types';

  @override
  String get allStatus => 'All Status';

  @override
  String get completed => 'Completed';

  @override
  String get contentPreview => 'Preview';

  @override
  String get copyUrl => 'Copy URL';

  @override
  String get userInformation => 'User Information';

  @override
  String get joined => 'Joined';

  @override
  String get adjustCredits => 'Adjust Credits';

  @override
  String get amount => 'Amount';

  @override
  String get reason => 'Reason';

  @override
  String get bonus => 'Bonus';

  @override
  String get refund => 'Refund';

  @override
  String get correction => 'Correction';

  @override
  String get other => 'Other';

  @override
  String get notes => 'Notes (optional)';

  @override
  String get accountStatus => 'Account Status';

  @override
  String get active => 'Active';

  @override
  String get banned => 'Banned';

  @override
  String get bannedOn => 'Banned on';

  @override
  String get banReason => 'Reason';

  @override
  String get recentCreations => 'Recent Creations';

  @override
  String get noCreations => 'No creations yet';

  @override
  String get paymentsList => 'Payments List';

  @override
  String get paymentId => 'Payment ID';

  @override
  String get paymentStatus => 'Status';

  @override
  String get paymentDate => 'Date';

  @override
  String get transactionId => 'Transaction ID';

  @override
  String get adminLogout => 'Logout';

  @override
  String get adminProfile => 'Admin Profile';

  @override
  String get adminEmail => 'Email';

  @override
  String get adminRole => 'Role';

  @override
  String get adminPermissions => 'Permissions';

  @override
  String get areYouSure => 'Are you sure?';

  @override
  String get deleteContentMsg => 'This content will be permanently deleted';

  @override
  String get confirmBan => 'Are you sure you want to ban this user?';

  @override
  String get unbanConfirm => 'Are you sure you want to unban this user?';

  @override
  String get userNotFound => 'User not found';

  @override
  String get contentNotFound => 'Content not found';

  @override
  String get creditsAdjusted => 'Credits adjusted successfully';

  @override
  String get userBanned => 'User has been banned';

  @override
  String get userUnbanned => 'User has been unbanned';

  @override
  String get contentDeleted => 'Content deleted successfully';

  @override
  String get errorAdjustingCredits => 'Error adjusting credits';

  @override
  String get errorBanningUser => 'Error banning user';

  @override
  String get errorLoadingUsers => 'Error loading users';

  @override
  String get errorLoadingContent => 'Error loading content';
}
