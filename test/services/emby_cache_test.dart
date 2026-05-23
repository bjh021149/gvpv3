import 'dart:io';

import 'package:emby_client/core/models/base_item_dto.dart';
import 'package:emby_client/core/models/query_result.dart';
import 'package:emby_client/core/models/user_item_data.dart';
import 'package:emby_client/services/cache/emby_cache.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

/// 构建一个完整的 [BaseItemDto] 用于测试 round-trip。
BaseItemDto _makeTestItem({
  required String id,
  String? name,
  String? type,
  List<String>? genres,
  Map<String, String>? providerIds,
  List<StudioDto>? studios,
  List<PersonDto>? people,
  UserItemDataDto? userData,
}) {
  return BaseItemDto(
    id: id,
    name: name ?? 'Test Item $id',
    type: type ?? 'Movie',
    overview: 'Overview for $id',
    productionYear: 2024,
    runTimeTicks: 600000000,
    genres: genres,
    providerIds: providerIds,
    studios: studios,
    people: people ?? const [],
    userData: userData,
    imageTags: {'Primary': 'tag-$id'},
  );
}

void main() {
  late Directory tempDir;
  late EmbyCache cache;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_test_');
    Hive.init(tempDir.path);
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  setUp(() async {
    cache = EmbyCache();
    await cache.init();
  });

  tearDown(() async {
    await cache.clearAll();
    await cache.dispose();
  });

  group('EmbyCache single-item operations', () {
    test('putItem + getItem round-trip preserves all fields', () async {
      final item = _makeTestItem(
        id: '1001',
        genres: const ['科幻', '动作'],
        providerIds: const {'Imdb': 'tt1001', 'Tmdb': '1001'},
        studios: const [StudioDto(id: 1, name: 'Marvel Studios')],
        people: const [
          PersonDto(id: 'p1', name: 'Tom Holland', type: 'Actor'),
        ],
        userData: const UserItemDataDto(
          playedPercentage: 45.5,
          isFavorite: true,
        ),
      );

      await cache.putItem(item);

      // Light read: should NOT include heavy fields
      final light = cache.getItem('1001', includeHeavyFields: false);
      expect(light, isNotNull);
      expect(light!.id, equals('1001'));
      expect(light.name, equals('Test Item 1001'));
      expect(light.genres, isNull);
      expect(light.studios, isNull);
      expect(light.people, isEmpty);
      expect(light.userData, isNotNull);
      expect(light.userData!.playedPercentage, equals(45.5));
      expect(light.userData!.isFavorite, isTrue);

      // Heavy read: should include all fields
      final heavy = cache.getItem('1001', includeHeavyFields: true);
      expect(heavy, isNotNull);
      expect(heavy!.genres, equals(const ['科幻', '动作']));
      expect(heavy.providerIds, equals(const {'Imdb': 'tt1001', 'Tmdb': '1001'}));
      expect(heavy.studios, hasLength(1));
      expect(heavy.studios!.first.name, equals('Marvel Studios'));
      expect(heavy.people, hasLength(1));
      expect(heavy.people.first.name, equals('Tom Holland'));
    });

    test('getItem returns null for missing id', () {
      expect(cache.getItem('non-existent'), isNull);
    });

    test('hasItem reflects existence correctly', () async {
      expect(cache.hasItem('2001'), isFalse);
      await cache.putItem(_makeTestItem(id: '2001'));
      expect(cache.hasItem('2001'), isTrue);
    });

    test('deleteItem removes from all boxes', () async {
      await cache.putItem(_makeTestItem(
        id: '3001',
        genres: const ['剧情'],
        userData: const UserItemDataDto(played: true),
      ));

      expect(cache.hasItem('3001'), isTrue);

      await cache.deleteItem('3001');

      expect(cache.hasItem('3001'), isFalse);
      expect(cache.getItem('3001'), isNull);
    });

    test('patchUserData updates only userdata box', () async {
      await cache.putItem(_makeTestItem(
        id: '4001',
        userData: const UserItemDataDto(playedPercentage: 10.0),
      ));

      await cache.patchUserData(
        '4001',
        const UserItemDataDto(playedPercentage: 88.0, isFavorite: true),
      );

      final item = cache.getItem('4001', includeHeavyFields: false);
      expect(item!.userData!.playedPercentage, equals(88.0));
      expect(item.userData!.isFavorite, isTrue);
    });
  });

  group('EmbyCache list operations', () {
    test('putList + getList round-trip', () async {
      final items = [
        _makeTestItem(id: 'list-1', name: 'Alpha'),
        _makeTestItem(id: 'list-2', name: 'Beta'),
        _makeTestItem(id: 'list-3', name: 'Gamma'),
      ];

      await cache.putItems(items);
      await cache.putList(
        key: 'test_list',
        items: items,
        totalRecordCount: 100,
      );

      final result = cache.getList('test_list', includeHeavyFields: false);
      expect(result, isNotNull);
      expect(result!.items, hasLength(3));
      expect(result.totalRecordCount, equals(100));
      expect(result.items.map((i) => i.id).toList(),
          equals(const ['list-1', 'list-2', 'list-3']));
    });

    test('getList returns null when expired', () async {
      final items = [_makeTestItem(id: 'exp-1')];

      await cache.putItems(items);
      await cache.putList(
        key: 'expired_list',
        items: items,
        totalRecordCount: 1,
        maxAge: Duration.zero, // 立即过期
      );

      // 由于 Hive 写入是异步的，但 Dart 中 await 后已经写入完成
      // 不过时间精度问题可能导致刚好未过期，所以用负的 maxAge 不太可能
      // 更可靠的方式：等待一小段时间
      await Future.delayed(const Duration(milliseconds: 10));

      final result = cache.getList('expired_list');
      expect(result, isNull);
    });

    test('getList returns null for missing key', () {
      expect(cache.getList('no-such-key'), isNull);
    });

    test('appendList deduplicates and preserves order', () async {
      final initial = [
        _makeTestItem(id: 'a-1'),
        _makeTestItem(id: 'a-2'),
      ];
      final append = [
        _makeTestItem(id: 'a-2'), // duplicate
        _makeTestItem(id: 'a-3'),
      ];

      await cache.putItems([...initial, ...append]);
      await cache.putList(
        key: 'append_test',
        items: initial,
        totalRecordCount: 10,
      );

      await cache.appendList(key: 'append_test', newItems: append);

      final result = cache.getList('append_test');
      expect(result, isNotNull);
      expect(result!.items, hasLength(3));
      expect(result.items.map((i) => i.id).toList(),
          equals(const ['a-1', 'a-2', 'a-3']));
    });

    test('invalidateList removes index but keeps items', () async {
      final item = _makeTestItem(id: 'inv-1');
      await cache.putItem(item);
      await cache.putList(
        key: 'inv_list',
        items: [item],
        totalRecordCount: 1,
      );

      expect(cache.getList('inv_list'), isNotNull);

      await cache.invalidateList('inv_list');

      expect(cache.getList('inv_list'), isNull);
      // item 对象本身还在 core box
      expect(cache.getItem('inv-1'), isNotNull);
    });
  });

  group('EmbyCache maintenance', () {
    test('stats returns zero for empty cache', () {
      final stats = cache.stats();
      expect(stats['core'], equals(0));
      expect(stats['listIndices'], equals(0));
    });

    test('stats reflects entries after put', () async {
      await cache.putItem(_makeTestItem(id: 'stat-1'));
      await cache.putList(
        key: 'stat_list',
        items: [_makeTestItem(id: 'stat-1')],
        totalRecordCount: 1,
      );

      final stats = cache.stats();
      expect(stats['core'], equals(1));
      expect(stats['listIndices'], equals(1));
      expect(stats['listMeta'], equals(1));
    });

    test('clearAll empties all boxes', () async {
      await cache.putItem(_makeTestItem(id: 'clr-1'));
      await cache.putList(
        key: 'clr_list',
        items: [_makeTestItem(id: 'clr-1')],
        totalRecordCount: 1,
      );

      await cache.clearAll();

      expect(cache.getItem('clr-1'), isNull);
      expect(cache.getList('clr_list'), isNull);
      final stats = cache.stats();
      for (final count in stats.values) {
        expect(count, equals(0));
      }
    });
  });

  group('EmbyCache edge cases', () {
    test('putItem with null id is silently ignored', () async {
      final item = _makeTestItem(id: '');
      await cache.putItem(item);
      expect(cache.hasItem(''), isFalse);
    });

    test('getItem assembles item missing from core box', () async {
      // Only put userdata, no core
      await cache.patchUserData('orphan',
          const UserItemDataDto(playedPercentage: 50.0));

      // getItem should return null because core is missing
      expect(cache.getItem('orphan'), isNull);
    });

    test('list with partial missing items returns available ones', () async {
      final items = [
        _makeTestItem(id: 'partial-1'),
        _makeTestItem(id: 'partial-2'),
      ];

      await cache.putItem(items[0]); // only put first item
      await cache.putList(
        key: 'partial_list',
        items: items, // index references both
        totalRecordCount: 2,
      );

      final result = cache.getList('partial_list');
      expect(result, isNotNull);
      expect(result!.items, hasLength(1));
      expect(result.items.first.id, equals('partial-1'));
      expect(result.totalRecordCount, equals(2));
    });
  });
}
