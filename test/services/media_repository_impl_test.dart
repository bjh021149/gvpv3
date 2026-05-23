import 'dart:io';

import 'package:emby_client/core/api/emby_api_service.dart';
import 'package:emby_client/core/models/base_item_dto.dart';
import 'package:emby_client/core/models/playback_info.dart';
import 'package:emby_client/core/models/query_result.dart';
import 'package:emby_client/services/cache/emby_cache.dart';
import 'package:emby_client/services/repositories/media_repository.dart';
import 'package:emby_client/services/repositories/media_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:mocktail/mocktail.dart';

class MockEmbyApiService extends Mock implements EmbyApiService {}

BaseItemDto _testItem(String id) => BaseItemDto(
      id: id,
      name: 'Item $id',
      type: 'Movie',
      overview: 'Overview $id',
    );

QueryResult<BaseItemDto> _testListResult(List<String> ids, {int? total}) {
  return QueryResult(
    items: ids.map(_testItem).toList(),
    totalRecordCount: total ?? ids.length,
  );
}

/// Helper to verify [api.getItems] was called [count] times with any arguments.
void _verifyGetItems(MockEmbyApiService api, int count) {
  verify(
    () => api.getItems(
      parentId: any(named: 'parentId'),
      includeItemTypes: any(named: 'includeItemTypes'),
      sortBy: any(named: 'sortBy'),
      sortOrder: any(named: 'sortOrder'),
      startIndex: any(named: 'startIndex'),
      limit: any(named: 'limit'),
      searchTerm: any(named: 'searchTerm'),
      filters: any(named: 'filters'),
      recursive: any(named: 'recursive'),
      fields: any(named: 'fields'),
      imageTypeLimit: any(named: 'imageTypeLimit'),
      enableImageTypes: any(named: 'enableImageTypes'),
    ),
  ).called(count);
}

void main() {
  late Directory tempDir;
  late EmbyCache cache;
  late MockEmbyApiService api;
  late MediaRepository repository;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_repo_test_');
    Hive.init(tempDir.path);
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  setUp(() async {
    cache = EmbyCache();
    await cache.init();
    api = MockEmbyApiService();
    repository = MediaRepositoryImpl(api, cache);
  });

  tearDown(() async {
    await cache.clearAll();
    await cache.dispose();
  });

  group('MediaRepositoryImpl cache-first behavior', () {
    test('getItems: first call hits API, second call hits cache', () async {
      const parentId = 'lib-123';
      final apiResult = _testListResult(const ['a', 'b', 'c'], total: 99);

      when(() => api.getItems(
            parentId: any(named: 'parentId'),
            includeItemTypes: any(named: 'includeItemTypes'),
            sortBy: any(named: 'sortBy'),
            sortOrder: any(named: 'sortOrder'),
            startIndex: any(named: 'startIndex'),
            limit: any(named: 'limit'),
            searchTerm: any(named: 'searchTerm'),
            filters: any(named: 'filters'),
            recursive: any(named: 'recursive'),
            fields: any(named: 'fields'),
            imageTypeLimit: any(named: 'imageTypeLimit'),
            enableImageTypes: any(named: 'enableImageTypes'),
          )).thenAnswer((_) async => apiResult);

      // First call → API
      final r1 = await repository.getItems(parentId: parentId);
      expect(r1.items, hasLength(3));

      // Second call → Cache (no additional API call)
      final r2 = await repository.getItems(parentId: parentId);
      expect(r2.items, hasLength(3));
      expect(r2.totalRecordCount, equals(99));

      // Verify API was called exactly once
      _verifyGetItems(api, 1);
    });

    test('getItems with different pagination uses different cache keys',
        () async {
      const parentId = 'lib-456';
      final page0 = _testListResult(const ['p0-a', 'p0-b'], total: 4);
      final page1 = _testListResult(const ['p1-a', 'p1-b'], total: 4);

      when(() => api.getItems(
            parentId: any(named: 'parentId'),
            startIndex: any(named: 'startIndex'),
            limit: any(named: 'limit'),
            includeItemTypes: any(named: 'includeItemTypes'),
            sortBy: any(named: 'sortBy'),
            sortOrder: any(named: 'sortOrder'),
            searchTerm: any(named: 'searchTerm'),
            filters: any(named: 'filters'),
            recursive: any(named: 'recursive'),
            fields: any(named: 'fields'),
            imageTypeLimit: any(named: 'imageTypeLimit'),
            enableImageTypes: any(named: 'enableImageTypes'),
          )).thenAnswer((invocation) async {
        final startIndex =
            invocation.namedArguments[const Symbol('startIndex')] as int? ?? 0;
        return startIndex == 0 ? page0 : page1;
      });

      // Fetch page 0
      final r0 = await repository.getItems(
        parentId: parentId,
        startIndex: 0,
        limit: 2,
      );
      expect(r0.items.first.id, equals('p0-a'));

      // Fetch page 1
      final r1 = await repository.getItems(
        parentId: parentId,
        startIndex: 2,
        limit: 2,
      );
      expect(r1.items.first.id, equals('p1-a'));

      // Re-fetch both pages → cache hit
      final r0c = await repository.getItems(
        parentId: parentId,
        startIndex: 0,
        limit: 2,
      );
      final r1c = await repository.getItems(
        parentId: parentId,
        startIndex: 2,
        limit: 2,
      );
      expect(r0c.items.first.id, equals('p0-a'));
      expect(r1c.items.first.id, equals('p1-a'));

      // Verify exactly 2 API calls total
      _verifyGetItems(api, 2);
    });

    test('getItemDetail: first call hits API, second hits cache', () async {
      const itemId = 'detail-99';
      final apiItem = _testItem(itemId).copyWith(
        genres: const ['动作'],
        studios: const [StudioDto(id: 1, name: 'Studio A')],
      );

      when(() => api.getItemDetail(itemId, fields: any(named: 'fields')))
          .thenAnswer((_) async => apiItem);

      // First call
      final d1 = await repository.getItemDetail(itemId);
      expect(d1.id, equals(itemId));

      // Second call → cache
      final d2 = await repository.getItemDetail(itemId);
      expect(d2.id, equals(itemId));
      expect(d2.genres, equals(const ['动作']));

      verify(() => api.getItemDetail(itemId, fields: any(named: 'fields'))).called(1);
    });

    test('getPlaybackInfo never hits cache', () async {
      const itemId = 'play-1';
      const info = PlaybackInfo();

      when(() => api.getPlaybackInfo(itemId))
          .thenAnswer((_) async => info);

      // Two calls → both hit API
      await repository.getPlaybackInfo(itemId);
      await repository.getPlaybackInfo(itemId);

      verify(() => api.getPlaybackInfo(itemId)).called(2);
    });

    test('getViews caches and returns on second call', () async {
      final result = _testListResult(const ['v1', 'v2'], total: 2);

      when(() => api.getViews()).thenAnswer((_) async => result);

      await repository.getViews();
      await repository.getViews();

      verify(() => api.getViews()).called(1);
    });

    test('getResumableMovies uses short maxAge', () async {
      final result = _testListResult(const ['m1'], total: 1);

      when(() => api.getResumableMovies(limit: any(named: 'limit')))
          .thenAnswer((_) async => result);

      await repository.getResumableMovies();
      // Immediately call again → cache hit (30s default)
      await repository.getResumableMovies();

      verify(() => api.getResumableMovies(limit: any(named: 'limit')))
          .called(1);
    });
  });

  group('MediaRepositoryImpl cache expiration', () {
    test('expired list falls back to API', () async {
      const parentId = 'exp-lib';
      final initial = _testListResult(const ['old-1'], total: 1);
      final refreshed = _testListResult(const ['new-1', 'new-2'], total: 2);

      // Manually seed cache with zero maxAge (already expired)
      await cache.putItems(initial.items);
      await cache.putList(
        key: 'items|${parentId}|_|0|50',
        items: initial.items,
        totalRecordCount: 1,
        maxAge: Duration.zero,
      );

      when(() => api.getItems(
            parentId: any(named: 'parentId'),
            includeItemTypes: any(named: 'includeItemTypes'),
            sortBy: any(named: 'sortBy'),
            sortOrder: any(named: 'sortOrder'),
            startIndex: any(named: 'startIndex'),
            limit: any(named: 'limit'),
            searchTerm: any(named: 'searchTerm'),
            filters: any(named: 'filters'),
            recursive: any(named: 'recursive'),
            fields: any(named: 'fields'),
            imageTypeLimit: any(named: 'imageTypeLimit'),
            enableImageTypes: any(named: 'enableImageTypes'),
          )).thenAnswer((_) async => refreshed);

      await Future.delayed(const Duration(milliseconds: 10));

      final r = await repository.getItems(parentId: parentId);
      expect(r.items, hasLength(2)); // got refreshed data

      _verifyGetItems(api, 1);
    });
  });
}
