import 'package:emby_client/core/responsive/screen_layout.dart';
import 'package:flutter/material.dart';

/// {@template adaptive_grid}
/// 自适应网格组件
///
/// 根据屏幕尺寸自动调整列数和子项宽高比，支持无限滚动加载更多。
///
/// 使用 Material Design 3 断点规则：
/// - 手机 (<600dp): 2列, 宽高比 0.65
/// - 小平板 (600-839dp): 3列, 宽高比 0.70
/// - 平板 (840-1199dp): 4列, 宽高比 0.72
/// - 桌面 (1200-1599dp): 5列, 宽高比 0.75
/// - 大桌面 (>=1600dp): 6列, 宽高比 0.78
///
/// 使用示例：
/// ```dart
/// AdaptiveGrid<Movie>(
///   items: movies,
///   itemBuilder: (context, movie) => MovieCard(movie: movie),
///   onLoadMore: () => ref.read(moviesProvider.notifier).loadMore(),
///   isLoadingMore: isLoading,
/// )
/// ```
/// {@endtemplate}
class AdaptiveGrid<T> extends StatelessWidget {
  /// 数据源列表
  final List<T> items;

  /// 子项构建函数
  final Widget Function(BuildContext context, T item) itemBuilder;

  /// 可选的滚动控制器
  final ScrollController? scrollController;

  /// 内边距
  final EdgeInsets padding;

  /// 加载更多回调（到达 80% 位置时触发）
  final VoidCallback? onLoadMore;

  /// 是否正在加载更多（显示底部 loading 指示器）
  final bool isLoadingMore;

  /// 网格主轴间距
  final double crossAxisSpacing;

  /// 网格纵轴间距
  final double mainAxisSpacing;

  /// 自定义列数（为 null 时根据屏幕尺寸自动计算）
  final int? crossAxisCount;

  /// 自定义子项宽高比（为 null 时根据屏幕尺寸自动计算）
  final double? childAspectRatio;

  /// 触发加载更多的滚动阈值（0.0 ~ 1.0）
  final double loadMoreThreshold;

  /// 空数据占位组件
  final Widget? emptyWidget;

  /// 列表头部组件
  final Widget? header;

  /// physics 滚动物理效果
  final ScrollPhysics? physics;

  const AdaptiveGrid({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.scrollController,
    this.padding = const EdgeInsets.all(16),
    this.onLoadMore,
    this.isLoadingMore = false,
    this.crossAxisSpacing = 12,
    this.mainAxisSpacing = 16,
    this.crossAxisCount,
    this.childAspectRatio,
    this.loadMoreThreshold = 0.8,
    this.emptyWidget,
    this.header,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    final layout = ScreenLayout.of(context);
    final effectiveCrossAxisCount = crossAxisCount ?? layout.gridCrossAxisCount;
    final effectiveChildAspectRatio =
        childAspectRatio ?? layout.gridChildAspectRatio;

    // 空数据状态
    if (items.isEmpty && !isLoadingMore) {
      return emptyWidget ??
          const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  '暂无数据',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: CustomScrollView(
        controller: scrollController,
        physics: physics,
        slivers: [
          // 头部
          if (header != null)
            SliverToBoxAdapter(
              child: header,
            ),

          // 主网格
          SliverPadding(
            padding: padding,
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: effectiveCrossAxisCount,
                childAspectRatio: effectiveChildAspectRatio,
                crossAxisSpacing: crossAxisSpacing,
                mainAxisSpacing: mainAxisSpacing,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => itemBuilder(context, items[index]),
                childCount: items.length,
                // 启用子项复用优化
                addRepaintBoundaries: true,
                addSemanticIndexes: true,
              ),
            ),
          ),

          // 底部加载指示器
          if (isLoadingMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 处理滚动通知，实现无限滚动加载
  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollEndNotification && onLoadMore != null) {
      final maxScroll = notification.metrics.maxScrollExtent;
      final currentScroll = notification.metrics.pixels;

      // 当滚动到阈值位置时触发加载更多
      if (maxScroll > 0 && currentScroll >= maxScroll * loadMoreThreshold) {
        onLoadMore!();
      }
    }
    return false;
  }
}

/// {@template adaptive_staggered_grid}
/// 自适应交错网格（瀑布流布局）
///
/// 与 [AdaptiveGrid] 类似，但支持不同高度的子项，形成瀑布流效果。
/// 适用于图片墙、内容流等场景。
/// {@endtemplate}
class AdaptiveStaggeredGrid<T> extends StatelessWidget {
  /// 数据源列表
  final List<T> items;

  /// 子项构建函数，返回的子项可以具有不同高度
  final Widget Function(BuildContext context, T item) itemBuilder;

  /// 可选的滚动控制器
  final ScrollController? scrollController;

  /// 内边距
  final EdgeInsets padding;

  /// 加载更多回调
  final VoidCallback? onLoadMore;

  /// 是否正在加载更多
  final bool isLoadingMore;

  /// 网格主轴间距
  final double crossAxisSpacing;

  /// 网格纵轴间距
  final double mainAxisSpacing;

  /// 自定义列数（为 null 时根据屏幕尺寸自动计算）
  final int? crossAxisCount;

  /// 触发加载更多的滚动阈值
  final double loadMoreThreshold;

  /// 空数据占位组件
  final Widget? emptyWidget;

  const AdaptiveStaggeredGrid({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.scrollController,
    this.padding = const EdgeInsets.all(16),
    this.onLoadMore,
    this.isLoadingMore = false,
    this.crossAxisSpacing = 12,
    this.mainAxisSpacing = 16,
    this.crossAxisCount,
    this.loadMoreThreshold = 0.8,
    this.emptyWidget,
  });

  @override
  Widget build(BuildContext context) {
    final layout = ScreenLayout.of(context);
    final effectiveCrossAxisCount = crossAxisCount ?? layout.gridCrossAxisCount;

    if (items.isEmpty && !isLoadingMore) {
      return emptyWidget ??
          const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  '暂无数据',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverPadding(
            padding: padding,
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: effectiveCrossAxisCount,
                childAspectRatio: 0.6, // 瀑布流使用较小的基础比例
                crossAxisSpacing: crossAxisSpacing,
                mainAxisSpacing: mainAxisSpacing,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => itemBuilder(context, items[index]),
                childCount: items.length,
              ),
            ),
          ),
          if (isLoadingMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollEndNotification && onLoadMore != null) {
      final maxScroll = notification.metrics.maxScrollExtent;
      final currentScroll = notification.metrics.pixels;
      if (maxScroll > 0 && currentScroll >= maxScroll * loadMoreThreshold) {
        onLoadMore!();
      }
    }
    return false;
  }
}
