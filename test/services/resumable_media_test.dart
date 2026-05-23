import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:emby_client/core/api/emby_api_service.dart';
import 'package:emby_client/core/models/base_item_dto.dart';
import 'package:emby_client/core/models/query_result.dart';
import 'package:emby_client/services/repositories/auth_repository_impl.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/auth_info_decryptor.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

/// 真实服务器集成测试：Continue Watching 数据获取
///
/// 认证信息从加密的 `test/authInfo.txt.enc` 自动解密加载。
///
/// 运行方式：flutter test test/services/resumable_media_test.dart --no-pub
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late final String testServerUrl;
  late final String testUsername;
  late final String testPassword;

  late String accessToken;
  late String userId;
  late Dio dio;
  late EmbyApiService apiService;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});

    // 恢复真实网络请求能力（TestWidgetsFlutterBinding 默认会拦截 HTTP）
    HttpOverrides.global = null;

    // ========== 自动解密加载认证信息 ==========
    debugPrint('[TEST] ===== 正在解密认证信息 =====');
    final authInfo = await AuthInfoDecryptor.load();
    testServerUrl = authInfo.serverUrl;
    testUsername = authInfo.username;
    testPassword = authInfo.password;
    debugPrint('[TEST] 认证信息加载成功: $authInfo');
    debugPrint('[TEST] ============================');

    debugPrint('[TEST] ===== 开始认证 =====');
    debugPrint('[TEST] Server: $testServerUrl');
    debugPrint('[TEST] Username: $testUsername');

    // Mock SecureStorage 避免插件未注册
    final mockStorage = MockFlutterSecureStorage();
    when(() => mockStorage.write(
      key: any(named: 'key'),
      value: any(named: 'value'),
    )).thenAnswer((_) async {});
    when(() => mockStorage.read(
      key: any(named: 'key'),
    )).thenAnswer((_) async => null);
    when(() => mockStorage.delete(
      key: any(named: 'key'),
    )).thenAnswer((_) async {});

    // 使用 AuthRepositoryImpl.authenticate() 进行认证
    final authRepo = AuthRepositoryImpl(secureStorage: mockStorage);
    final authResult = await authRepo.authenticate(
      testServerUrl,
      testUsername,
      testPassword,
    );

    accessToken = authResult.accessToken!;
    userId = authResult.user!.id!;

    debugPrint('[TEST] 认证成功!');
    debugPrint('[TEST] AccessToken: $accessToken');
    debugPrint('[TEST] UserId: $userId');
    debugPrint('[TEST] ====================');

    // 创建用于 API 请求的 Dio 实例
    dio = Dio(BaseOptions(
      baseUrl: testServerUrl,
      headers: {
        'Accept': 'application/json',
        'X-Emby-Token': accessToken,
      },
    ));

    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      },
    );

    apiService = EmbyApiService(dio: dio, userId: userId);
  });

  group('Continue Watching - Real Server', () {
    test('getResumableMovies returns movies with IsResumable filter', () async {
      debugPrint('[TEST] ===== getResumableMovies =====');

      final QueryResult<BaseItemDto> result =
          await apiService.getResumableMovies(limit: 10);

      debugPrint('[TEST] TotalRecordCount: ${result.totalRecordCount}');
      debugPrint('[TEST] Items count: ${result.items.length}');

      for (var i = 0; i < result.items.length; i++) {
        final item = result.items[i];
        debugPrint('[TEST] --- Movie #$i ---');
        debugPrint('[TEST]   Id: ${item.id}');
        debugPrint('[TEST]   Name: ${item.name}');
        debugPrint('[TEST]   Type: ${item.type}');
        debugPrint('[TEST]   ProductionYear: ${item.productionYear}');
        debugPrint('[TEST]   UserData.playedPercentage: ${item.userData?.playedPercentage}');
        debugPrint('[TEST]   UserData.playbackPositionTicks: ${item.userData?.playbackPositionTicks}');
      }

      // 断言：返回的应该是 Movie 类型
      for (final item in result.items) {
        expect(
          item.type,
          equals('Movie'),
          reason: 'Resumable movies should return Movie type, got ${item.type}',
        );
      }

      debugPrint('[TEST] ===== getResumableMovies 完成 =====');
    });

    test('getResumableSeries returns series with IsResumable filter', () async {
      debugPrint('[TEST] ===== getResumableSeries =====');

      final QueryResult<BaseItemDto> result =
          await apiService.getResumableSeries(limit: 10);

      debugPrint('[TEST] TotalRecordCount: ${result.totalRecordCount}');
      debugPrint('[TEST] Items count: ${result.items.length}');

      for (var i = 0; i < result.items.length; i++) {
        final item = result.items[i];
        debugPrint('[TEST] --- Series #$i ---');
        debugPrint('[TEST]   Id: ${item.id}');
        debugPrint('[TEST]   Name: ${item.name}');
        debugPrint('[TEST]   Type: ${item.type}');
        debugPrint('[TEST]   ProductionYear: ${item.productionYear}');
        debugPrint('[TEST]   UserData.playedPercentage: ${item.userData?.playedPercentage}');
        debugPrint('[TEST]   UserData.playbackPositionTicks: ${item.userData?.playbackPositionTicks}');
      }

      // 断言：返回的应该是 Series 类型
      for (final item in result.items) {
        expect(
          item.type,
          equals('Series'),
          reason:
              'Resumable series should return Series type, got ${item.type}',
        );
      }

      debugPrint('[TEST] ===== getResumableSeries 完成 =====');
    });

    test('raw API comparison: old getContinueWatching vs new split APIs',
        () async {
      debugPrint('[TEST] ===== API 对比测试 =====');

      // 旧的 NextUp API
      final oldResult = await apiService.getContinueWatching(limit: 10);
      debugPrint('[TEST] 旧 API (NextUp) - Items: ${oldResult.items.length}');
      for (final item in oldResult.items) {
        debugPrint('[TEST]   [NextUp] ${item.name} (Type: ${item.type})');
      }

      // 新的 IsResumable Movies
      final moviesResult = await apiService.getResumableMovies(limit: 10);
      debugPrint('[TEST] 新 API (Movies) - Items: ${moviesResult.items.length}');
      for (final item in moviesResult.items) {
        debugPrint('[TEST]   [Movie] ${item.name}');
      }

      // 新的 IsResumable Series
      final seriesResult = await apiService.getResumableSeries(limit: 10);
      debugPrint(
          '[TEST] 新 API (Series) - Items: ${seriesResult.items.length}');
      for (final item in seriesResult.items) {
        debugPrint('[TEST]   [Series] ${item.name}');
      }

      debugPrint('[TEST] ===== API 对比完成 =====');
    });

    test('getChildren returns items inside a CollectionFolder', () async {
      debugPrint('[TEST] ===== getChildren 测试 =====');

      // 先获取视图列表，找到一个 CollectionFolder
      final views = await apiService.getViews();
      debugPrint('[TEST] Views count: ${views.items.length}');

      if (views.items.isEmpty) {
        debugPrint('[TEST] 无可用视图，跳过测试');
        return;
      }

      // 找一个 isFolder 类型的视图（如"电视剧"、"电影"）
      final folder = views.items.firstWhere(
        (v) => v.isFolder == true,
        orElse: () => views.items.first,
      );
      debugPrint('[TEST] 测试文件夹: ${folder.name} (id=${folder.id}, type=${folder.type}, isFolder=${folder.isFolder})');

      // 获取该文件夹的子项目
      final children = await apiService.getChildren(
        folder.id!,
        includeItemTypes: 'Movie,Series',
        recursive: false,
        limit: 10,
      );

      debugPrint('[TEST] Children count: ${children.items.length}');
      for (var i = 0; i < children.items.length; i++) {
        final item = children.items[i];
        debugPrint('[TEST] --- Child #$i ---');
        debugPrint('[TEST]   Id: ${item.id}');
        debugPrint('[TEST]   Name: ${item.name}');
        debugPrint('[TEST]   Type: ${item.type}');
        debugPrint('[TEST]   isFolder: ${item.isFolder}');
      }

      expect(children.items.isNotEmpty, isTrue,
          reason: 'Folder ${folder.name} should have children');

      debugPrint('[TEST] ===== getChildren 测试完成 =====');
    });

    test('getMovieRecommendations returns recommended movies', () async {
      debugPrint('[TEST] ===== getMovieRecommendations 测试 =====');

      final result = await apiService.getMovieRecommendations(
        itemLimit: 10,
        categoryLimit: 3,
      );

      debugPrint('[TEST] TotalRecordCount: ${result.totalRecordCount}');
      debugPrint('[TEST] Items count: ${result.items.length}');

      for (var i = 0; i < result.items.length && i < 10; i++) {
        final item = result.items[i];
        debugPrint('[TEST] --- Recommendation #$i ---');
        debugPrint('[TEST]   Id: ${item.id}');
        debugPrint('[TEST]   Name: ${item.name}');
        debugPrint('[TEST]   Type: ${item.type}');
        debugPrint('[TEST]   ProductionYear: ${item.productionYear}');
        debugPrint('[TEST]   Overview: ${item.overview?.substring(0, (item.overview!.length > 50 ? 50 : item.overview!.length))}...');
      }

      // 断言：返回的应该是 Movie 类型
      for (final item in result.items) {
        expect(item.type, equals('Movie'),
            reason: 'Recommendations should return Movie type, got ${item.type}');
      }

      debugPrint('[TEST] ===== getMovieRecommendations 测试完成 =====');
    });
  });
}
