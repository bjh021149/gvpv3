import 'package:emby_client/core/models/base_item_dto.dart';
import 'package:emby_client/core/responsive/screen_layout.dart';
import 'package:emby_client/features/shared/media_card.dart';
import 'package:flutter/material.dart';

/// Displays a horizontally scrollable row of similar/recommended media items.
///
/// Composed of:
/// - [SectionHeader] with title "More Like This"
/// - Horizontal [ListView] of [MediaCard] widgets
///
/// Each card is displayed at a smaller size than the standard grid view.
/// Tapping a card navigates to its detail page via the provided callback.
class SimilarItemsRow extends StatelessWidget {
  /// List of similar/recommended items to display.
  final List<BaseItemDto> items;

  /// Callback when an item card is tapped.
  /// Receives the tapped item as a parameter.
  final ValueChanged<BaseItemDto> onItemTap;

  /// Constructor for the similar items row.
  const SimilarItemsRow({
    super.key,
    required this.items,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    final layout = ScreenLayout.of(context);
    final horizontalPadding = layout.horizontalPadding;

    // Responsive card width based on screen type
    final cardWidth = switch (layout.type) {
      ScreenType.extraLarge => 160.0,
      ScreenType.large => 150.0,
      ScreenType.expanded => 140.0,
      ScreenType.medium => 130.0,
      ScreenType.compact => 120.0,
    };

    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: SizedBox(
              width: cardWidth,
              child: MediaCard(
                item: item,
                width: cardWidth,
                aspectRatio: 0.67,
                onTap: () => onItemTap(item),
              ),
            ),
          );
        },
      ),
    );
  }
}
