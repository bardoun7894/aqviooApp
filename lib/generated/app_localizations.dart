import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Aqvioo'**
  String get appTitle;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @verifyCode.
  ///
  /// In en, this message translates to:
  /// **'Verify Code'**
  String get verifyCode;

  /// No description provided for @enterPhoneToContinue.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number to continue'**
  String get enterPhoneToContinue;

  /// No description provided for @enterCodeSentTo.
  ///
  /// In en, this message translates to:
  /// **'Enter the code sent to {phoneNumber}'**
  String enterCodeSentTo(String phoneNumber);

  /// No description provided for @sendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get sendOtp;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @changeNumber.
  ///
  /// In en, this message translates to:
  /// **'Change Number'**
  String get changeNumber;

  /// No description provided for @continueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest'**
  String get continueAsGuest;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to login'**
  String get backToLogin;

  /// No description provided for @google.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get google;

  /// No description provided for @apple.
  ///
  /// In en, this message translates to:
  /// **'Apple'**
  String get apple;

  /// No description provided for @stepIdea.
  ///
  /// In en, this message translates to:
  /// **'Idea'**
  String get stepIdea;

  /// No description provided for @stepStyle.
  ///
  /// In en, this message translates to:
  /// **'Style'**
  String get stepStyle;

  /// No description provided for @stepFinalize.
  ///
  /// In en, this message translates to:
  /// **'Finalize'**
  String get stepFinalize;

  /// No description provided for @ideaStepPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Describe your video idea... e.g., \'A futuristic city with flying cars\''**
  String get ideaStepPlaceholder;

  /// No description provided for @addImage.
  ///
  /// In en, this message translates to:
  /// **'Add Image'**
  String get addImage;

  /// No description provided for @imageAdded.
  ///
  /// In en, this message translates to:
  /// **'Image Added'**
  String get imageAdded;

  /// No description provided for @buttonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get buttonBack;

  /// No description provided for @buttonNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get buttonNext;

  /// No description provided for @promptRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a prompt to continue'**
  String get promptRequired;

  /// No description provided for @alreadyGenerating.
  ///
  /// In en, this message translates to:
  /// **'Already generating! Please wait for current generation to complete.'**
  String get alreadyGenerating;

  /// No description provided for @errorMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorMessage(String error);

  /// No description provided for @myCreations.
  ///
  /// In en, this message translates to:
  /// **'My Creations'**
  String get myCreations;

  /// No description provided for @noCreationsYet.
  ///
  /// In en, this message translates to:
  /// **'No creations yet'**
  String get noCreationsYet;

  /// No description provided for @startCreating.
  ///
  /// In en, this message translates to:
  /// **'Start creating your first video!'**
  String get startCreating;

  /// No description provided for @createNew.
  ///
  /// In en, this message translates to:
  /// **'Create New'**
  String get createNew;

  /// No description provided for @videoLength.
  ///
  /// In en, this message translates to:
  /// **'Video Length'**
  String get videoLength;

  /// No description provided for @aspectRatio.
  ///
  /// In en, this message translates to:
  /// **'Aspect Ratio'**
  String get aspectRatio;

  /// No description provided for @voiceGender.
  ///
  /// In en, this message translates to:
  /// **'Voice Gender'**
  String get voiceGender;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @seconds.
  ///
  /// In en, this message translates to:
  /// **'seconds'**
  String get seconds;

  /// No description provided for @generate.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get generate;

  /// No description provided for @creating.
  ///
  /// In en, this message translates to:
  /// **'Creating'**
  String get creating;

  /// No description provided for @generatingVideo.
  ///
  /// In en, this message translates to:
  /// **'Generating your video...'**
  String get generatingVideo;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @continueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithApple;

  /// No description provided for @creatingMagic.
  ///
  /// In en, this message translates to:
  /// **'Creating Magic...'**
  String get creatingMagic;

  /// No description provided for @almostDone.
  ///
  /// In en, this message translates to:
  /// **'Almost Done!'**
  String get almostDone;

  /// No description provided for @processingVideo.
  ///
  /// In en, this message translates to:
  /// **'Processing your video'**
  String get processingVideo;

  /// No description provided for @thisWillTakeAMoment.
  ///
  /// In en, this message translates to:
  /// **'This will take a moment'**
  String get thisWillTakeAMoment;

  /// No description provided for @videoPreview.
  ///
  /// In en, this message translates to:
  /// **'Video Preview'**
  String get videoPreview;

  /// No description provided for @playPause.
  ///
  /// In en, this message translates to:
  /// **'Play/Pause'**
  String get playPause;

  /// No description provided for @restart.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get restart;

  /// No description provided for @downloadVideo.
  ///
  /// In en, this message translates to:
  /// **'Download Video'**
  String get downloadVideo;

  /// No description provided for @shareVideo.
  ///
  /// In en, this message translates to:
  /// **'Share Video'**
  String get shareVideo;

  /// No description provided for @deleteVideo.
  ///
  /// In en, this message translates to:
  /// **'Delete Video'**
  String get deleteVideo;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this video?'**
  String get confirmDelete;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @proceedToPayment.
  ///
  /// In en, this message translates to:
  /// **'Proceed to Payment'**
  String get proceedToPayment;

  /// No description provided for @paymentSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Payment Successful'**
  String get paymentSuccessful;

  /// No description provided for @paymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment Failed'**
  String get paymentFailed;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @selectMedia.
  ///
  /// In en, this message translates to:
  /// **'Select Media'**
  String get selectMedia;

  /// No description provided for @photos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photos;

  /// No description provided for @videos.
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get videos;

  /// No description provided for @recentMedia.
  ///
  /// In en, this message translates to:
  /// **'Recent Media'**
  String get recentMedia;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get info;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @step1Script.
  ///
  /// In en, this message translates to:
  /// **'Script'**
  String get step1Script;

  /// No description provided for @step2Voice.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get step2Voice;

  /// No description provided for @step3Video.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get step3Video;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @images.
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get images;

  /// No description provided for @noCreationsYetMessage.
  ///
  /// In en, this message translates to:
  /// **'Start creating your first video!'**
  String get noCreationsYetMessage;

  /// No description provided for @selectVideo.
  ///
  /// In en, this message translates to:
  /// **'Select Video'**
  String get selectVideo;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter Password'**
  String get enterPassword;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// No description provided for @otpVerification.
  ///
  /// In en, this message translates to:
  /// **'OTP Verification'**
  String get otpVerification;

  /// No description provided for @enterOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP'**
  String get enterOtp;

  /// No description provided for @resend.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get resend;

  /// No description provided for @twoFactor.
  ///
  /// In en, this message translates to:
  /// **'Two-Factor Authentication'**
  String get twoFactor;

  /// No description provided for @musicTrack.
  ///
  /// In en, this message translates to:
  /// **'Music Track'**
  String get musicTrack;

  /// No description provided for @voiceNarration.
  ///
  /// In en, this message translates to:
  /// **'Voice Narration'**
  String get voiceNarration;

  /// No description provided for @noMusicSelected.
  ///
  /// In en, this message translates to:
  /// **'No Music Selected'**
  String get noMusicSelected;

  /// No description provided for @noVoiceSelected.
  ///
  /// In en, this message translates to:
  /// **'No Voice Selected'**
  String get noVoiceSelected;

  /// No description provided for @selectMusicTrack.
  ///
  /// In en, this message translates to:
  /// **'Select Music Track'**
  String get selectMusicTrack;

  /// No description provided for @addVoiceNarration.
  ///
  /// In en, this message translates to:
  /// **'Add Voice Narration'**
  String get addVoiceNarration;

  /// No description provided for @confirmation.
  ///
  /// In en, this message translates to:
  /// **'Confirmation'**
  String get confirmation;

  /// No description provided for @reviewCreation.
  ///
  /// In en, this message translates to:
  /// **'Review Your Creation'**
  String get reviewCreation;

  /// No description provided for @titleRequired.
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get titleRequired;

  /// No description provided for @descriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get descriptionOptional;

  /// No description provided for @creationTitle.
  ///
  /// In en, this message translates to:
  /// **'Creation Title'**
  String get creationTitle;

  /// No description provided for @creationDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get creationDescription;

  /// No description provided for @tapToUnlock.
  ///
  /// In en, this message translates to:
  /// **'Tap to Unlock'**
  String get tapToUnlock;

  /// No description provided for @appLocked.
  ///
  /// In en, this message translates to:
  /// **'App Locked'**
  String get appLocked;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown Error'**
  String get unknownError;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get processing;

  /// No description provided for @waitForOtp.
  ///
  /// In en, this message translates to:
  /// **'Waiting for OTP code'**
  String get waitForOtp;

  /// No description provided for @empty.
  ///
  /// In en, this message translates to:
  /// **'Empty'**
  String get empty;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @created.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get created;

  /// No description provided for @dateFormat.
  ///
  /// In en, this message translates to:
  /// **'MMM dd, yyyy'**
  String get dateFormat;

  /// No description provided for @deleteConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get deleteConfirmation;

  /// No description provided for @deleteCreationMsg.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone'**
  String get deleteCreationMsg;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copied;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @whatToCreate.
  ///
  /// In en, this message translates to:
  /// **'What would you like to create?'**
  String get whatToCreate;

  /// No description provided for @describeYourIdea.
  ///
  /// In en, this message translates to:
  /// **'Describe your video idea and let AI do the magic.'**
  String get describeYourIdea;

  /// No description provided for @enhance.
  ///
  /// In en, this message translates to:
  /// **'Enhance'**
  String get enhance;

  /// No description provided for @promptEnhanced.
  ///
  /// In en, this message translates to:
  /// **'Prompt enhanced! ✨'**
  String get promptEnhanced;

  /// No description provided for @charsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} chars'**
  String charsCount(int count);

  /// No description provided for @guestLoginDisabled.
  ///
  /// In en, this message translates to:
  /// **'Guest login is disabled. Please enable Anonymous Auth in Firebase Console.'**
  String get guestLoginDisabled;

  /// No description provided for @phoneInputHint.
  ///
  /// In en, this message translates to:
  /// **'000 000 0000'**
  String get phoneInputHint;

  /// No description provided for @otpInputHint.
  ///
  /// In en, this message translates to:
  /// **'••••••'**
  String get otpInputHint;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @enterYourName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enterYourName;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @phoneInputPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'+1 (555) 123-4567'**
  String get phoneInputPlaceholder;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Aqvioo'**
  String get appName;

  /// No description provided for @appSubtitle.
  ///
  /// In en, this message translates to:
  /// **'AI-Powered Content Creation'**
  String get appSubtitle;

  /// No description provided for @yourIdea.
  ///
  /// In en, this message translates to:
  /// **'📝 Your Idea'**
  String get yourIdea;

  /// No description provided for @settingsSection.
  ///
  /// In en, this message translates to:
  /// **'⚙️ Settings'**
  String get settingsSection;

  /// No description provided for @outputType.
  ///
  /// In en, this message translates to:
  /// **'Output Type'**
  String get outputType;

  /// No description provided for @video.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get video;

  /// No description provided for @image.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get image;

  /// No description provided for @style.
  ///
  /// In en, this message translates to:
  /// **'Style'**
  String get style;

  /// No description provided for @aspectRatio16x9.
  ///
  /// In en, this message translates to:
  /// **'16:9 (Horizontal)'**
  String get aspectRatio16x9;

  /// No description provided for @aspectRatio9x16.
  ///
  /// In en, this message translates to:
  /// **'9:16 (Vertical)'**
  String get aspectRatio9x16;

  /// No description provided for @voice.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get voice;

  /// No description provided for @size.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get size;

  /// No description provided for @costSection.
  ///
  /// In en, this message translates to:
  /// **'💰 Cost'**
  String get costSection;

  /// No description provided for @cost.
  ///
  /// In en, this message translates to:
  /// **'2.99'**
  String get cost;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'﷼'**
  String get currency;

  /// No description provided for @loginRequired.
  ///
  /// In en, this message translates to:
  /// **'Login Required'**
  String get loginRequired;

  /// No description provided for @pleaseLoginToGenerate.
  ///
  /// In en, this message translates to:
  /// **'Please login to generate your video.'**
  String get pleaseLoginToGenerate;

  /// No description provided for @generateMagic.
  ///
  /// In en, this message translates to:
  /// **'Generate Magic'**
  String get generateMagic;

  /// No description provided for @dialectSaudi.
  ///
  /// In en, this message translates to:
  /// **'Saudi'**
  String get dialectSaudi;

  /// No description provided for @dialectEgyptian.
  ///
  /// In en, this message translates to:
  /// **'Egyptian'**
  String get dialectEgyptian;

  /// No description provided for @dialectUAE.
  ///
  /// In en, this message translates to:
  /// **'UAE'**
  String get dialectUAE;

  /// No description provided for @dialectLebanese.
  ///
  /// In en, this message translates to:
  /// **'Lebanese'**
  String get dialectLebanese;

  /// No description provided for @dialectJordanian.
  ///
  /// In en, this message translates to:
  /// **'Jordanian'**
  String get dialectJordanian;

  /// No description provided for @dialectMoroccan.
  ///
  /// In en, this message translates to:
  /// **'Moroccan'**
  String get dialectMoroccan;

  /// No description provided for @sizeSquare.
  ///
  /// In en, this message translates to:
  /// **'Square (1024x1024)'**
  String get sizeSquare;

  /// No description provided for @sizeLandscape.
  ///
  /// In en, this message translates to:
  /// **'Landscape (1920x1080)'**
  String get sizeLandscape;

  /// No description provided for @sizePortrait.
  ///
  /// In en, this message translates to:
  /// **'Portrait (1080x1920)'**
  String get sizePortrait;

  /// No description provided for @chooseVisualMood.
  ///
  /// In en, this message translates to:
  /// **'Choose the visual mood of your video'**
  String get chooseVisualMood;

  /// No description provided for @selectVideoLength.
  ///
  /// In en, this message translates to:
  /// **'Select video length'**
  String get selectVideoLength;

  /// No description provided for @chooseVideoOrientation.
  ///
  /// In en, this message translates to:
  /// **'Choose video orientation'**
  String get chooseVideoOrientation;

  /// No description provided for @configureNarratorVoice.
  ///
  /// In en, this message translates to:
  /// **'Configure narrator voice'**
  String get configureNarratorVoice;

  /// No description provided for @durationQuick.
  ///
  /// In en, this message translates to:
  /// **'Quick'**
  String get durationQuick;

  /// No description provided for @durationStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get durationStandard;

  /// No description provided for @bestForYouTube.
  ///
  /// In en, this message translates to:
  /// **'Best for YouTube'**
  String get bestForYouTube;

  /// No description provided for @bestForTikTok.
  ///
  /// In en, this message translates to:
  /// **'Best for TikTok'**
  String get bestForTikTok;

  /// No description provided for @noCreationsYetTitle.
  ///
  /// In en, this message translates to:
  /// **'No creations yet'**
  String get noCreationsYetTitle;

  /// No description provided for @startCreatingVideos.
  ///
  /// In en, this message translates to:
  /// **'Start creating amazing videos!'**
  String get startCreatingVideos;

  /// No description provided for @scriptStep.
  ///
  /// In en, this message translates to:
  /// **'Script'**
  String get scriptStep;

  /// No description provided for @audioStep.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get audioStep;

  /// No description provided for @videoStep.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get videoStep;

  /// No description provided for @backgroundGenerationInfo.
  ///
  /// In en, this message translates to:
  /// **'You can safely exit the app. Your video will continue generating in the background.'**
  String get backgroundGenerationInfo;

  /// No description provided for @mediaGallery.
  ///
  /// In en, this message translates to:
  /// **'Media Gallery'**
  String get mediaGallery;

  /// No description provided for @createNow.
  ///
  /// In en, this message translates to:
  /// **'Create Now'**
  String get createNow;

  /// No description provided for @videoDownloadSuccess.
  ///
  /// In en, this message translates to:
  /// **'Video downloaded to temp folder!\nNote: Gallery save requires additional permissions.'**
  String get videoDownloadSuccess;

  /// No description provided for @downloadError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String downloadError(String error);

  /// No description provided for @shareError.
  ///
  /// In en, this message translates to:
  /// **'Share failed: {error}'**
  String shareError(String error);

  /// No description provided for @completeYourPayment.
  ///
  /// In en, this message translates to:
  /// **'Complete Your Payment'**
  String get completeYourPayment;

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get totalAmount;

  /// No description provided for @payWithTabby.
  ///
  /// In en, this message translates to:
  /// **'Pay with Tabby'**
  String get payWithTabby;

  /// No description provided for @payWithTap.
  ///
  /// In en, this message translates to:
  /// **'Pay with Tap'**
  String get payWithTap;

  /// No description provided for @payWithApplePay.
  ///
  /// In en, this message translates to:
  /// **'Pay with Apple Pay'**
  String get payWithApplePay;

  /// No description provided for @payWithSTCPay.
  ///
  /// In en, this message translates to:
  /// **'Pay with STC Pay'**
  String get payWithSTCPay;

  /// No description provided for @payWithCard.
  ///
  /// In en, this message translates to:
  /// **'Pay with Card'**
  String get payWithCard;

  /// No description provided for @emailOrPhone.
  ///
  /// In en, this message translates to:
  /// **'Email or Phone'**
  String get emailOrPhone;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @joinAndStartCreating.
  ///
  /// In en, this message translates to:
  /// **'Join and start creating amazing videos'**
  String get joinAndStartCreating;

  /// No description provided for @styleHeader.
  ///
  /// In en, this message translates to:
  /// **'Style'**
  String get styleHeader;

  /// No description provided for @durationHeader.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get durationHeader;

  /// No description provided for @aspectRatioHeader.
  ///
  /// In en, this message translates to:
  /// **'Aspect Ratio'**
  String get aspectRatioHeader;

  /// No description provided for @voiceSettingsHeader.
  ///
  /// In en, this message translates to:
  /// **'Voice Settings'**
  String get voiceSettingsHeader;

  /// No description provided for @sizeHeader.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get sizeHeader;

  /// No description provided for @quick.
  ///
  /// In en, this message translates to:
  /// **'Quick'**
  String get quick;

  /// No description provided for @standard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get standard;

  /// No description provided for @horizontal.
  ///
  /// In en, this message translates to:
  /// **'Horizontal'**
  String get horizontal;

  /// No description provided for @vertical.
  ///
  /// In en, this message translates to:
  /// **'Vertical'**
  String get vertical;

  /// No description provided for @square.
  ///
  /// In en, this message translates to:
  /// **'Square'**
  String get square;

  /// No description provided for @landscape.
  ///
  /// In en, this message translates to:
  /// **'Landscape'**
  String get landscape;

  /// No description provided for @portrait.
  ///
  /// In en, this message translates to:
  /// **'Portrait'**
  String get portrait;

  /// No description provided for @recentProjects.
  ///
  /// In en, this message translates to:
  /// **'Recent Projects'**
  String get recentProjects;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @createMagic.
  ///
  /// In en, this message translates to:
  /// **'Create Magic'**
  String get createMagic;

  /// No description provided for @productAd.
  ///
  /// In en, this message translates to:
  /// **'Product Ad'**
  String get productAd;

  /// No description provided for @socialReel.
  ///
  /// In en, this message translates to:
  /// **'Social Reel'**
  String get socialReel;

  /// No description provided for @render3D.
  ///
  /// In en, this message translates to:
  /// **'3D Render'**
  String get render3D;

  /// No description provided for @avatar.
  ///
  /// In en, this message translates to:
  /// **'Avatar'**
  String get avatar;

  /// No description provided for @advancedSettings.
  ///
  /// In en, this message translates to:
  /// **'Advanced Settings'**
  String get advancedSettings;

  /// No description provided for @credits.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get credits;

  /// No description provided for @viewLibrary.
  ///
  /// In en, this message translates to:
  /// **'View Library'**
  String get viewLibrary;

  /// No description provided for @modelVersion.
  ///
  /// In en, this message translates to:
  /// **'Model v4.0'**
  String get modelVersion;

  /// No description provided for @generating.
  ///
  /// In en, this message translates to:
  /// **'Generating...'**
  String get generating;

  /// No description provided for @quickSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Quick Suggestions'**
  String get quickSuggestions;

  /// No description provided for @buyCredits.
  ///
  /// In en, this message translates to:
  /// **'Add Balance'**
  String get buyCredits;

  /// No description provided for @currentBalance.
  ///
  /// In en, this message translates to:
  /// **'Current Balance'**
  String get currentBalance;

  /// No description provided for @creditBalance.
  ///
  /// In en, this message translates to:
  /// **'Credit Balance'**
  String creditBalance(int count);

  /// No description provided for @purchaseCredits.
  ///
  /// In en, this message translates to:
  /// **'Add {count} ﷼ - {price} SAR'**
  String purchaseCredits(int count, String price);

  /// No description provided for @videosOrImages.
  ///
  /// In en, this message translates to:
  /// **'{videos} videos or {images} images'**
  String videosOrImages(String videos, String images);

  /// No description provided for @popularBadge.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get popularBadge;

  /// No description provided for @bestValueBadge.
  ///
  /// In en, this message translates to:
  /// **'Best Value'**
  String get bestValueBadge;

  /// No description provided for @tabbyInstallments.
  ///
  /// In en, this message translates to:
  /// **'Split your purchase into 4 interest-free payments'**
  String get tabbyInstallments;

  /// No description provided for @paymentsOf.
  ///
  /// In en, this message translates to:
  /// **'4 payments of'**
  String get paymentsOf;

  /// No description provided for @tabbyBenefits.
  ///
  /// In en, this message translates to:
  /// **'• Pay the first installment now\n• Remaining 3 payments every 2 weeks\n• No interest, no fees'**
  String get tabbyBenefits;

  /// No description provided for @continueToTabby.
  ///
  /// In en, this message translates to:
  /// **'Continue to Tabby'**
  String get continueToTabby;

  /// No description provided for @tapPaymentInfo.
  ///
  /// In en, this message translates to:
  /// **'Secure payment with credit/debit card via Tap Payments'**
  String get tapPaymentInfo;

  /// No description provided for @tapPaymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Supported: Visa, Mastercard, MADA, American Express'**
  String get tapPaymentMethods;

  /// No description provided for @balanceToAdd.
  ///
  /// In en, this message translates to:
  /// **'Balance to add'**
  String get balanceToAdd;

  /// No description provided for @continueToPayment.
  ///
  /// In en, this message translates to:
  /// **'Continue to Payment'**
  String get continueToPayment;

  /// No description provided for @addedToBalance.
  ///
  /// In en, this message translates to:
  /// **'added to your balance'**
  String get addedToBalance;

  /// No description provided for @securePaymentTap.
  ///
  /// In en, this message translates to:
  /// **'Secure payment powered by Tap'**
  String get securePaymentTap;

  /// No description provided for @firstPayment.
  ///
  /// In en, this message translates to:
  /// **'First payment: {amount} SAR'**
  String firstPayment(String amount);

  /// No description provided for @paymentSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment Successful!'**
  String get paymentSuccessTitle;

  /// No description provided for @creditsAdded.
  ///
  /// In en, this message translates to:
  /// **'{count} credits have been added to your account'**
  String creditsAdded(int count);

  /// No description provided for @startCreatingButton.
  ///
  /// In en, this message translates to:
  /// **'Start Creating'**
  String get startCreatingButton;

  /// No description provided for @paymentFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment Failed'**
  String get paymentFailedTitle;

  /// No description provided for @paymentFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Unable to process payment. Please try again.'**
  String get paymentFailedMessage;

  /// No description provided for @purchaseButton.
  ///
  /// In en, this message translates to:
  /// **'Purchase'**
  String get purchaseButton;

  /// No description provided for @restorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restorePurchases;

  /// No description provided for @purchasesRestored.
  ///
  /// In en, this message translates to:
  /// **'Purchases restored successfully'**
  String get purchasesRestored;

  /// No description provided for @restoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to restore purchases'**
  String get restoreFailed;

  /// No description provided for @securePaymentTabby.
  ///
  /// In en, this message translates to:
  /// **'Secure buy now, pay later with Tabby'**
  String get securePaymentTabby;

  /// No description provided for @insufficientCredits.
  ///
  /// In en, this message translates to:
  /// **'Insufficient Credits'**
  String get insufficientCredits;

  /// No description provided for @needCreditsMessage.
  ///
  /// In en, this message translates to:
  /// **'You need {count} credits to generate a {type}.'**
  String needCreditsMessage(int count, String type);

  /// No description provided for @yourBalance.
  ///
  /// In en, this message translates to:
  /// **'Your balance: {count} credits'**
  String yourBalance(int count);

  /// No description provided for @enhancingIdea.
  ///
  /// In en, this message translates to:
  /// **'Enhancing your idea...'**
  String get enhancingIdea;

  /// No description provided for @enhancingVideoIdea.
  ///
  /// In en, this message translates to:
  /// **'Enhancing your video idea...'**
  String get enhancingVideoIdea;

  /// No description provided for @enhancingImageIdea.
  ///
  /// In en, this message translates to:
  /// **'Enhancing your image idea...'**
  String get enhancingImageIdea;

  /// No description provided for @preparingPrompt.
  ///
  /// In en, this message translates to:
  /// **'Preparing your prompt...'**
  String get preparingPrompt;

  /// No description provided for @preparingVideoPrompt.
  ///
  /// In en, this message translates to:
  /// **'Preparing your video prompt...'**
  String get preparingVideoPrompt;

  /// No description provided for @preparingImagePrompt.
  ///
  /// In en, this message translates to:
  /// **'Preparing your image prompt...'**
  String get preparingImagePrompt;

  /// No description provided for @bringingImageToLife.
  ///
  /// In en, this message translates to:
  /// **'Bringing your image to life...'**
  String get bringingImageToLife;

  /// No description provided for @creatingVideo.
  ///
  /// In en, this message translates to:
  /// **'Creating your video...'**
  String get creatingVideo;

  /// No description provided for @generatingImage.
  ///
  /// In en, this message translates to:
  /// **'Generating your image...'**
  String get generatingImage;

  /// No description provided for @creatingMasterpiece.
  ///
  /// In en, this message translates to:
  /// **'Creating your masterpiece...'**
  String get creatingMasterpiece;

  /// No description provided for @creatingVideoMasterpiece.
  ///
  /// In en, this message translates to:
  /// **'Creating your video masterpiece...'**
  String get creatingVideoMasterpiece;

  /// No description provided for @creatingImageMasterpiece.
  ///
  /// In en, this message translates to:
  /// **'Creating your image masterpiece...'**
  String get creatingImageMasterpiece;

  /// No description provided for @magicComplete.
  ///
  /// In en, this message translates to:
  /// **'Magic Complete!'**
  String get magicComplete;

  /// No description provided for @videoComplete.
  ///
  /// In en, this message translates to:
  /// **'Video Complete!'**
  String get videoComplete;

  /// No description provided for @imageComplete.
  ///
  /// In en, this message translates to:
  /// **'Image Complete!'**
  String get imageComplete;

  /// No description provided for @generatingVideoTitle.
  ///
  /// In en, this message translates to:
  /// **'Generating Video'**
  String get generatingVideoTitle;

  /// No description provided for @generatingImageTitle.
  ///
  /// In en, this message translates to:
  /// **'Generating Image'**
  String get generatingImageTitle;

  /// No description provided for @library.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get library;

  /// No description provided for @allCreations.
  ///
  /// In en, this message translates to:
  /// **'All Creations'**
  String get allCreations;

  /// No description provided for @playVideo.
  ///
  /// In en, this message translates to:
  /// **'Play Video'**
  String get playVideo;

  /// No description provided for @viewImage.
  ///
  /// In en, this message translates to:
  /// **'View Image'**
  String get viewImage;

  /// No description provided for @createdOn.
  ///
  /// In en, this message translates to:
  /// **'Created on {date}'**
  String createdOn(String date);

  /// No description provided for @checkLaterInMyCreations.
  ///
  /// In en, this message translates to:
  /// **'Check later in My Creations'**
  String get checkLaterInMyCreations;

  /// No description provided for @creator.
  ///
  /// In en, this message translates to:
  /// **'Creator'**
  String get creator;

  /// No description provided for @speechRecognitionNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Speech recognition not available'**
  String get speechRecognitionNotAvailable;

  /// No description provided for @microphonePermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission is required'**
  String get microphonePermissionRequired;

  /// No description provided for @failedToEnhancePrompt.
  ///
  /// In en, this message translates to:
  /// **'Failed to enhance prompt: {error}'**
  String failedToEnhancePrompt(Object error);

  /// No description provided for @moreStyles.
  ///
  /// In en, this message translates to:
  /// **'More Styles'**
  String get moreStyles;

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'Show Less'**
  String get showLess;

  /// No description provided for @enhancing.
  ///
  /// In en, this message translates to:
  /// **'Enhancing...'**
  String get enhancing;

  /// No description provided for @didNotReceiveCode.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the code? '**
  String get didNotReceiveCode;

  /// No description provided for @weSentCodeTo.
  ///
  /// In en, this message translates to:
  /// **'We sent a code to'**
  String get weSentCodeTo;

  /// No description provided for @youWillGenerate.
  ///
  /// In en, this message translates to:
  /// **'You will generate {label}'**
  String youWillGenerate(Object label);

  /// No description provided for @yourGallery.
  ///
  /// In en, this message translates to:
  /// **'YOUR GALLERY'**
  String get yourGallery;

  /// No description provided for @emptyGalleryDescription.
  ///
  /// In en, this message translates to:
  /// **'Start creating amazing AI-generated videos and images with just a few taps'**
  String get emptyGalleryDescription;

  /// No description provided for @createYourFirst.
  ///
  /// In en, this message translates to:
  /// **'Create Your First'**
  String get createYourFirst;

  /// No description provided for @generatingMagic.
  ///
  /// In en, this message translates to:
  /// **'Generating Magic...'**
  String get generatingMagic;

  /// No description provided for @generationTimedOut.
  ///
  /// In en, this message translates to:
  /// **'Generation timed out'**
  String get generationTimedOut;

  /// No description provided for @cinematic.
  ///
  /// In en, this message translates to:
  /// **'Cinematic'**
  String get cinematic;

  /// No description provided for @realEstate.
  ///
  /// In en, this message translates to:
  /// **'Real Estate'**
  String get realEstate;

  /// No description provided for @educational.
  ///
  /// In en, this message translates to:
  /// **'Educational'**
  String get educational;

  /// No description provided for @corporate.
  ///
  /// In en, this message translates to:
  /// **'Corporate'**
  String get corporate;

  /// No description provided for @gaming.
  ///
  /// In en, this message translates to:
  /// **'Gaming'**
  String get gaming;

  /// No description provided for @musicVideo.
  ///
  /// In en, this message translates to:
  /// **'Music Video'**
  String get musicVideo;

  /// No description provided for @documentary.
  ///
  /// In en, this message translates to:
  /// **'Documentary'**
  String get documentary;

  /// No description provided for @adminDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get adminDashboard;

  /// No description provided for @adminUsers.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get adminUsers;

  /// No description provided for @adminContent.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get adminContent;

  /// No description provided for @adminPayments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get adminPayments;

  /// No description provided for @adminSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get adminSettings;

  /// No description provided for @dashboardMetrics.
  ///
  /// In en, this message translates to:
  /// **'Dashboard Metrics'**
  String get dashboardMetrics;

  /// No description provided for @totalUsers.
  ///
  /// In en, this message translates to:
  /// **'Total Users'**
  String get totalUsers;

  /// No description provided for @totalVideos.
  ///
  /// In en, this message translates to:
  /// **'Total Videos'**
  String get totalVideos;

  /// No description provided for @totalRevenue.
  ///
  /// In en, this message translates to:
  /// **'Total Revenue'**
  String get totalRevenue;

  /// No description provided for @videosGenerated.
  ///
  /// In en, this message translates to:
  /// **'Videos Generated'**
  String get videosGenerated;

  /// No description provided for @activeGenerations.
  ///
  /// In en, this message translates to:
  /// **'Active Generations'**
  String get activeGenerations;

  /// No description provided for @successRate.
  ///
  /// In en, this message translates to:
  /// **'Success Rate'**
  String get successRate;

  /// No description provided for @recentUsers.
  ///
  /// In en, this message translates to:
  /// **'Recent Users'**
  String get recentUsers;

  /// No description provided for @recentVideos.
  ///
  /// In en, this message translates to:
  /// **'Recent Videos'**
  String get recentVideos;

  /// No description provided for @recentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get recentTransactions;

  /// No description provided for @userList.
  ///
  /// In en, this message translates to:
  /// **'User List'**
  String get userList;

  /// No description provided for @searchByEmail.
  ///
  /// In en, this message translates to:
  /// **'Search by email or username'**
  String get searchByEmail;

  /// No description provided for @phoneNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneNumberLabel;

  /// No description provided for @creditsLabel.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get creditsLabel;

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusLabel;

  /// No description provided for @actionLabel.
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get actionLabel;

  /// No description provided for @banUser.
  ///
  /// In en, this message translates to:
  /// **'Ban User'**
  String get banUser;

  /// No description provided for @unbanUser.
  ///
  /// In en, this message translates to:
  /// **'Unban User'**
  String get unbanUser;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @contentManagement.
  ///
  /// In en, this message translates to:
  /// **'Content Management'**
  String get contentManagement;

  /// No description provided for @searchByPrompt.
  ///
  /// In en, this message translates to:
  /// **'Search by prompt or user'**
  String get searchByPrompt;

  /// No description provided for @typeFilter.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get typeFilter;

  /// No description provided for @statusFilter.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusFilter;

  /// No description provided for @allTypes.
  ///
  /// In en, this message translates to:
  /// **'All Types'**
  String get allTypes;

  /// No description provided for @allStatus.
  ///
  /// In en, this message translates to:
  /// **'All Status'**
  String get allStatus;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @contentPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get contentPreview;

  /// No description provided for @copyUrl.
  ///
  /// In en, this message translates to:
  /// **'Copy URL'**
  String get copyUrl;

  /// No description provided for @userInformation.
  ///
  /// In en, this message translates to:
  /// **'User Information'**
  String get userInformation;

  /// No description provided for @joined.
  ///
  /// In en, this message translates to:
  /// **'Joined'**
  String get joined;

  /// No description provided for @adjustCredits.
  ///
  /// In en, this message translates to:
  /// **'Adjust Credits'**
  String get adjustCredits;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @reason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reason;

  /// No description provided for @bonus.
  ///
  /// In en, this message translates to:
  /// **'Bonus'**
  String get bonus;

  /// No description provided for @refund.
  ///
  /// In en, this message translates to:
  /// **'Refund'**
  String get refund;

  /// No description provided for @correction.
  ///
  /// In en, this message translates to:
  /// **'Correction'**
  String get correction;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get notes;

  /// No description provided for @accountStatus.
  ///
  /// In en, this message translates to:
  /// **'Account Status'**
  String get accountStatus;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @banned.
  ///
  /// In en, this message translates to:
  /// **'Banned'**
  String get banned;

  /// No description provided for @bannedOn.
  ///
  /// In en, this message translates to:
  /// **'Banned on'**
  String get bannedOn;

  /// No description provided for @banReason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get banReason;

  /// No description provided for @recentCreations.
  ///
  /// In en, this message translates to:
  /// **'Recent Creations'**
  String get recentCreations;

  /// No description provided for @noCreations.
  ///
  /// In en, this message translates to:
  /// **'No creations yet'**
  String get noCreations;

  /// No description provided for @paymentsList.
  ///
  /// In en, this message translates to:
  /// **'Payments List'**
  String get paymentsList;

  /// No description provided for @paymentId.
  ///
  /// In en, this message translates to:
  /// **'Payment ID'**
  String get paymentId;

  /// No description provided for @paymentStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get paymentStatus;

  /// No description provided for @paymentDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get paymentDate;

  /// No description provided for @transactionId.
  ///
  /// In en, this message translates to:
  /// **'Transaction ID'**
  String get transactionId;

  /// No description provided for @adminLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get adminLogout;

  /// No description provided for @adminProfile.
  ///
  /// In en, this message translates to:
  /// **'Admin Profile'**
  String get adminProfile;

  /// No description provided for @adminEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get adminEmail;

  /// No description provided for @adminRole.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get adminRole;

  /// No description provided for @adminPermissions.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get adminPermissions;

  /// No description provided for @switchToApp.
  ///
  /// In en, this message translates to:
  /// **'Switch to App'**
  String get switchToApp;

  /// No description provided for @administrator.
  ///
  /// In en, this message translates to:
  /// **'Administrator'**
  String get administrator;

  /// No description provided for @areYouSure.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get areYouSure;

  /// No description provided for @deleteContentMsg.
  ///
  /// In en, this message translates to:
  /// **'This content will be permanently deleted'**
  String get deleteContentMsg;

  /// No description provided for @confirmBan.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to ban this user?'**
  String get confirmBan;

  /// No description provided for @unbanConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to unban this user?'**
  String get unbanConfirm;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get userNotFound;

  /// No description provided for @contentNotFound.
  ///
  /// In en, this message translates to:
  /// **'Content not found'**
  String get contentNotFound;

  /// No description provided for @creditsAdjusted.
  ///
  /// In en, this message translates to:
  /// **'Credits adjusted successfully'**
  String get creditsAdjusted;

  /// No description provided for @userBanned.
  ///
  /// In en, this message translates to:
  /// **'User has been banned'**
  String get userBanned;

  /// No description provided for @userUnbanned.
  ///
  /// In en, this message translates to:
  /// **'User has been unbanned'**
  String get userUnbanned;

  /// No description provided for @contentDeleted.
  ///
  /// In en, this message translates to:
  /// **'Content deleted successfully'**
  String get contentDeleted;

  /// No description provided for @errorAdjustingCredits.
  ///
  /// In en, this message translates to:
  /// **'Error adjusting credits'**
  String get errorAdjustingCredits;

  /// No description provided for @errorBanningUser.
  ///
  /// In en, this message translates to:
  /// **'Error banning user'**
  String get errorBanningUser;

  /// No description provided for @errorLoadingUsers.
  ///
  /// In en, this message translates to:
  /// **'Error loading users'**
  String get errorLoadingUsers;

  /// No description provided for @errorLoadingContent.
  ///
  /// In en, this message translates to:
  /// **'Error loading content'**
  String get errorLoadingContent;

  /// No description provided for @profileUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdatedSuccess;

  /// No description provided for @profileUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile'**
  String get profileUpdateFailed;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @accountSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT SETTINGS'**
  String get accountSettingsTitle;

  /// No description provided for @enhanceCinematic.
  ///
  /// In en, this message translates to:
  /// **'with cinematic lighting and professional color grading'**
  String get enhanceCinematic;

  /// No description provided for @enhance4K.
  ///
  /// In en, this message translates to:
  /// **'in stunning 4K quality with dramatic atmosphere'**
  String get enhance4K;

  /// No description provided for @enhanceMusic.
  ///
  /// In en, this message translates to:
  /// **'with epic music and smooth transitions'**
  String get enhanceMusic;

  /// No description provided for @enhanceDynamic.
  ///
  /// In en, this message translates to:
  /// **'featuring dynamic camera movements and vivid colors'**
  String get enhanceDynamic;

  /// No description provided for @enhanceHollywood.
  ///
  /// In en, this message translates to:
  /// **'with Hollywood-style production value'**
  String get enhanceHollywood;

  /// No description provided for @enhancePremium.
  ///
  /// In en, this message translates to:
  /// **'in premium quality with artistic composition'**
  String get enhancePremium;

  /// No description provided for @enterName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enterName;

  /// No description provided for @enterPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get enterPhone;

  /// No description provided for @logoutConfirmationTitle.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutConfirmationTitle;

  /// No description provided for @logoutConfirmationMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirmationMessage;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountMessage.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. All your data will be permanently deleted.'**
  String get deleteAccountMessage;

  /// No description provided for @paymentMobileOnly.
  ///
  /// In en, this message translates to:
  /// **'Payments are only available on the mobile app'**
  String get paymentMobileOnly;

  /// No description provided for @imagePreview.
  ///
  /// In en, this message translates to:
  /// **'Image Preview'**
  String get imagePreview;

  /// No description provided for @videoPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Video Preview'**
  String get videoPreviewTitle;

  /// No description provided for @saveToPhotos.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveToPhotos;

  /// No description provided for @remix.
  ///
  /// In en, this message translates to:
  /// **'Remix'**
  String get remix;

  /// No description provided for @loop.
  ///
  /// In en, this message translates to:
  /// **'Loop'**
  String get loop;

  /// No description provided for @noLoop.
  ///
  /// In en, this message translates to:
  /// **'No Loop'**
  String get noLoop;

  /// No description provided for @prompt.
  ///
  /// In en, this message translates to:
  /// **'Prompt'**
  String get prompt;

  /// No description provided for @noPromptAvailable.
  ///
  /// In en, this message translates to:
  /// **'No prompt available'**
  String get noPromptAvailable;

  /// No description provided for @promptDetails.
  ///
  /// In en, this message translates to:
  /// **'Prompt Details'**
  String get promptDetails;

  /// No description provided for @tryAgainWithPrompt.
  ///
  /// In en, this message translates to:
  /// **'Try Again with this Prompt'**
  String get tryAgainWithPrompt;

  /// No description provided for @generateNewVideo.
  ///
  /// In en, this message translates to:
  /// **'Generate New Video?'**
  String get generateNewVideo;

  /// No description provided for @generateNewContent.
  ///
  /// In en, this message translates to:
  /// **'Generate New Content?'**
  String get generateNewContent;

  /// No description provided for @chooseVariation.
  ///
  /// In en, this message translates to:
  /// **'Choose how you want to create a new variation'**
  String get chooseVariation;

  /// No description provided for @useSamePrompt.
  ///
  /// In en, this message translates to:
  /// **'Use Same Prompt'**
  String get useSamePrompt;

  /// No description provided for @enhancePrompt.
  ///
  /// In en, this message translates to:
  /// **'Enhance Prompt'**
  String get enhancePrompt;

  /// No description provided for @newPrompt.
  ///
  /// In en, this message translates to:
  /// **'New Prompt'**
  String get newPrompt;

  /// No description provided for @savedToPhotos.
  ///
  /// In en, this message translates to:
  /// **'Saved to Photos successfully!'**
  String get savedToPhotos;

  /// No description provided for @failedToSave.
  ///
  /// In en, this message translates to:
  /// **'Failed to save to Photos. Access denied?'**
  String get failedToSave;

  /// No description provided for @shareFailed.
  ///
  /// In en, this message translates to:
  /// **'Share failed: {error}'**
  String shareFailed(Object error);

  /// No description provided for @listView.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get listView;

  /// No description provided for @gridView.
  ///
  /// In en, this message translates to:
  /// **'Grid'**
  String get gridView;

  /// No description provided for @styleCinematic.
  ///
  /// In en, this message translates to:
  /// **'Cinematic'**
  String get styleCinematic;

  /// No description provided for @styleAnimation.
  ///
  /// In en, this message translates to:
  /// **'Animation'**
  String get styleAnimation;

  /// No description provided for @styleMinimal.
  ///
  /// In en, this message translates to:
  /// **'Minimal'**
  String get styleMinimal;

  /// No description provided for @styleModern.
  ///
  /// In en, this message translates to:
  /// **'Modern'**
  String get styleModern;

  /// No description provided for @styleCorporate.
  ///
  /// In en, this message translates to:
  /// **'Corporate'**
  String get styleCorporate;

  /// No description provided for @styleSocialMedia.
  ///
  /// In en, this message translates to:
  /// **'Social Media'**
  String get styleSocialMedia;

  /// No description provided for @styleVintage.
  ///
  /// In en, this message translates to:
  /// **'Vintage'**
  String get styleVintage;

  /// No description provided for @styleFantasy.
  ///
  /// In en, this message translates to:
  /// **'Fantasy'**
  String get styleFantasy;

  /// No description provided for @styleDocumentary.
  ///
  /// In en, this message translates to:
  /// **'Documentary'**
  String get styleDocumentary;

  /// No description provided for @styleHorror.
  ///
  /// In en, this message translates to:
  /// **'Horror'**
  String get styleHorror;

  /// No description provided for @styleComedy.
  ///
  /// In en, this message translates to:
  /// **'Comedy'**
  String get styleComedy;

  /// No description provided for @styleSciFi.
  ///
  /// In en, this message translates to:
  /// **'Sci-Fi'**
  String get styleSciFi;

  /// No description provided for @styleNoir.
  ///
  /// In en, this message translates to:
  /// **'Noir'**
  String get styleNoir;

  /// No description provided for @styleDreamlike.
  ///
  /// In en, this message translates to:
  /// **'Dreamlike'**
  String get styleDreamlike;

  /// No description provided for @styleRetro.
  ///
  /// In en, this message translates to:
  /// **'Retro'**
  String get styleRetro;

  /// No description provided for @styleTealFrame.
  ///
  /// In en, this message translates to:
  /// **'Teal Frame'**
  String get styleTealFrame;

  /// No description provided for @styleNavyExecutive.
  ///
  /// In en, this message translates to:
  /// **'Navy Executive'**
  String get styleNavyExecutive;

  /// No description provided for @styleForestGreen.
  ///
  /// In en, this message translates to:
  /// **'Forest Green'**
  String get styleForestGreen;

  /// No description provided for @styleRoyalPurple.
  ///
  /// In en, this message translates to:
  /// **'Royal Purple'**
  String get styleRoyalPurple;

  /// No description provided for @styleSunsetOrange.
  ///
  /// In en, this message translates to:
  /// **'Sunset Orange'**
  String get styleSunsetOrange;

  /// No description provided for @stylePromptCinematic.
  ///
  /// In en, this message translates to:
  /// **'cinematic style with dramatic lighting and composition'**
  String get stylePromptCinematic;

  /// No description provided for @stylePromptAnimation.
  ///
  /// In en, this message translates to:
  /// **'animated style with vibrant colors and smooth motion'**
  String get stylePromptAnimation;

  /// No description provided for @stylePromptMinimal.
  ///
  /// In en, this message translates to:
  /// **'minimal and clean aesthetic with simple compositions'**
  String get stylePromptMinimal;

  /// No description provided for @stylePromptModern.
  ///
  /// In en, this message translates to:
  /// **'modern and contemporary style'**
  String get stylePromptModern;

  /// No description provided for @stylePromptCorporate.
  ///
  /// In en, this message translates to:
  /// **'professional corporate style'**
  String get stylePromptCorporate;

  /// No description provided for @stylePromptSocialMedia.
  ///
  /// In en, this message translates to:
  /// **'engaging social media style with dynamic energy'**
  String get stylePromptSocialMedia;

  /// No description provided for @stylePromptVintage.
  ///
  /// In en, this message translates to:
  /// **'vintage style with retro aesthetics and aged film look'**
  String get stylePromptVintage;

  /// No description provided for @stylePromptFantasy.
  ///
  /// In en, this message translates to:
  /// **'fantasy style with magical and otherworldly elements'**
  String get stylePromptFantasy;

  /// No description provided for @stylePromptDocumentary.
  ///
  /// In en, this message translates to:
  /// **'documentary style with realistic and observational approach'**
  String get stylePromptDocumentary;

  /// No description provided for @stylePromptHorror.
  ///
  /// In en, this message translates to:
  /// **'horror style with dark atmosphere and suspenseful mood'**
  String get stylePromptHorror;

  /// No description provided for @stylePromptComedy.
  ///
  /// In en, this message translates to:
  /// **'comedy style with lighthearted and playful energy'**
  String get stylePromptComedy;

  /// No description provided for @stylePromptSciFi.
  ///
  /// In en, this message translates to:
  /// **'sci-fi style with futuristic technology and advanced aesthetics'**
  String get stylePromptSciFi;

  /// No description provided for @stylePromptNoir.
  ///
  /// In en, this message translates to:
  /// **'film noir style with high contrast and moody shadows'**
  String get stylePromptNoir;

  /// No description provided for @stylePromptDreamlike.
  ///
  /// In en, this message translates to:
  /// **'dreamlike style with surreal and ethereal atmosphere'**
  String get stylePromptDreamlike;

  /// No description provided for @stylePromptRetro.
  ///
  /// In en, this message translates to:
  /// **'retro style with 80s and 90s aesthetic'**
  String get stylePromptRetro;

  /// No description provided for @stylePromptTealFrame.
  ///
  /// In en, this message translates to:
  /// **'professional teal frame with clean card layout, rounded corners, and soft shadows on light background'**
  String get stylePromptTealFrame;

  /// No description provided for @stylePromptNavyExecutive.
  ///
  /// In en, this message translates to:
  /// **'executive navy blue style with gold accents, formal composition, and corporate elegance'**
  String get stylePromptNavyExecutive;

  /// No description provided for @stylePromptForestGreen.
  ///
  /// In en, this message translates to:
  /// **'nature-inspired forest green palette with organic shapes, earthy tones, and calming atmosphere'**
  String get stylePromptForestGreen;

  /// No description provided for @stylePromptRoyalPurple.
  ///
  /// In en, this message translates to:
  /// **'royal purple elegant style with luxurious gradients, sophisticated typography, and premium feel'**
  String get stylePromptRoyalPurple;

  /// No description provided for @stylePromptSunsetOrange.
  ///
  /// In en, this message translates to:
  /// **'warm sunset orange gradient with vibrant energy, golden hour lighting, and inspiring mood'**
  String get stylePromptSunsetOrange;

  /// No description provided for @supportTitle.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get supportTitle;

  /// No description provided for @supportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'re here to help! Contact us for any questions or issues.'**
  String get supportSubtitle;

  /// No description provided for @emailUs.
  ///
  /// In en, this message translates to:
  /// **'Email Us'**
  String get emailUs;

  /// No description provided for @responseTime.
  ///
  /// In en, this message translates to:
  /// **'Response Time'**
  String get responseTime;

  /// No description provided for @responseTimeValue.
  ///
  /// In en, this message translates to:
  /// **'Within 24-48 hours'**
  String get responseTimeValue;

  /// No description provided for @faqTitle.
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get faqTitle;

  /// No description provided for @faqQuestion1.
  ///
  /// In en, this message translates to:
  /// **'How do I create a video?'**
  String get faqQuestion1;

  /// No description provided for @faqAnswer1.
  ///
  /// In en, this message translates to:
  /// **'Simply enter your idea in the text field, choose your preferred style and settings, then tap \'Generate\'. Our AI will create your video automatically.'**
  String get faqAnswer1;

  /// No description provided for @faqQuestion2.
  ///
  /// In en, this message translates to:
  /// **'How do credits work?'**
  String get faqQuestion2;

  /// No description provided for @faqAnswer2.
  ///
  /// In en, this message translates to:
  /// **'Credits are used to generate videos and images. Each generation costs a certain amount of credits based on the output type and settings.'**
  String get faqAnswer2;

  /// No description provided for @faqQuestion3.
  ///
  /// In en, this message translates to:
  /// **'Can I get a refund?'**
  String get faqQuestion3;

  /// No description provided for @faqAnswer3.
  ///
  /// In en, this message translates to:
  /// **'Please contact our support team for refund requests. We review each case individually.'**
  String get faqAnswer3;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyTitle;

  /// No description provided for @privacyIntro.
  ///
  /// In en, this message translates to:
  /// **'Introduction'**
  String get privacyIntro;

  /// No description provided for @privacyIntroContent.
  ///
  /// In en, this message translates to:
  /// **'At Aqvioo, we respect the privacy of our users and strive to protect their personal data. This policy aims to explain how we collect, use, and protect information when you use our application.'**
  String get privacyIntroContent;

  /// No description provided for @privacySection1Title.
  ///
  /// In en, this message translates to:
  /// **'1. Information We Collect'**
  String get privacySection1Title;

  /// No description provided for @privacySection1Content.
  ///
  /// In en, this message translates to:
  /// **'We collect only the necessary information to operate application services and improve the experience, including:\n\nInformation provided voluntarily by the user:\n• Texts or ideas written by the user to create video or image\n• Images or files uploaded by the user within the app\n• Contact information (such as email) when contacting us for technical support\n\nTechnical information (automatically):\n• Device type, operating system, and app version\n• General usage data (number of uses, errors, session duration)\n\nWe do not collect any data that directly identifies the user without their permission.'**
  String get privacySection1Content;

  /// No description provided for @privacySection2Title.
  ///
  /// In en, this message translates to:
  /// **'2. Use of Information'**
  String get privacySection2Title;

  /// No description provided for @privacySection2Content.
  ///
  /// In en, this message translates to:
  /// **'We use the collected information to:\n• Create requested content (texts, videos, audio)\n• Improve app performance and user experience\n• Provide technical support and respond to inquiries\n• Send notifications or updates related to the app (when enabled by user)\n\nWe confirm that all data entered for video creation purposes is not used for marketing purposes or external sharing.'**
  String get privacySection2Content;

  /// No description provided for @privacySection3Title.
  ///
  /// In en, this message translates to:
  /// **'3. Data Sharing'**
  String get privacySection3Title;

  /// No description provided for @privacySection3Content.
  ///
  /// In en, this message translates to:
  /// **'We do not share any personal data with third parties.'**
  String get privacySection3Content;

  /// No description provided for @privacySection4Title.
  ///
  /// In en, this message translates to:
  /// **'4. Data Storage and Security'**
  String get privacySection4Title;

  /// No description provided for @privacySection4Content.
  ///
  /// In en, this message translates to:
  /// **'• Data is retained temporarily only during the video or image creation process\n• We do not store any user files or texts after the process is completed\n• We use security and encryption protocols to protect all data during transfer between the user and servers'**
  String get privacySection4Content;

  /// No description provided for @privacySection5Title.
  ///
  /// In en, this message translates to:
  /// **'5. Payment Operations'**
  String get privacySection5Title;

  /// No description provided for @privacySection5Content.
  ///
  /// In en, this message translates to:
  /// **'• All payment operations are processed through secure service providers such as Apple Pay, STC Pay, Visa, MasterCard, and Mada\n• We do not store any credit card information or financial data within the app\n• All transactions are subject to the security policies of payment providers'**
  String get privacySection5Content;

  /// No description provided for @privacySection6Title.
  ///
  /// In en, this message translates to:
  /// **'6. User Rights'**
  String get privacySection6Title;

  /// No description provided for @privacySection6Content.
  ///
  /// In en, this message translates to:
  /// **'The user has the right to:\n• Request deletion of their data or images and texts they sent\n• Stop using the app at any time without any obligation\n• Contact us for clarifications or complaints via email'**
  String get privacySection6Content;

  /// No description provided for @privacySection7Title.
  ///
  /// In en, this message translates to:
  /// **'7. Privacy Policy Changes'**
  String get privacySection7Title;

  /// No description provided for @privacySection7Content.
  ///
  /// In en, this message translates to:
  /// **'We may update this policy from time to time in accordance with technical or legal updates. Users will be notified of any significant changes through the app or email.'**
  String get privacySection7Content;

  /// No description provided for @privacySection8Title.
  ///
  /// In en, this message translates to:
  /// **'8. Contact Us'**
  String get privacySection8Title;

  /// No description provided for @privacySection8Content.
  ///
  /// In en, this message translates to:
  /// **'If you have any questions or comments about the privacy policy, you can contact us at:\nAqvioo@outlook.sa'**
  String get privacySection8Content;

  /// No description provided for @notificationVideoReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Video Ready!'**
  String get notificationVideoReadyTitle;

  /// No description provided for @notificationVideoReadyBody.
  ///
  /// In en, this message translates to:
  /// **'Your video has been generated successfully.'**
  String get notificationVideoReadyBody;

  /// No description provided for @notificationImageReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Image Ready!'**
  String get notificationImageReadyTitle;

  /// No description provided for @notificationImageReadyBody.
  ///
  /// In en, this message translates to:
  /// **'Your image has been generated successfully.'**
  String get notificationImageReadyBody;

  /// No description provided for @notificationGenerationFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Generation Failed'**
  String get notificationGenerationFailedTitle;

  /// No description provided for @notificationTimeoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Generation Timed Out'**
  String get notificationTimeoutTitle;

  /// No description provided for @notificationTimeoutBody.
  ///
  /// In en, this message translates to:
  /// **'Please try again later.'**
  String get notificationTimeoutBody;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
