import 'dart:async';

import 'package:emby_client/core/models/base_item_dto.dart';
import 'package:emby_client/core/navigation/detail_navigation.dart';
import 'package:emby_client/features/shared/emby_cached_image.dart';
import 'package:emby_client/features/shared/logo_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


/// Auto-playing hero carousel that displays featured media items
/// in a 16:9 aspect ratio with dot indicators and gradient overlay.
class HeroCarousel extends ConsumerStatefulWidget {
  final List<BaseItemDto> items;

  const HeroCarousel({super.key, required this.items});

  @override
  ConsumerState<HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends ConsumerState<HeroCarousel> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  Timer? _autoPlayTimer;

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  /// Starts the auto-play timer that advances the page every 5 seconds.
  void _startAutoPlay() {
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted) return;
      if (widget.items.length <= 1) return;
      final nextIndex = (_currentIndex + 1) % widget.items.length;
      _pageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onItemTap(BaseItemDto item) {
    goToDetail(context, ref, item);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (widget.items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Semantics(
      label: 'Featured media carousel with ${widget.items.length} items',
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.items.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) {
                final item = widget.items[index];
                return _CarouselPage(
                  item: item,
                  onTap: () => _onItemTap(item),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          // Dot indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.items.length, (index) {
              return Semantics(
                label: 'Page ${index + 1} of ${widget.items.length}',
                child: GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentIndex == index ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color:
                          _currentIndex == index
                              ? colorScheme.primary
                              : colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

/// A single carousel page with background image, gradient overlay, and title.
class _CarouselPage extends ConsumerWidget {
  final BaseItemDto item;
  final VoidCallback onTap;

  const _CarouselPage({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final logoMaxWidth = screenWidth * 0.35;
    final itemId = item.id;
    if (itemId == null || itemId.isEmpty) {
      return const SizedBox.shrink();
    }

    return Semantics(
      button: true,
      label: item.name,
      onTapHint: 'Open ${item.name} details',
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            Positioned.fill(
              child: EmbyCachedImage(
                itemId: itemId,
                imageTagList: [
                  MapEntry('Backdrop', item.imageTags?['Backdrop'] ?? ''),
                  MapEntry('Primary', item.imageTags?['Primary'] ?? ''),
                  MapEntry('Thumb', item.imageTags?['Thumb'] ?? ''),
                ],
                maxWidth: screenWidth.ceil(),
                showProgressIndicator: true,
              ),
            ),
            // Bottom gradient overlay
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 120,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),
            ),
            // Title and metadata
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  LogoTitle(
                    item: item,
                    logoMaxHeight: 60,
                    logoMaxWidth: logoMaxWidth.ceil(),
                    textStyle: textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 4,
                          color: Colors.black.withValues(alpha: 0.5),
                        ),
                      ],
                    ),
                    textColor: Colors.white,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.productionYear != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '${item.productionYear}',
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                          shadows: [
                            Shadow(
                              blurRadius: 4,
                              color: Colors.black.withValues(alpha: 0.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
