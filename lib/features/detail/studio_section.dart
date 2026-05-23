import 'package:emby_client/core/models/base_item_dto.dart';
import 'package:emby_client/features/detail/studio_name.dart';
import 'package:emby_client/features/shared/section_header.dart';
import 'package:flutter/material.dart';

/// Displays studio information using [StudioName] components.
///
/// Shows a horizontal scrollable list of studios. Each studio is rendered
/// by [StudioName], which优先显示图片（Primary/Thumb），无图则显示文字名称。
class StudioSection extends StatelessWidget {
  /// Studio details fetched via [getStudioDetail].
  final List<BaseItemDto> studioDetails;

  /// Callback when a studio is tapped.
  final void Function(BaseItemDto studio)? onStudioTap;

  const StudioSection({
    super.key,
    required this.studioDetails,
    this.onStudioTap,
  });

  @override
  Widget build(BuildContext context) {
    if (studioDetails.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: '制片公司'),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: studioDetails.map((studio) {
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: StudioName(
                  studio: studio,
                  onTap: onStudioTap != null ? () => onStudioTap!(studio) : null,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
