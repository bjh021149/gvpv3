import 'package:emby_client/core/api/emby_api_service.dart';
import 'package:emby_client/core/models/base_item_dto.dart';
import 'package:emby_client/core/navigation/detail_navigation.dart';
import 'package:emby_client/core/responsive/screen_layout.dart';
import 'package:emby_client/features/shared/media_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Displays a grid of items related to a studio, person, or genre with pagination.
///
/// Used when the user taps "View More" from the related items bottom sheet
/// or taps a genre chip on the detail page.
class RelatedItemsPage extends ConsumerStatefulWidget {
  final String title;
  final String? studioId;
  final String? personId;
  final String? genre;

  const RelatedItemsPage({
    super.key,
    required this.title,
    this.studioId,
    this.personId,
    this.genre,
  });

  @override
  ConsumerState<RelatedItemsPage> createState() => _RelatedItemsPageState();
}

class _RelatedItemsPageState extends ConsumerState<RelatedItemsPage> {
  final List<BaseItemDto> _items = [];
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;
  int _startIndex = 0;
  bool _hasMore = true;

  static const int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadItems();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isLoadingMore || !_hasMore) return;

    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadItems() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _startIndex = 0;
      _hasMore = true;
      _items.clear();
    });

    try {
      final api = ref.read(embyApiServiceProvider);
      final result = await api.getItems(
        studioIds: widget.studioId != null ? [widget.studioId!] : null,
        personIds: widget.personId != null ? [widget.personId!] : null,
        genres: widget.genre != null ? [widget.genre!] : null,
        includeItemTypes: 'Movie,Series',
        recursive: true,
        sortBy: 'ProductionYear',
        sortOrder: false,
        startIndex: _startIndex,
        limit: _pageSize,
        fields: 'PrimaryImageAspectRatio,BasicSyncInfo,MediaSourceCount,ProductionYear,ImageTags',
      );
      if (mounted) {
        setState(() {
          _items.addAll(result.items);
          _hasMore = result.items.length >= _pageSize;
          _startIndex += result.items.length;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final api = ref.read(embyApiServiceProvider);
      final result = await api.getItems(
        studioIds: widget.studioId != null ? [widget.studioId!] : null,
        personIds: widget.personId != null ? [widget.personId!] : null,
        genres: widget.genre != null ? [widget.genre!] : null,
        includeItemTypes: 'Movie,Series',
        recursive: true,
        sortBy: 'ProductionYear',
        sortOrder: false,
        startIndex: _startIndex,
        limit: _pageSize,
        fields: 'PrimaryImageAspectRatio,BasicSyncInfo,MediaSourceCount,ProductionYear,ImageTags',
      );
      if (mounted) {
        setState(() {
          _items.addAll(result.items);
          _hasMore = result.items.length >= _pageSize;
          _startIndex += result.items.length;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final layout = ScreenLayout.of(context);
    final crossAxisCount = switch (layout.type) {
      ScreenType.compact => 3,
      ScreenType.medium => 4,
      ScreenType.expanded => 4,
      ScreenType.large => 6,
      ScreenType.extraLarge => 6,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
      ),
      body: _buildContent(context, crossAxisCount),
    );
  }

  Widget _buildContent(BuildContext context, int crossAxisCount) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 8),
            Text('加载失败: $_error'),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _loadItems,
              icon: const Icon(Icons.refresh),
              label: const Text('重试'),
            ),
          ],
        ),
      );
    }
    if (_items.isEmpty) {
      return const Center(child: Text('暂无关联作品'));
    }

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.7,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _items.length + (_isLoadingMore ? crossAxisCount : 0),
      itemBuilder: (context, index) {
        if (index >= _items.length) {
          return const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }
        final item = _items[index];
        return MediaCard(
          item: item,
          onTap: () => goToDetail(context, ref, item),
        );
      },
    );
  }
}
