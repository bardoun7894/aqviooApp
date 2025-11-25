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
    }
  }
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
