/// Configuration model for multi-step video/image creation wizard
class CreationConfig {
  // Step 1: Idea
  final String prompt;
  final String? imagePath;

  // Step 2: Output Type
  final OutputType outputType;

  // Step 2: Video Settings (Sora 2 or Veo3)
  final VideoStyle? videoStyle;
  final int? videoDurationSeconds; // 10 or 15 for Sora2
  final String? videoAspectRatio; // "landscape" (16:9) or "portrait" (9:16)

  // Step 2: Voice Settings (for future TTS)
  final VoiceGender? voiceGender;
  final String? voiceDialect; // ar-SA, ar-EG, ar-AE, ar-LB, ar-JO, ar-MA

  // Step 2: Image Settings (Nano Banana)
  final ImageStyle? imageStyle;
  final String? imageSize;

  const CreationConfig({
    this.prompt = '',
    this.imagePath,
    this.outputType = OutputType.video,
    this.videoStyle,
    this.videoDurationSeconds,
    this.videoAspectRatio,
    this.voiceGender,
    this.voiceDialect,
    this.imageStyle,
    this.imageSize,
  });

  factory CreationConfig.empty() {
    return const CreationConfig(
      prompt: '',
      imagePath: null,
      outputType: OutputType.video,
      videoStyle: VideoStyle.cinematic,
      videoDurationSeconds: 10,
      videoAspectRatio: 'landscape',
      voiceGender: VoiceGender.female,
      voiceDialect: 'ar-SA',
      imageStyle: ImageStyle.realistic,
      imageSize: '1024x1024',
    );
  }

  CreationConfig copyWith({
    String? prompt,
    String? imagePath,
    OutputType? outputType,
    VideoStyle? videoStyle,
    int? videoDurationSeconds,
    String? videoAspectRatio,
    VoiceGender? voiceGender,
    String? voiceDialect,
    ImageStyle? imageStyle,
    String? imageSize,
  }) {
    return CreationConfig(
      prompt: prompt ?? this.prompt,
      imagePath: imagePath ?? this.imagePath,
      outputType: outputType ?? this.outputType,
      videoStyle: videoStyle ?? this.videoStyle,
      videoDurationSeconds: videoDurationSeconds ?? this.videoDurationSeconds,
      videoAspectRatio: videoAspectRatio ?? this.videoAspectRatio,
      voiceGender: voiceGender ?? this.voiceGender,
      voiceDialect: voiceDialect ?? this.voiceDialect,
      imageStyle: imageStyle ?? this.imageStyle,
      imageSize: imageSize ?? this.imageSize,
    );
  }

  bool get isValid {
    if (prompt.isEmpty) return false;
    if (outputType == OutputType.video) {
      return videoDurationSeconds != null && videoAspectRatio != null;
    } else {
      return imageStyle != null && imageSize != null;
    }
  }

  // Convert to API-friendly format
  Map<String, dynamic> toJson() {
    return {
      'prompt': prompt,
      'imagePath': imagePath,
      'outputType': outputType.name,
      'videoStyle': videoStyle?.name,
      'videoDurationSeconds': videoDurationSeconds,
      'videoAspectRatio': videoAspectRatio,
      'voiceGender': voiceGender?.name,
      'voiceDialect': voiceDialect,
      'imageStyle': imageStyle?.name,
      'imageSize': imageSize,
    };
  }
}

enum OutputType {
  video,
  image,
}

enum VideoStyle {
  cinematic,
  animation,
  minimal,
  modern,
  corporate,
  socialMedia,
  vintage,
  fantasy,
  documentary,
  horror,
  comedy,
  sciFi,
  noir,
  dreamlike,
  retro,
  // New Professional Templates (based on JSON spec)
  tealFrame,       // Teal/Green professional frame with card layout
  navyExecutive,   // Navy blue executive style
  forestGreen,     // Forest green nature-inspired
  royalPurple,     // Royal purple elegant style
  sunsetOrange,    // Warm sunset orange gradient
}

extension VideoStyleExtension on VideoStyle {
  String get displayName {
    switch (this) {
      case VideoStyle.cinematic:
        return 'Cinematic';
      case VideoStyle.animation:
        return 'Animation';
      case VideoStyle.minimal:
        return 'Minimal';
      case VideoStyle.modern:
        return 'Modern';
      case VideoStyle.corporate:
        return 'Corporate';
      case VideoStyle.socialMedia:
        return 'Social Media';
      case VideoStyle.vintage:
        return 'Vintage';
      case VideoStyle.fantasy:
        return 'Fantasy';
      case VideoStyle.documentary:
        return 'Documentary';
      case VideoStyle.horror:
        return 'Horror';
      case VideoStyle.comedy:
        return 'Comedy';
      case VideoStyle.sciFi:
        return 'Sci-Fi';
      case VideoStyle.noir:
        return 'Noir';
      case VideoStyle.dreamlike:
        return 'Dreamlike';
      case VideoStyle.retro:
        return 'Retro';
      // New Professional Templates
      case VideoStyle.tealFrame:
        return 'Teal Frame';
      case VideoStyle.navyExecutive:
        return 'Navy Executive';
      case VideoStyle.forestGreen:
        return 'Forest Green';
      case VideoStyle.royalPurple:
        return 'Royal Purple';
      case VideoStyle.sunsetOrange:
        return 'Sunset Orange';
    }
  }

  String get promptModifier {
    switch (this) {
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
      // New Professional Templates
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

  /// Returns theme colors for the template style
  VideoStyleTheme get theme {
    switch (this) {
      case VideoStyle.tealFrame:
        return const VideoStyleTheme(
          primary: '#0F3A3F',
          secondary: '#00A88F',
          accent: '#FFC857',
          background: '#F5F7FA',
          text: '#123047',
        );
      case VideoStyle.navyExecutive:
        return const VideoStyleTheme(
          primary: '#1E3A5F',
          secondary: '#C9A227',
          accent: '#E8D5B7',
          background: '#F8F9FA',
          text: '#1E3A5F',
        );
      case VideoStyle.forestGreen:
        return const VideoStyleTheme(
          primary: '#2D5A3D',
          secondary: '#7CB342',
          accent: '#C5E1A5',
          background: '#F1F8E9',
          text: '#1B5E20',
        );
      case VideoStyle.royalPurple:
        return const VideoStyleTheme(
          primary: '#4A148C',
          secondary: '#9C27B0',
          accent: '#E1BEE7',
          background: '#F3E5F5',
          text: '#311B92',
        );
      case VideoStyle.sunsetOrange:
        return const VideoStyleTheme(
          primary: '#E65100',
          secondary: '#FF9800',
          accent: '#FFE0B2',
          background: '#FFF3E0',
          text: '#BF360C',
        );
      default:
        return const VideoStyleTheme(
          primary: '#7C3AED',
          secondary: '#A78BFA',
          accent: '#DDD6FE',
          background: '#F5F5F7',
          text: '#1F2937',
        );
    }
  }
}

/// Theme colors for a video style template
class VideoStyleTheme {
  final String primary;
  final String secondary;
  final String accent;
  final String background;
  final String text;

  const VideoStyleTheme({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.background,
    required this.text,
  });

  Map<String, dynamic> toJson() => {
    'primary': primary,
    'secondary': secondary,
    'accent': accent,
    'background': background,
    'text': text,
  };
}

enum VoiceGender {
  male,
  female,
}

enum ImageStyle {
  realistic,
  cartoon,
  artistic,
}

extension ImageStyleExtension on ImageStyle {
  String get displayName {
    switch (this) {
      case ImageStyle.realistic:
        return 'Realistic';
      case ImageStyle.cartoon:
        return 'Cartoon';
      case ImageStyle.artistic:
        return 'Artistic';
    }
  }
}
