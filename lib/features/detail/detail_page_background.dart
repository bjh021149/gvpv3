import 'dart:ui';

import 'package:emby_client/core/models/base_item_dto.dart';
import 'package:emby_client/features/shared/emby_cached_image.dart';
import 'package:flutter/material.dart';

/// Full-screen background layer for the detail page.
///
/// Displays the media's backdrop image with a gaussian blur and a
/// semi-transparent theme-colored frosted overlay.
///
/// The blur intensity and overlay opacity adapt to the current
/// [ThemeData.brightness] for optimal readability in both light
/// and dark modes.
class DetailPageBackground extends StatelessWidget {
  /// The media item to extract the backdrop from.
  final BaseItemDto item;

  const DetailPageBackground({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;

    // Adaptive blur and overlay based on theme brightness
    final blurSigma = brightness == Brightness.dark ? 24.0 : 32.0;
    final overlayOpacity = brightness == Brightness.dark ? 0.65 : 0.75;

    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Backdrop image
          if (item.backdropImageTags != null &&
              item.backdropImageTags!.isNotEmpty)
            EmbyCachedImage(
              itemId: item.id!,
              imageTagList: [
                MapEntry('Backdrop', item.backdropImageTags?.first ?? ''),
              ],
              maxWidth: 1280,
              maxHeight: 720,
              fit: BoxFit.cover,
            )
          else
            Container(
              color: colorScheme.surfaceContainerHighest,
            ),

          // 2. Gaussian blur (frosted glass base)
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(
                sigmaX: blurSigma,
                sigmaY: blurSigma,
              ),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),

          // 3. Theme-colored frosted overlay
          Positioned.fill(
            child: Container(
              color: colorScheme.surface.withValues(
                alpha: overlayOpacity,
              ),
            ),
          ),

          // 4. Subtle top gradient for nav button readability
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: const Alignment(0, 0.25),
                colors: [
                  colorScheme.scrim.withValues(alpha: 0.35),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
