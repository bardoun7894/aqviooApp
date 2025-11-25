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

  /// The application title
  ///
  /// In en, this message translates to:
  /// **'Aqvioo'**
  String get appTitle;

  /// First step label in creation wizard
  ///
  /// In en, this message translates to:
  /// **'Idea'**
  String get stepIdea;

  /// Second step label in creation wizard
  ///
  /// In en, this message translates to:
  /// **'Style'**
  String get stepStyle;

  /// Third step label in creation wizard
  ///
  /// In en, this message translates to:
  /// **'Finalize'**
  String get stepFinalize;

  /// Placeholder text for idea input field
  ///
  /// In en, this message translates to:
  /// **'Describe your video idea... e.g., \'A futuristic city with flying cars\''**
  String get ideaStepPlaceholder;

  /// Button text to add an image
  ///
  /// In en, this message translates to:
  /// **'Add Image'**
  String get addImage;

  /// Button text when image is added
  ///
  /// In en, this message translates to:
  /// **'Image Added'**
  String get imageAdded;

  /// Back button text
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get buttonBack;

  /// Next button text
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get buttonNext;

  /// Error message when prompt is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter a prompt to continue'**
  String get promptRequired;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String errorMessage(String message);

  /// My Creations screen title
  ///
  /// In en, this message translates to:
  /// **'My Creations'**
  String get myCreations;

  /// Video length label
  ///
  /// In en, this message translates to:
  /// **'Video Length'**
  String get videoLength;

  /// Aspect ratio label
  ///
  /// In en, this message translates to:
  /// **'Aspect Ratio'**
  String get aspectRatio;

  /// Voice gender label
  ///
  /// In en, this message translates to:
  /// **'Voice Gender'**
  String get voiceGender;

  /// Male voice option
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// Female voice option
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// Duration label
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// Seconds unit
  ///
  /// In en, this message translates to:
  /// **'seconds'**
  String get seconds;

  /// Generate button text
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get generate;

  /// Creating status text
  ///
  /// In en, this message translates to:
  /// **'Creating'**
  String get creating;

  /// Generating video message
  ///
  /// In en, this message translates to:
  /// **'Generating your video...'**
  String get generatingVideo;

  /// Preview button text
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// Share button text
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// Download button text
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;
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
