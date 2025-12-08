import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:simple_animations/simple_animations.dart';

import '../theme/app_colors.dart';
import '../../generated/app_localizations.dart';

/// A professional skeleton loading card that shows when content is generating.
/// Displays animated shimmer effect with "Generating..." text.
class GeneratingSkeletonCard extends StatelessWidget {
  final bool isVideo;
  final bool isCompact; // For grid view (smaller)
  final String? prompt;

  const GeneratingSkeletonCard({
    super.key,
    this.isVideo = true,
    this.isCompact = true,
    this.prompt,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.9),
            Colors.white.withOpacity(0.7),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Animated Skeleton Area
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isVideo
                      ? [
                          const Color(0xFFA076F9).withOpacity(0.8),
                          const Color(0xFF82C8F7).withOpacity(0.8)
                        ]
                      : [
                          const Color(0xFFFF6B9D).withOpacity(0.8),
                          const Color(0xFFFFA06B).withOpacity(0.8)
                        ],
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Shimmer animation overlay
                    _ShimmerEffect(),

                    // Center loading indicator
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Animated magic icon
                          _AnimatedMagicIcon(),
                          SizedBox(height: isCompact ? 8 : 12),
                          // Generating text with animated dots
                          _AnimatedGeneratingText(
                            isVideo: isVideo,
                            isCompact: isCompact,
                          ),
                        ],
                      ),
                    ),

                    // Type badge
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isVideo
                                  ? Icons.videocam_rounded
                                  : Icons.image_rounded,
                              size: 12,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isVideo ? l10n.video : l10n.image,
                              style: GoogleFonts.outfit(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Details section
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(isCompact ? 12 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Prompt or skeleton text
                  Expanded(
                    child: prompt != null && prompt!.isNotEmpty
                        ? Text(
                            prompt!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              fontSize: isCompact ? 12 : 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                              height: 1.3,
                            ),
                          )
                        : _SkeletonTextLines(isCompact: isCompact),
                  ),
                  SizedBox(height: isCompact ? 6 : 8),
                  // Status indicator
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryPurple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 10,
                              height: 10,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primaryPurple,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              l10n.processing,
                              style: GoogleFonts.outfit(
                                fontSize: isCompact ? 10 : 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryPurple,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shimmer effect overlay
class _ShimmerEffect extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomAnimationBuilder<double>(
      tween: Tween<double>(begin: -1.0, end: 2.0),
      duration: const Duration(milliseconds: 1500),
      control: Control.loop,
      builder: (context, value, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1 + value, 0),
              end: Alignment(value, 0),
              colors: [
                Colors.white.withOpacity(0.0),
                Colors.white.withOpacity(0.2),
                Colors.white.withOpacity(0.0),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

/// Animated magic icon with pulsing effect
class _AnimatedMagicIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.9, end: 1.1),
      duration: const Duration(milliseconds: 800),
      control: Control.mirror,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.4),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        );
      },
    );
  }
}

/// Animated "Generating..." text with dots
class _AnimatedGeneratingText extends StatelessWidget {
  final bool isVideo;
  final bool isCompact;

  const _AnimatedGeneratingText({
    required this.isVideo,
    required this.isCompact,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final text = isVideo ? l10n.generatingVideo : l10n.generatingImage;

    return CustomAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: 3),
      duration: const Duration(milliseconds: 800),
      control: Control.loop,
      builder: (context, value, child) {
        final dots = '.' * value;
        return Text(
          '$text$dots',
          style: GoogleFonts.outfit(
            fontSize: isCompact ? 12 : 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 4,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Skeleton placeholder text lines
class _SkeletonTextLines extends StatelessWidget {
  final bool isCompact;

  const _SkeletonTextLines({required this.isCompact});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SkeletonLine(width: double.infinity, height: isCompact ? 10 : 12),
        SizedBox(height: isCompact ? 6 : 8),
        _SkeletonLine(width: 80, height: isCompact ? 10 : 12),
      ],
    );
  }
}

/// Single skeleton line with shimmer
class _SkeletonLine extends StatelessWidget {
  final double width;
  final double height;

  const _SkeletonLine({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return CustomAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.5, end: 1.0),
      duration: const Duration(milliseconds: 800),
      control: Control.mirror,
      builder: (context, value, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: AppColors.lightGray.withOpacity(value),
            borderRadius: BorderRadius.circular(6),
          ),
        );
      },
    );
  }
}

/// List view variant of the skeleton card (for list mode in my creations)
class GeneratingSkeletonListCard extends StatelessWidget {
  final bool isVideo;
  final String? prompt;

  const GeneratingSkeletonListCard({
    super.key,
    this.isVideo = true,
    this.prompt,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.9),
            Colors.white.withOpacity(0.7),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail area
          Container(
            height: 220,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(22),
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isVideo
                    ? [
                        const Color(0xFFA076F9).withOpacity(0.8),
                        const Color(0xFF82C8F7).withOpacity(0.8)
                      ]
                    : [
                        const Color(0xFFFF6B9D).withOpacity(0.8),
                        const Color(0xFFFFA06B).withOpacity(0.8)
                      ],
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(22),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _ShimmerEffect(),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _AnimatedMagicIcon(),
                        const SizedBox(height: 16),
                        _AnimatedGeneratingText(
                          isVideo: isVideo,
                          isCompact: false,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Details
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (prompt != null && prompt!.isNotEmpty)
                  Text(
                    prompt!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SkeletonLine(width: double.infinity, height: 14),
                      const SizedBox(height: 8),
                      _SkeletonLine(width: 150, height: 14),
                    ],
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryPurple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primaryPurple,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.processing,
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryPurple,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.lightGray.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isVideo
                                ? Icons.videocam_rounded
                                : Icons.image_rounded,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isVideo ? l10n.video : l10n.image,
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
