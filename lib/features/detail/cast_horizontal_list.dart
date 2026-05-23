import 'package:emby_client/core/models/base_item_dto.dart';
import 'package:emby_client/core/responsive/screen_layout.dart';
import 'package:emby_client/features/shared/emby_cached_image.dart';
import 'package:emby_client/services/cache/cache_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Displays a horizontally scrollable list of cast members.
///
/// Each item shows:
/// - [CircleAvatar] with the person's photo (or initials fallback)
/// - Person's full name
/// - Character/role name
///
/// This component independently watches the [_people] box via
/// [peopleProvider] and only rebuilds when the cast list changes.
class CastHorizontalList extends ConsumerWidget {
  /// The item ID to watch for cast data.
  final String itemId;

  /// Callback when a person is tapped.
  final void Function(PersonDto person)? onPersonTap;

  const CastHorizontalList({
    super.key,
    required this.itemId,
    this.onPersonTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final peopleAsync = ref.watch(peopleProvider(itemId));

    return peopleAsync.when(
      data: (people) {
        final cast = people ?? [];
        if (cast.isEmpty) return const SizedBox.shrink();
        return _CastListView(people: cast, onPersonTap: onPersonTap);
      },
      loading: () => _buildSkeleton(context),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    final layout = ScreenLayout.of(context);
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: layout.horizontalPadding),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Container(
              width: 80,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CastListView extends StatelessWidget {
  final List<PersonDto> people;
  final void Function(PersonDto person)? onPersonTap;

  const _CastListView({
    required this.people,
    this.onPersonTap,
  });

  @override
  Widget build(BuildContext context) {
    final layout = ScreenLayout.of(context);
    final horizontalPadding = layout.horizontalPadding;

    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        itemCount: people.length,
        itemBuilder: (context, index) {
          final person = people[index];
          return _CastItem(
            person: person,
            onTap: onPersonTap != null ? () => onPersonTap!(person) : null,
          );
        },
      ),
    );
  }
}

class _CastItem extends StatelessWidget {
  final PersonDto person;
  final VoidCallback? onTap;

  const _CastItem({
    required this.person,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final displayName = person.name ?? '未知';
    final displayRole = person.role ?? person.type ?? '';

    return Semantics(
      label: '$displayName${displayRole.isNotEmpty ? ' 饰演 $displayRole' : ''}',
      button: onTap != null,
      child: Tooltip(
        message: displayName,
        child: GestureDetector(
          onTap: onTap,
          child: SizedBox(
            width: 80,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildAvatar(context),
                const SizedBox(height: 8),
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
                if (displayRole.isNotEmpty)
                  Text(
                    displayRole,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final personId = person.id;
    final imageTag = person.primaryImageTag;

    if (personId != null && imageTag != null && imageTag.isNotEmpty) {
      return ClipOval(
        child: EmbyCachedImage(
          itemId: personId,
          imageTagList: [MapEntry('Primary', imageTag)],
          width: 64,
          height: 64,
          fit: BoxFit.cover,
          placeholderColor: colorScheme.secondaryContainer,
          errorColor: colorScheme.secondaryContainer,
          errorIcon: null,
          errorWidget: _buildInitialsAvatar(context),
        ),
      );
    }

    return _buildInitialsAvatar(context);
  }

  Widget _buildInitialsAvatar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final initials = _getInitials();

    return CircleAvatar(
      radius: 32,
      backgroundColor: colorScheme.secondaryContainer,
      foregroundColor: colorScheme.onSecondaryContainer,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            initials,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  String _getInitials() {
    final name = person.name;
    if (name == null || name.isEmpty) return '?';

    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    if (parts.isNotEmpty) {
      return parts.first[0].toUpperCase();
    }
    return '?';
  }
}
