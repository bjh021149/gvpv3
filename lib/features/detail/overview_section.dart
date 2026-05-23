import 'package:emby_client/services/cache/cache_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Displays the overview / synopsis text for a media item.
///
/// Independently watches the item core data via [itemCoreProvider]
/// and only rebuilds when the overview or other core fields change.
class OverviewSection extends ConsumerWidget {
  /// The item ID to watch.
  final String itemId;

  const OverviewSection({
    super.key,
    required this.itemId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemAsync = ref.watch(itemCoreProvider(itemId));

    return itemAsync.when(
      data: (item) {
        final overview = item?.overview;
        if (overview == null || overview.isEmpty) {
          return const SizedBox.shrink();
        }
        return _OverviewContent(overview: overview);
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _OverviewContent extends StatelessWidget {
  final String overview;

  const _OverviewContent({required this.overview});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '简介',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          overview,
          style: textTheme.bodyMedium?.copyWith(
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
