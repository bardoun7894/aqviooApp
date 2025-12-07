import 'package:flutter/material.dart';
import '../../../generated/app_localizations.dart';
import '../../../features/creation/domain/models/creation_config.dart';

/// Utility class for getting localized style names and prompt modifiers
class StyleUtils {
  /// Get localized display name for a video style
  static String getLocalizedStyleName(BuildContext context, VideoStyle style) {
    final l10n = AppLocalizations.of(context)!;
    switch (style) {
      case VideoStyle.cinematic:
        return l10n.styleCinematic;
      case VideoStyle.animation:
        return l10n.styleAnimation;
      case VideoStyle.minimal:
        return l10n.styleMinimal;
      case VideoStyle.modern:
        return l10n.styleModern;
      case VideoStyle.corporate:
        return l10n.styleCorporate;
      case VideoStyle.socialMedia:
        return l10n.styleSocialMedia;
      case VideoStyle.vintage:
        return l10n.styleVintage;
      case VideoStyle.fantasy:
        return l10n.styleFantasy;
      case VideoStyle.documentary:
        return l10n.styleDocumentary;
      case VideoStyle.horror:
        return l10n.styleHorror;
      case VideoStyle.comedy:
        return l10n.styleComedy;
      case VideoStyle.sciFi:
        return l10n.styleSciFi;
      case VideoStyle.noir:
        return l10n.styleNoir;
      case VideoStyle.dreamlike:
        return l10n.styleDreamlike;
      case VideoStyle.retro:
        return l10n.styleRetro;
      case VideoStyle.tealFrame:
        return l10n.styleTealFrame;
      case VideoStyle.navyExecutive:
        return l10n.styleNavyExecutive;
      case VideoStyle.forestGreen:
        return l10n.styleForestGreen;
      case VideoStyle.royalPurple:
        return l10n.styleRoyalPurple;
      case VideoStyle.sunsetOrange:
        return l10n.styleSunsetOrange;
    }
  }

  /// Get localized prompt modifier for a video style
  /// This is used to enhance the user's prompt with style-specific language
  static String getLocalizedStylePrompt(BuildContext context, VideoStyle style) {
    final l10n = AppLocalizations.of(context)!;
    switch (style) {
      case VideoStyle.cinematic:
        return l10n.stylePromptCinematic;
      case VideoStyle.animation:
        return l10n.stylePromptAnimation;
      case VideoStyle.minimal:
        return l10n.stylePromptMinimal;
      case VideoStyle.modern:
        return l10n.stylePromptModern;
      case VideoStyle.corporate:
        return l10n.stylePromptCorporate;
      case VideoStyle.socialMedia:
        return l10n.stylePromptSocialMedia;
      case VideoStyle.vintage:
        return l10n.stylePromptVintage;
      case VideoStyle.fantasy:
        return l10n.stylePromptFantasy;
      case VideoStyle.documentary:
        return l10n.stylePromptDocumentary;
      case VideoStyle.horror:
        return l10n.stylePromptHorror;
      case VideoStyle.comedy:
        return l10n.stylePromptComedy;
      case VideoStyle.sciFi:
        return l10n.stylePromptSciFi;
      case VideoStyle.noir:
        return l10n.stylePromptNoir;
      case VideoStyle.dreamlike:
        return l10n.stylePromptDreamlike;
      case VideoStyle.retro:
        return l10n.stylePromptRetro;
      case VideoStyle.tealFrame:
        return l10n.stylePromptTealFrame;
      case VideoStyle.navyExecutive:
        return l10n.stylePromptNavyExecutive;
      case VideoStyle.forestGreen:
        return l10n.stylePromptForestGreen;
      case VideoStyle.royalPurple:
        return l10n.stylePromptRoyalPurple;
      case VideoStyle.sunsetOrange:
        return l10n.stylePromptSunsetOrange;
    }
  }

  /// Enhance the user's prompt with the selected style in the current language
  static String enhancePromptWithStyle(
    BuildContext context,
    String userPrompt,
    VideoStyle style,
  ) {
    final stylePrompt = getLocalizedStylePrompt(context, style);
    // Combine user prompt with style modifier
    return '$userPrompt, $stylePrompt';
  }

  /// Detect if the prompt is primarily in Arabic
  static bool isArabicPrompt(String prompt) {
    // Arabic Unicode range: \u0600-\u06FF
    final arabicPattern = RegExp(r'[\u0600-\u06FF]');
    final arabicChars = arabicPattern.allMatches(prompt).length;
    final totalChars = prompt.replaceAll(RegExp(r'\s'), '').length;

    if (totalChars == 0) return false;

    // If more than 30% of characters are Arabic, consider it Arabic
    return (arabicChars / totalChars) > 0.3;
  }

  /// Get style prompt in the appropriate language based on prompt language
  static String getStylePromptForLanguage(
    BuildContext context,
    VideoStyle style,
    String userPrompt,
  ) {
    final isArabic = isArabicPrompt(userPrompt);

    // If prompt is in Arabic, use Arabic style prompt
    // If prompt is in English, use English style prompt
    // This ensures the style enhancement matches the prompt language
    if (isArabic) {
      // Return Arabic style prompt
      return _getArabicStylePrompt(style);
    } else {
      // Return English style prompt
      return _getEnglishStylePrompt(style);
    }
  }

  static String _getEnglishStylePrompt(VideoStyle style) {
    switch (style) {
      case VideoStyle.cinematic:
        return 'cinematic style with dramatic lighting and composition';
      case VideoStyle.animation:
        return 'animated style with vibrant colors and smooth motion';
      case VideoStyle.minimal:
        return 'minimal and clean aesthetic with simple compositions';
      case VideoStyle.modern:
        return 'modern and contemporary style';
      case VideoStyle.corporate:
        return 'professional corporate style';
      case VideoStyle.socialMedia:
        return 'engaging social media style with dynamic energy';
      case VideoStyle.vintage:
        return 'vintage style with retro aesthetics and aged film look';
      case VideoStyle.fantasy:
        return 'fantasy style with magical and otherworldly elements';
      case VideoStyle.documentary:
        return 'documentary style with realistic and observational approach';
      case VideoStyle.horror:
        return 'horror style with dark atmosphere and suspenseful mood';
      case VideoStyle.comedy:
        return 'comedy style with lighthearted and playful energy';
      case VideoStyle.sciFi:
        return 'sci-fi style with futuristic technology and advanced aesthetics';
      case VideoStyle.noir:
        return 'film noir style with high contrast and moody shadows';
      case VideoStyle.dreamlike:
        return 'dreamlike style with surreal and ethereal atmosphere';
      case VideoStyle.retro:
        return 'retro style with 80s and 90s aesthetic';
      case VideoStyle.tealFrame:
        return 'professional teal frame with clean card layout, rounded corners, and soft shadows on light background';
      case VideoStyle.navyExecutive:
        return 'executive navy blue style with gold accents, formal composition, and corporate elegance';
      case VideoStyle.forestGreen:
        return 'nature-inspired forest green palette with organic shapes, earthy tones, and calming atmosphere';
      case VideoStyle.royalPurple:
        return 'royal purple elegant style with luxurious gradients, sophisticated typography, and premium feel';
      case VideoStyle.sunsetOrange:
        return 'warm sunset orange gradient with vibrant energy, golden hour lighting, and inspiring mood';
    }
  }

  static String _getArabicStylePrompt(VideoStyle style) {
    switch (style) {
      case VideoStyle.cinematic:
        return 'بأسلوب سينمائي مع إضاءة درامية وتكوين احترافي';
      case VideoStyle.animation:
        return 'بأسلوب رسوم متحركة مع ألوان نابضة بالحياة وحركة سلسة';
      case VideoStyle.minimal:
        return 'بأسلوب بسيط ونظيف مع تكوينات مبسطة';
      case VideoStyle.modern:
        return 'بأسلوب عصري ومعاصر';
      case VideoStyle.corporate:
        return 'بأسلوب احترافي للشركات';
      case VideoStyle.socialMedia:
        return 'بأسلوب جذاب لوسائل التواصل الاجتماعي مع طاقة ديناميكية';
      case VideoStyle.vintage:
        return 'بأسلوب كلاسيكي مع جماليات قديمة ومظهر فيلم عتيق';
      case VideoStyle.fantasy:
        return 'بأسلوب خيالي مع عناصر سحرية وأجواء أسطورية';
      case VideoStyle.documentary:
        return 'بأسلوب وثائقي مع نهج واقعي ورصدي';
      case VideoStyle.horror:
        return 'بأسلوب رعب مع أجواء مظلمة ومزاج مشوق';
      case VideoStyle.comedy:
        return 'بأسلوب كوميدي مع طاقة مرحة وخفيفة';
      case VideoStyle.sciFi:
        return 'بأسلوب خيال علمي مع تقنية مستقبلية وجماليات متقدمة';
      case VideoStyle.noir:
        return 'بأسلوب فيلم نوار مع تباين عالي وظلال درامية';
      case VideoStyle.dreamlike:
        return 'بأسلوب حالم مع أجواء سريالية وأثيرية';
      case VideoStyle.retro:
        return 'بأسلوب ريترو من الثمانينات والتسعينات';
      case VideoStyle.tealFrame:
        return 'بإطار أزرق مخضر احترافي مع تخطيط بطاقات نظيف وزوايا مستديرة وظلال ناعمة على خلفية فاتحة';
      case VideoStyle.navyExecutive:
        return 'بأسلوب كحلي تنفيذي مع لمسات ذهبية وتكوين رسمي وأناقة مؤسسية';
      case VideoStyle.forestGreen:
        return 'بلوحة ألوان خضراء مستوحاة من الطبيعة مع أشكال عضوية ونغمات ترابية وأجواء هادئة';
      case VideoStyle.royalPurple:
        return 'بأسلوب بنفسجي ملكي أنيق مع تدرجات فاخرة وطباعة راقية وإحساس فاخر';
      case VideoStyle.sunsetOrange:
        return 'بتدرج برتقالي غروب دافئ مع طاقة نابضة بالحياة وإضاءة الساعة الذهبية ومزاج ملهم';
    }
  }
}
