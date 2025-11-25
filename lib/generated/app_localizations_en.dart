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
  String errorMessage(String message) {
    return 'Error: $message';
  }

  @override
  String get myCreations => 'My Creations';

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
}
