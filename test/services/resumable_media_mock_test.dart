import 'package:dio/dio.dart';
import 'package:emby_client/core/api/emby_api_service.dart';
import 'package:emby_client/core/models/base_item_dto.dart';
import 'package:emby_client/services/cache/emby_cache.dart';
import 'package:emby_client/services/repositories/media_repository_impl.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

class MockEmbyCache extends Mock implements EmbyCache {}

class FakeRequestOptions extends Fake implements RequestOptions {}

class FakeBaseItemDto extends Fake implements BaseItemDto {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeRequestOptions());
    registerFallbackValue(FakeBaseItemDto());
    registerFallbackValue(Duration.zero);
  });

  group('EmbyApiService.getResumableMovies (mocked Dio)', () {
    late MockDio mockDio;
    late EmbyApiService apiService;

    setUp(() {
      mockDio = MockDio();
      apiService = EmbyApiService(dio: mockDio, userId: 'test-user-123');
    });

    test('returns movies with correct query parameters', () async {
      debugPrint('[TEST] ===== getResumableMovies mock test =====');

      final mockResponse = Response<Map<String, dynamic>>(
        data: {
          'Items': [
            {
              'Id': 'movie-1',
              'Name': 'Test Movie 1',
              'Type': 'Movie',
              'ProductionYear': 2024,
              'UserData': {
                'PlaybackPositionTicks': 18000000000,
                'PlayedPercentage': 45.5,
              },
            },
            {
              'Id': 'movie-2',
              'Name': 'Test Movie 2',
              'Type': 'Movie',
              'ProductionYear': 2023,
              'UserData': {
                'PlaybackPositionTicks': 9000000000,
                'PlayedPercentage': 22.3,
              },
            },
          ],
          'TotalRecordCount': 2,
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: '/Users/test-user-123/Items'),
      );

      when(() => mockDio.get<Map<String, dynamic>>(
        any(),
        queryParameters: any(named: 'queryParameters'),
      )).thenAnswer((_) async => mockResponse);

      debugPrint('[TEST] Calling getResumableMovies(limit: 10)...');
      final result = await apiService.getResumableMovies(limit: 10);

      debugPrint('[TEST] TotalRecordCount: ${result.totalRecordCount}');
      debugPrint('[TEST] Items count: ${result.items.length}');

      for (var i = 0; i < result.items.length; i++) {
        final item = result.items[i];
        debugPrint('[TEST] --- Movie #$i ---');
        debugPrint('[TEST]   Id: ${item.id}');
        debugPrint('[TEST]   Name: ${item.name}');
        debugPrint('[TEST]   Type: ${item.type}');
        debugPrint('[TEST]   playedPercentage: ${item.userData?.playedPercentage}');
      }

      // Assert
      expect(result.items.length, equals(2));
      expect(result.totalRecordCount, equals(2));
      expect(result.items[0].type, equals('Movie'));
      expect(result.items[0].name, equals('Test Movie 1'));
      expect(result.items[0].userData?.playedPercentage, equals(45.5));

      // Verify correct endpoint and query params were used
      final captured = verify(() => mockDio.get<Map<String, dynamic>>(
        any(),
        queryParameters: captureAny(named: 'queryParameters'),
      )).captured.single as Map<String, dynamic>;

      debugPrint('[TEST] Captured queryParameters: $captured');
      expect(captured['Filters'], equals('IsResumable'));
      expect(captured['IncludeItemTypes'], equals('Movie'));
      expect(captured['Recursive'], equals(true));
      expect(captured['Limit'], equals(10));
      expect(captured['SortBy'], equals('DatePlayed'));

      debugPrint('[TEST] ===== getResumableMovies mock test 完成 =====');
    });

    test('returns empty list when no resumable movies', () async {
      debugPrint('[TEST] ===== getResumableMovies empty test =====');

      final mockResponse = Response<Map<String, dynamic>>(
        data: {
          'Items': [],
          'TotalRecordCount': 0,
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: '/Users/test-user-123/Items'),
      );

      when(() => mockDio.get<Map<String, dynamic>>(
        any(),
        queryParameters: any(named: 'queryParameters'),
      )).thenAnswer((_) async => mockResponse);

      final result = await apiService.getResumableMovies(limit: 10);

      debugPrint('[TEST] Items count: ${result.items.length}');
      expect(result.items, isEmpty);
      expect(result.totalRecordCount, equals(0));

      debugPrint('[TEST] ===== getResumableMovies empty test 完成 =====');
    });

    test('throws on DioException', () async {
      debugPrint('[TEST] ===== getResumableMovies error test =====');

      when(() => mockDio.get<Map<String, dynamic>>(
        any(),
        queryParameters: any(named: 'queryParameters'),
      )).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/Users/test-user-123/Items'),
        response: Response(
          statusCode: 500,
          requestOptions: RequestOptions(path: '/Users/test-user-123/Items'),
        ),
        type: DioExceptionType.badResponse,
      ));

      debugPrint('[TEST] Expecting DioException...');
      expect(
        () => apiService.getResumableMovies(limit: 10),
        throwsA(isA<DioException>()),
      );

      debugPrint('[TEST] ===== getResumableMovies error test 完成 =====');
    });
  });

  group('EmbyApiService.getResumableSeries (mocked Dio)', () {
    late MockDio mockDio;
    late EmbyApiService apiService;

    setUp(() {
      mockDio = MockDio();
      apiService = EmbyApiService(dio: mockDio, userId: 'test-user-123');
    });

    test('returns series deduplicated from episodes', () async {
      debugPrint('[TEST] ===== getResumableSeries mock test =====');

      // getResumableSeries 内部先请求 Episode，然后去重构造 Series
      final mockResponse = Response<Map<String, dynamic>>(
        data: {
          'Items': [
            {
              'Id': 'ep-1',
              'Name': 'Episode 1',
              'Type': 'Episode',
              'SeriesId': 'series-1',
              'SeriesName': 'Test Series 1',
              'UserData': {
                'PlaybackPositionTicks': 36000000000,
                'PlayedPercentage': 67.8,
              },
            },
            {
              'Id': 'ep-2',
              'Name': 'Episode 2',
              'Type': 'Episode',
              'SeriesId': 'series-1', // 同一系列，应该被去重
              'SeriesName': 'Test Series 1',
              'UserData': {
                'PlaybackPositionTicks': 18000000000,
                'PlayedPercentage': 33.5,
              },
            },
            {
              'Id': 'ep-3',
              'Name': 'Episode 1',
              'Type': 'Episode',
              'SeriesId': 'series-2',
              'SeriesName': 'Test Series 2',
              'UserData': {
                'PlaybackPositionTicks': 9000000000,
                'PlayedPercentage': 15.2,
              },
            },
          ],
          'TotalRecordCount': 3,
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: '/Users/test-user-123/Items'),
      );

      when(() => mockDio.get<Map<String, dynamic>>(
        any(),
        queryParameters: any(named: 'queryParameters'),
      )).thenAnswer((_) async => mockResponse);

      debugPrint('[TEST] Calling getResumableSeries(limit: 5)...');
      final result = await apiService.getResumableSeries(limit: 5);

      debugPrint('[TEST] TotalRecordCount: ${result.totalRecordCount}');
      debugPrint('[TEST] Items count: ${result.items.length}');

      for (var i = 0; i < result.items.length; i++) {
        final item = result.items[i];
        debugPrint('[TEST] --- Series #$i ---');
        debugPrint('[TEST]   Id: ${item.id}');
        debugPrint('[TEST]   Name: ${item.name}');
        debugPrint('[TEST]   Type: ${item.type}');
        debugPrint('[TEST]   seriesId: ${item.seriesId}');
      }

      // 断言：3 个 Episode 来自 2 个不同的 Series，去重后应为 2 个
      expect(result.items.length, equals(2));
      expect(result.items[0].type, equals('Series'));
      expect(result.items[0].id, equals('series-1'));
      expect(result.items[0].name, equals('Test Series 1'));
      expect(result.items[1].id, equals('series-2'));
      expect(result.items[1].name, equals('Test Series 2'));

      final captured = verify(() => mockDio.get<Map<String, dynamic>>(
        any(),
        queryParameters: captureAny(named: 'queryParameters'),
      )).captured.single as Map<String, dynamic>;

      debugPrint('[TEST] Captured queryParameters: $captured');
      expect(captured['Filters'], equals('IsResumable'));
      expect(captured['IncludeItemTypes'], equals('Episode'));
      expect(captured['Recursive'], equals(true));

      debugPrint('[TEST] ===== getResumableSeries mock test 完成 =====');
    });
  });

  group('MediaRepositoryImpl resumable methods', () {
    late MockDio mockDio;
    late MediaRepositoryImpl repository;

    setUp(() {
      mockDio = MockDio();
      final apiService = EmbyApiService(dio: mockDio, userId: 'test-user-123');
      final cache = MockEmbyCache();
      // Stub Future<void> methods to avoid null-safety runtime errors
      when(() => cache.putItems(any())).thenAnswer((_) async {});
      when(() => cache.putItem(any())).thenAnswer((_) async {});
      when(() => cache.putList(
            key: any(named: 'key'),
            items: any(named: 'items'),
            totalRecordCount: any(named: 'totalRecordCount'),
            sortBy: any(named: 'sortBy'),
            maxAge: any(named: 'maxAge'),
          )).thenAnswer((_) async {});
      repository = MediaRepositoryImpl(apiService, cache);
    });

    test('getResumableMovies delegates to apiService', () async {
      debugPrint('[TEST] ===== MediaRepositoryImpl.getResumableMovies =====');

      final mockResponse = Response<Map<String, dynamic>>(
        data: {
          'Items': [
            {'Id': 'm1', 'Name': 'Movie A', 'Type': 'Movie'},
          ],
          'TotalRecordCount': 1,
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: '/Users/test-user-123/Items'),
      );

      when(() => mockDio.get<Map<String, dynamic>>(
        any(),
        queryParameters: any(named: 'queryParameters'),
      )).thenAnswer((_) async => mockResponse);

      final result = await repository.getResumableMovies(limit: 10);

      debugPrint('[TEST] Repository returned ${result.items.length} items');
      expect(result.items.length, equals(1));
      expect(result.items[0].name, equals('Movie A'));

      debugPrint('[TEST] ===== MediaRepositoryImpl.getResumableMovies 完成 =====');
    });

    test('getResumableSeries delegates to apiService', () async {
      debugPrint('[TEST] ===== MediaRepositoryImpl.getResumableSeries =====');

      // getResumableSeries 内部请求 Episode 然后去重
      final mockResponse = Response<Map<String, dynamic>>(
        data: {
          'Items': [
            {
              'Id': 'ep-1',
              'Name': 'Ep 1',
              'Type': 'Episode',
              'SeriesId': 's1',
              'SeriesName': 'Series B',
            },
          ],
          'TotalRecordCount': 1,
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: '/Users/test-user-123/Items'),
      );

      when(() => mockDio.get<Map<String, dynamic>>(
        any(),
        queryParameters: any(named: 'queryParameters'),
      )).thenAnswer((_) async => mockResponse);

      final result = await repository.getResumableSeries(limit: 10);

      debugPrint('[TEST] Repository returned ${result.items.length} items');
      expect(result.items.length, equals(1));
      expect(result.items[0].name, equals('Series B'));
      expect(result.items[0].type, equals('Series'));

      debugPrint('[TEST] ===== MediaRepositoryImpl.getResumableSeries 完成 =====');
    });

    test('getMovieRecommendations delegates to apiService', () async {
      debugPrint('[TEST] ===== MediaRepositoryImpl.getMovieRecommendations =====');

      final mockResponse = Response<List<dynamic>>(
        data: [
          {
            'Items': [
              {'Id': 'rec-1', 'Name': '推荐电影 A', 'Type': 'Movie', 'ProductionYear': 2024},
              {'Id': 'rec-2', 'Name': '推荐电影 B', 'Type': 'Movie', 'ProductionYear': 2023},
            ],
            'RecommendationType': 'BecauseYouWatched',
            'BaselineItemName': '某电影',
          },
          {
            'Items': [
              {'Id': 'rec-3', 'Name': '推荐电影 C', 'Type': 'Movie'},
              {'Id': 'rec-1', 'Name': '推荐电影 A', 'Type': 'Movie'}, // 重复，应被去重
            ],
            'RecommendationType': 'SimilarToRecentlyPlayed',
          },
        ],
        statusCode: 200,
        requestOptions: RequestOptions(path: '/Movies/Recommendations'),
      );

      when(() => mockDio.get<List<dynamic>>(
        any(),
        queryParameters: any(named: 'queryParameters'),
      )).thenAnswer((_) async => mockResponse);

      final result = await repository.getMovieRecommendations(
        itemLimit: 10,
        categoryLimit: 3,
      );

      debugPrint('[TEST] Repository returned ${result.items.length} items');
      // 2 + 2 个，但 rec-1 重复，去重后应为 3
      expect(result.items.length, equals(3));
      expect(result.items[0].name, equals('推荐电影 A'));
      expect(result.items[1].name, equals('推荐电影 B'));
      expect(result.items[2].name, equals('推荐电影 C'));

      final captured = verify(() => mockDio.get<List<dynamic>>(
        any(),
        queryParameters: captureAny(named: 'queryParameters'),
      )).captured.single as Map<String, dynamic>;

      debugPrint('[TEST] Captured queryParameters: $captured');
      expect(captured['ItemLimit'], equals(10));
      expect(captured['CategoryLimit'], equals(3));
      expect(captured['UserId'], equals('test-user-123'));

      debugPrint('[TEST] ===== MediaRepositoryImpl.getMovieRecommendations 完成 =====');
    });

    test('getChildren delegates to apiService with correct params', () async {
      debugPrint('[TEST] ===== MediaRepositoryImpl.getChildren =====');

      final mockResponse = Response<Map<String, dynamic>>(
        data: {
          'Items': [
            {'Id': 'child-1', 'Name': 'Child Movie', 'Type': 'Movie', 'IsFolder': false},
            {'Id': 'child-2', 'Name': 'Child Series', 'Type': 'Series', 'IsFolder': false},
          ],
          'TotalRecordCount': 2,
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: '/Users/test-user-123/Items'),
      );

      when(() => mockDio.get<Map<String, dynamic>>(
        any(),
        queryParameters: any(named: 'queryParameters'),
      )).thenAnswer((_) async => mockResponse);

      final result = await repository.getChildren(
        'folder-123',
        includeItemTypes: 'Movie,Series',
        recursive: true,
        limit: 20,
      );

      debugPrint('[TEST] Repository returned ${result.items.length} items');
      expect(result.items.length, equals(2));

      final captured = verify(() => mockDio.get<Map<String, dynamic>>(
        any(),
        queryParameters: captureAny(named: 'queryParameters'),
      )).captured.single as Map<String, dynamic>;

      debugPrint('[TEST] Captured queryParameters: $captured');
      expect(captured['ParentId'], equals('folder-123'));
      expect(captured['IncludeItemTypes'], equals('Movie,Series'));
      expect(captured['Recursive'], equals(true));

      debugPrint('[TEST] ===== MediaRepositoryImpl.getChildren 完成 =====');
    });
  });
}
