// lib/services/cache/emby_cache.dart
//
// Hive-based multi-box cache for Emby API data.
//
// Design principles:
// - One itemId is the primary key across all boxes
// - Core fields (lightweight) are separated from heavy/variable fields
// - List queries only touch the core box + list index box
// - Incremental updates only write to the changed boxes
// - UserData changes frequently → isolated box
// - MediaSources can be large → isolated box

import 'dart:async';
import 'dart:convert';

import 'package:emby_client/core/models/base_item_dto.dart';
import 'package:emby_client/core/models/media_source_info.dart';
import 'package:emby_client/core/models/query_result.dart';
import 'package:emby_client/core/models/user_item_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';

/// Box names used by [EmbyCache].
abstract class _BoxNames {
  static const core = 'cache_items_core';
  static const userdata = 'cache_items_userdata';
  static const genres = 'cache_items_genres';
  static const studios = 'cache_items_studios';
  static const providerIds = 'cache_items_providerIds';
  static const people = 'cache_items_people';
  static const mediaSources = 'cache_items_mediaSources';
  static const listIndices = 'cache_list_indices';
  static const listMeta = 'cache_list_meta';
}

/// {@template emby_cache}
/// Multi-box Hive cache for Emby API responses.
///
/// Splits a [BaseItemDto] across 7 dedicated boxes, all keyed by [item.id]:
///
/// | Box | Content | When to read | When to write |
/// |-----|---------|--------------|---------------|
/// | [core] | id, name, type, overview, year, rating, imageTags, etc. | Always | Always |
/// | [userdata] | playbackPositionTicks, isFavorite, played, etc. | After playback | After playback / API refresh |
/// | `genres` | `List<String>` | Detail view | Detail view |
/// | `studios` | `List<StudioDto>` | Detail view | Detail view |
/// | `providerIds` | `Map<String,String>` | Detail view | Detail view |
/// | `people` | `List<PersonDto>` | Detail view | Detail view |
/// | `mediaSources` | `List<MediaSourceInfo>` | Before playback | Detail view |
///
/// List results are stored as ID indices in [listIndices] + metadata in [listMeta],
/// while the actual objects live in the core/child boxes.
/// {@endtemplate}
class EmbyCache {
  // ── Boxes ──────────────────────────────────────────────

  late final Box<dynamic> _core;
  late final Box<dynamic> _userdata;
  late final Box<dynamic> _genres;
  late final Box<dynamic> _studios;
  late final Box<dynamic> _providerIds;
  late final Box<dynamic> _people;
  late final Box<dynamic> _mediaSources;
  late final Box<dynamic> _listIndices;
  late final Box<dynamic> _listMeta;

  bool _initialized = false;

  // ── Initialization ─────────────────────────────────────

  /// {@macro emby_cache}
  EmbyCache();

  /// Opens all Hive boxes. Must be called once before any cache operation.
  /// Typically invoked in `main()` after `Hive.initFlutter()`.
  Future<void> init() async {
    if (_initialized) return;

    await Future.wait([
      Hive.openBox<dynamic>(_BoxNames.core).then((b) => _core = b),
      Hive.openBox<dynamic>(_BoxNames.userdata).then((b) => _userdata = b),
      Hive.openBox<dynamic>(_BoxNames.genres).then((b) => _genres = b),
      Hive.openBox<dynamic>(_BoxNames.studios).then((b) => _studios = b),
      Hive.openBox<dynamic>(_BoxNames.providerIds).then((b) => _providerIds = b),
      Hive.openBox<dynamic>(_BoxNames.people).then((b) => _people = b),
      Hive.openBox<dynamic>(_BoxNames.mediaSources)
          .then((b) => _mediaSources = b),
      Hive.openBox<dynamic>(_BoxNames.listIndices)
          .then((b) => _listIndices = b),
      Hive.openBox<dynamic>(_BoxNames.listMeta).then((b) => _listMeta = b),
    ]);

    _initialized = true;
  }

  void _assertInit() {
    assert(_initialized, 'EmbyCache.init() must be called first');
  }

  // ═══════════════════════════════════════════════════════
  //  Single-item operations
  // ═══════════════════════════════════════════════════════

  /// Writes a complete [BaseItemDto] into all relevant boxes.
  /// Use this after fetching an item detail from the API.
  Future<void> putItem(BaseItemDto item) async {
    _assertInit();
    final id = item.id;
    if (id == null || id.isEmpty) return;

    await Future.wait([
      _putCore(id, item),
      if (item.userData != null) _putUserData(id, item.userData!),
      if (item.genres != null && item.genres!.isNotEmpty)
        _putGenres(id, item.genres!),
      if (item.studios != null && item.studios!.isNotEmpty)
        _putStudios(id, item.studios!),
      if (item.providerIds != null && item.providerIds!.isNotEmpty)
        _putProviderIds(id, item.providerIds!),
      if (item.people.isNotEmpty) _putPeople(id, item.people),
      if (item.mediaSources.isNotEmpty)
        _putMediaSources(id, item.mediaSources),
    ]);
  }

  /// Writes multiple items in batch.
  Future<void> putItems(Iterable<BaseItemDto> items) async {
    for (final item in items) {
      await putItem(item);
    }
  }

  /// Watches a single item for cache changes.
  ///
  /// Returns a [Stream] that emits the updated [BaseItemDto] whenever
  /// the item's data changes in any box. The stream emits `null` if the
  /// item is deleted from the cache.
  ///
  /// **Note**: This only listens to the `_core` box. Heavy fields
  /// (people, studios, genres) stored in separate boxes will NOT trigger
  /// this stream. Use [watchItemFull] or the specific watch methods
  /// (e.g. [watchPeople]) for those fields.
  Stream<BaseItemDto?> watchItem(String id) {
    _assertInit();
    return _core.watch(key: id).map((_) => getItem(id, includeHeavyFields: true));
  }

  // ── Atomic watch methods (fine-grained, one per box) ────

  /// Reads core fields directly from the [_core] box without assembling
  /// heavy fields. Returns null if the item is not in the cache.
  BaseItemDto? _getItemCore(String id) {
    final raw = _core.get(id);
    if (raw == null) return null;
    try {
      return BaseItemDto.fromJson(Map<String, dynamic>.from(raw as Map));
    } catch (_) {
      return null;
    }
  }

  /// Watches only the [_core] box fields for an item.
  ///
  /// Emits the current cached value immediately, then emits updates
  /// whenever the core box changes. Emits `null` if the item is not cached.
  Stream<BaseItemDto?> watchItemCore(String id) {
    _assertInit();

    final controller = StreamController<BaseItemDto?>();
    final subscription = _core.watch(key: id).listen((event) {
      controller.add(_getItemCore(id));
    });

    controller.onCancel = () => subscription.cancel();

    // Emit initial value (cached or null)
    controller.add(_getItemCore(id));

    return controller.stream;
  }

  /// Watches all boxes related to an item and emits the fully assembled
  /// [BaseItemDto] whenever ANY of them change.
  ///
  /// Emits the current cached value immediately, then emits updates.
  /// This fixes the limitation of [watchItem] which only listens to
  /// the core box.
  Stream<BaseItemDto?> watchItemFull(String id) {
    _assertInit();

    final controller = StreamController<BaseItemDto?>();
    final subscriptions = <StreamSubscription<BoxEvent>>[];

    void emit() => controller.add(getItem(id, includeHeavyFields: true));

    subscriptions.addAll([
      _core.watch(key: id).listen((_) => emit()),
      _userdata.watch(key: id).listen((_) => emit()),
      _genres.watch(key: id).listen((_) => emit()),
      _studios.watch(key: id).listen((_) => emit()),
      _people.watch(key: id).listen((_) => emit()),
      _mediaSources.watch(key: id).listen((_) => emit()),
    ]);

    controller.onCancel = () {
      for (final sub in subscriptions) {
        sub.cancel();
      }
    };

    // Emit initial value (cached or null)
    controller.add(getItem(id, includeHeavyFields: true));

    return controller.stream;
  }

  /// Watches the [_people] box for a specific item.
  ///
  /// Emits the current cached value immediately, then emits updates.
  Stream<List<PersonDto>?> watchPeople(String id) {
    _assertInit();

    final controller = StreamController<List<PersonDto>?>();
    final subscription = _people.watch(key: id).listen((event) {
      controller.add(_getPeople(id));
    });

    controller.onCancel = () => subscription.cancel();
    controller.add(_getPeople(id));

    return controller.stream;
  }

  List<PersonDto>? _getPeople(String id) {
    final raw = _people.get(id);
    if (raw == null) return null;
    try {
      final list = List<dynamic>.from(raw as List);
      return list
          .map((json) => PersonDto.fromJson(Map<String, dynamic>.from(json as Map)))
          .toList();
    } catch (_) {
      return null;
    }
  }

  /// Watches the [_studios] box for a specific item.
  ///
  /// Emits the current cached value immediately, then emits updates.
  Stream<List<StudioDto>?> watchStudios(String id) {
    _assertInit();

    final controller = StreamController<List<StudioDto>?>();
    final subscription = _studios.watch(key: id).listen((event) {
      controller.add(_getStudios(id));
    });

    controller.onCancel = () => subscription.cancel();
    controller.add(_getStudios(id));

    return controller.stream;
  }

  List<StudioDto>? _getStudios(String id) {
    final raw = _studios.get(id);
    if (raw == null) return null;
    try {
      final list = List<dynamic>.from(raw as List);
      return list
          .map((json) => StudioDto.fromJson(Map<String, dynamic>.from(json as Map)))
          .toList();
    } catch (_) {
      return null;
    }
  }

  /// Watches the [_genres] box for a specific item.
  ///
  /// Emits the current cached value immediately, then emits updates.
  Stream<List<String>?> watchGenres(String id) {
    _assertInit();

    final controller = StreamController<List<String>?>();
    final subscription = _genres.watch(key: id).listen((event) {
      controller.add(_getGenres(id));
    });

    controller.onCancel = () => subscription.cancel();
    controller.add(_getGenres(id));

    return controller.stream;
  }

  List<String>? _getGenres(String id) {
    final raw = _genres.get(id);
    if (raw == null) return null;
    try {
      return List<dynamic>.from(raw as List).cast<String>();
    } catch (_) {
      return null;
    }
  }

  /// Reads a [BaseItemDto] by assembling data from all boxes.
  ///
  /// - [includeHeavyFields] controls whether people, mediaSources, etc. are fetched.
  ///   Set to `false` for list/card views (faster, less memory).
  ///   Set to `true` for detail views.
  BaseItemDto? getItem(String id, {bool includeHeavyFields = false}) {
    _assertInit();
    final coreRaw = _core.get(id);
    if (coreRaw == null) return null;
    final json = Map<String, dynamic>.from(coreRaw as Map);

    // Always merge userdata if present
    final udRaw = _userdata.get(id);
    if (udRaw != null) json['UserData'] = Map<String, dynamic>.from(udRaw as Map);

    if (includeHeavyFields) {
      final g = _genres.get(id);
      if (g != null) json['Genres'] = List<dynamic>.from(g as List);

      final s = _studios.get(id);
      if (s != null) json['Studios'] = List<dynamic>.from(s as List);

      final p = _providerIds.get(id);
      if (p != null) json['ProviderIds'] = Map<String, dynamic>.from(p as Map);

      final pe = _people.get(id);
      if (pe != null) json['People'] = List<dynamic>.from(pe as List);

      final ms = _mediaSources.get(id);
      if (ms != null) json['MediaSources'] = List<dynamic>.from(ms as List);
    }

    try {
      return BaseItemDto.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  /// Partial update for fields that change frequently
  /// (e.g. after toggling favorite, marking watched, playback progress).
  Future<void> patchUserData(String id, UserItemDataDto userData) async {
    _assertInit();
    await _putUserData(id, userData);
  }

  /// Deletes all traces of an item across every box.
  Future<void> deleteItem(String id) async {
    _assertInit();
    await Future.wait([
      _core.delete(id),
      _userdata.delete(id),
      _genres.delete(id),
      _studios.delete(id),
      _providerIds.delete(id),
      _people.delete(id),
      _mediaSources.delete(id),
    ]);
  }

  /// Checks whether the core record exists.
  bool hasItem(String id) {
    _assertInit();
    return _core.containsKey(id);
  }

  // ═══════════════════════════════════════════════════════
  //  List operations (ID-indexed)
  // ═══════════════════════════════════════════════════════

  /// Saves a list result as an ID index + metadata.
  /// The actual objects must already be in the core box (via [putItems]).
  Future<void> putList({
    required String key,
    required List<BaseItemDto> items,
    required int totalRecordCount,
    String? sortBy,
    Duration maxAge = const Duration(minutes: 5),
  }) async {
    _assertInit();
    final ids = items.map((i) => i.id).whereType<String>().toList();

    await Future.wait([
      _listIndices.put(key, ids),
      _listMeta.put(key, {
        'totalRecordCount': totalRecordCount,
        'sortBy': sortBy,
        'ts': DateTime.now().millisecondsSinceEpoch,
        'maxAgeMs': maxAge.inMilliseconds,
      }),
    ]);
  }

  /// Appends new items to an existing list index.
  /// Use this for pagination (loadMore).
  Future<void> appendList({
    required String key,
    required List<BaseItemDto> newItems,
  }) async {
    _assertInit();
    final existingRaw = _listIndices.get(key);
    final existing = existingRaw != null
        ? List<dynamic>.from(existingRaw as List).cast<String>()
        : <String>[];
    final newIds = newItems
        .map((i) => i.id)
        .whereType<String>()
        .where((id) => !existing.contains(id))
        .toList();

    if (newIds.isEmpty) return;

    await _listIndices.put(key, [...existing, ...newIds]);

    // Update metadata timestamp
    final metaRaw = _listMeta.get(key);
    final meta = metaRaw != null
        ? Map<String, dynamic>.from(metaRaw as Map)
        : <String, dynamic>{};
    meta['ts'] = DateTime.now().millisecondsSinceEpoch;
    await _listMeta.put(key, meta);
  }

  /// Reads a cached list by ID index.
  ///
  /// Returns a [QueryResult] with items assembled from the core box.
  /// Returns `null` if the list is missing, expired, or has no valid items.
  QueryResult<BaseItemDto>? getList(
    String key, {
    bool includeHeavyFields = false,
  }) {
    _assertInit();

    final metaRaw = _listMeta.get(key);
    if (metaRaw == null) return null;
    final meta = Map<String, dynamic>.from(metaRaw as Map);

    // Expiration check
    final ts = meta['ts'] as int?;
    final maxAgeMs = meta['maxAgeMs'] as int?;
    if (ts != null && maxAgeMs != null) {
      final age = DateTime.now().millisecondsSinceEpoch - ts;
      if (age > maxAgeMs) return null;
    }

    final idsRaw = _listIndices.get(key);
    if (idsRaw == null) return null;
    final ids = List<dynamic>.from(idsRaw as List).cast<String>();
    if (ids.isEmpty) return null;

    final items = <BaseItemDto>[];
    for (final id in ids) {
      final item = getItem(id, includeHeavyFields: includeHeavyFields);
      if (item != null) items.add(item);
    }

    final totalRecordCount = meta['totalRecordCount'] as int? ?? items.length;

    return QueryResult(items: items, totalRecordCount: totalRecordCount);
  }

  /// Watches a list (seasons/episodes/similarItems) for cache changes.
  ///
  /// Emits the current cached value immediately, then emits updates
  /// whenever the underlying `_listIndices` or `_listMeta` changes.
  /// Emits `null` if the list is not cached or expired.
  Stream<QueryResult<BaseItemDto>?> watchList(String key) {
    _assertInit();

    final controller = StreamController<QueryResult<BaseItemDto>?>();
    final subscriptions = <StreamSubscription<BoxEvent>>[];

    void emit() => controller.add(getList(key));

    subscriptions.addAll([
      _listIndices.watch(key: key).listen((_) => emit()),
      _listMeta.watch(key: key).listen((_) => emit()),
    ]);

    controller.onCancel = () {
      for (final sub in subscriptions) {
        sub.cancel();
      }
    };

    // Emit initial value (cached or null)
    controller.add(getList(key));

    return controller.stream;
  }

  /// Invalidates a single list (removes index + metadata).
  /// The underlying item objects remain in the core box.
  Future<void> invalidateList(String key) async {
    _assertInit();
    await Future.wait([
      _listIndices.delete(key),
      _listMeta.delete(key),
    ]);
  }

  // ═══════════════════════════════════════════════════════
  //  Internal box writers
  // ═══════════════════════════════════════════════════════

  Future<void> _putCore(String id, BaseItemDto item) async {
    final json = item.toJson();

    // Strip out fields stored in other boxes to keep core lean
    json.remove('UserData');
    json.remove('Genres');
    json.remove('Studios');
    json.remove('ProviderIds');
    json.remove('People');
    json.remove('MediaSources');

    await _core.put(id, json);
  }

  Future<void> _putUserData(String id, UserItemDataDto ud) async {
    await _userdata.put(id, ud.toJson());
  }

  Future<void> _putGenres(String id, List<String> genres) async {
    await _genres.put(id, genres);
  }

  Future<void> _putStudios(String id, List<StudioDto> studios) async {
    await _studios.put(id, studios.map((s) => s.toJson()).toList());
  }

  Future<void> _putProviderIds(
    String id,
    Map<String, String> providerIds,
  ) async {
    await _providerIds.put(id, providerIds);
  }

  Future<void> _putPeople(String id, List<PersonDto> people) async {
    await _people.put(id, people.map((p) => p.toJson()).toList());
  }

  Future<void> _putMediaSources(
    String id,
    List<MediaSourceInfo> sources,
  ) async {
    // MediaSourceInfo.toJson() 生成的代码没有递归调用 MediaStream.toJson()，
    // 导致 Hive 遇到 _MediaStream 对象时抛出 unknown type 错误。
    // 使用 jsonEncode + jsonDecode 强制完整序列化后再存入 Hive。
    final jsonList = sources.map((s) => jsonDecode(jsonEncode(s)) as Map<String, dynamic>).toList();
    await _mediaSources.put(id, jsonList);
  }

  // ═══════════════════════════════════════════════════════
  //  Maintenance
  // ═══════════════════════════════════════════════════════

  /// Returns approximate total entries across all boxes.
  Map<String, int> stats() {
    _assertInit();
    return {
      'core': _core.length,
      'userdata': _userdata.length,
      'genres': _genres.length,
      'studios': _studios.length,
      'providerIds': _providerIds.length,
      'people': _people.length,
      'mediaSources': _mediaSources.length,
      'listIndices': _listIndices.length,
      'listMeta': _listMeta.length,
    };
  }

  /// Clears everything. Use with caution.
  Future<void> clearAll() async {
    _assertInit();
    await Future.wait([
      _core.clear(),
      _userdata.clear(),
      _genres.clear(),
      _studios.clear(),
      _providerIds.clear(),
      _people.clear(),
      _mediaSources.clear(),
      _listIndices.clear(),
      _listMeta.clear(),
    ]);
  }

  /// Closes all boxes. Call on app termination if needed.
  Future<void> dispose() async {
    _assertInit();
    await Future.wait([
      _core.close(),
      _userdata.close(),
      _genres.close(),
      _studios.close(),
      _providerIds.close(),
      _people.close(),
      _mediaSources.close(),
      _listIndices.close(),
      _listMeta.close(),
    ]);
    _initialized = false;
  }
}

// ═══════════════════════════════════════════════════════
//  Riverpod Provider
// ═══════════════════════════════════════════════════════

/// Provider for the [EmbyCache] instance.
///
/// Must be overridden in [ProviderScope] with an initialized instance:
/// ```dart
/// final cache = EmbyCache();
/// await cache.init();
/// runApp(ProviderScope(
///   overrides: [embyCacheProvider.overrideWithValue(cache)],
///   child: const MyApp(),
/// ));
/// ```
final embyCacheProvider = Provider<EmbyCache>((ref) {
  throw UnimplementedError(
    'embyCacheProvider must be overridden with an initialized EmbyCache instance',
  );
});
