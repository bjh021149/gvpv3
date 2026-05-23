import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:emby_client/services/deep_link/deep_link_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class MockGoRouter extends Mock implements GoRouter {}

class MockAppLinks extends Mock implements AppLinks {}

void main() {
  group('DeepLinkService', () {
    late MockGoRouter mockRouter;
    late MockAppLinks mockAppLinks;

    setUp(() {
      mockRouter = MockGoRouter();
      mockAppLinks = MockAppLinks();
    });

    group('resolveUri', () {
      test('emby://detail/123 → /detail/123', () {
        final result = DeepLinkService.resolveUri(
          Uri.parse('emby://detail/123'),
        );

        expect(result.isHandled, isTrue);
        expect(result.path, equals('/detail/123'));
      });

      test('emby://player/abc → /player/abc', () {
        final result = DeepLinkService.resolveUri(
          Uri.parse('emby://player/abc'),
        );

        expect(result.isHandled, isTrue);
        expect(result.path, equals('/player/abc'));
      });

      test('emby://library → /library', () {
        final result = DeepLinkService.resolveUri(
          Uri.parse('emby://library'),
        );

        expect(result.isHandled, isTrue);
        expect(result.path, equals('/library'));
      });

      test('emby://library/456 → /library/456', () {
        final result = DeepLinkService.resolveUri(
          Uri.parse('emby://library/456'),
        );

        expect(result.isHandled, isTrue);
        expect(result.path, equals('/library/456'));
      });

      test('emby://home → /home', () {
        final result = DeepLinkService.resolveUri(
          Uri.parse('emby://home'),
        );

        expect(result.isHandled, isTrue);
        expect(result.path, equals('/home'));
      });

      test('emby://settings → /settings', () {
        final result = DeepLinkService.resolveUri(
          Uri.parse('emby://settings'),
        );

        expect(result.isHandled, isTrue);
        expect(result.path, equals('/settings'));
      });

      test('emby://detail/123?ref=email → /detail/123?ref=email (保留查询参数)', () {
        final result = DeepLinkService.resolveUri(
          Uri.parse('emby://detail/123?ref=email'),
        );

        expect(result.isHandled, isTrue);
        expect(result.path, equals('/detail/123?ref=email'));
      });

      test('https://example.com/detail/123 → unhandled (scheme 不匹配)', () {
        final result = DeepLinkService.resolveUri(
          Uri.parse('https://example.com/detail/123'),
        );

        expect(result.isHandled, isFalse);
        expect(result.path, isNull);
      });

      test('emby://unknown/path → unhandled (无效路由)', () {
        final result = DeepLinkService.resolveUri(
          Uri.parse('emby://unknown/path'),
        );

        expect(result.isHandled, isFalse);
        expect(result.path, isNull);
      });

      test('emby:// → unhandled (空 host)', () {
        final result = DeepLinkService.resolveUri(
          Uri.parse('emby://'),
        );

        expect(result.isHandled, isFalse);
        expect(result.path, isNull);
      });
    });

    group('init - 冷启动', () {
      test('初始链接有效时导航到对应页面', () async {
        when(() => mockAppLinks.getInitialLink())
            .thenAnswer((_) async => Uri.parse('emby://detail/123'));
        when(() => mockAppLinks.uriLinkStream)
            .thenAnswer((_) => const Stream<Uri>.empty());

        final service = DeepLinkService(
          router: mockRouter,
          appLinks: mockAppLinks,
        );
        await service.init();

        verify(() => mockRouter.go('/detail/123')).called(1);
      });

      test('初始链接无效时不导航', () async {
        when(() => mockAppLinks.getInitialLink())
            .thenAnswer((_) async => Uri.parse('emby://unknown/path'));
        when(() => mockAppLinks.uriLinkStream)
            .thenAnswer((_) => const Stream<Uri>.empty());

        final service = DeepLinkService(
          router: mockRouter,
          appLinks: mockAppLinks,
        );
        await service.init();

        verifyNever(() => mockRouter.go(any()));
      });

      test('无初始链接时不导航', () async {
        when(() => mockAppLinks.getInitialLink())
            .thenAnswer((_) async => null);
        when(() => mockAppLinks.uriLinkStream)
            .thenAnswer((_) => const Stream<Uri>.empty());

        final service = DeepLinkService(
          router: mockRouter,
          appLinks: mockAppLinks,
        );
        await service.init();

        verifyNever(() => mockRouter.go(any()));
      });
    });

    group('init - 热启动', () {
      test('收到有效深度链接时导航', () async {
        final controller = StreamController<Uri>();

        when(() => mockAppLinks.getInitialLink())
            .thenAnswer((_) async => null);
        when(() => mockAppLinks.uriLinkStream)
            .thenAnswer((_) => controller.stream);

        final service = DeepLinkService(
          router: mockRouter,
          appLinks: mockAppLinks,
        );
        await service.init();

        // 模拟热启动收到深度链接
        controller.add(Uri.parse('emby://player/456'));
        await Future.delayed(Duration.zero);

        verify(() => mockRouter.go('/player/456')).called(1);

        await controller.close();
      });

      test('收到无效深度链接时不导航', () async {
        final controller = StreamController<Uri>();

        when(() => mockAppLinks.getInitialLink())
            .thenAnswer((_) async => null);
        when(() => mockAppLinks.uriLinkStream)
            .thenAnswer((_) => controller.stream);

        final service = DeepLinkService(
          router: mockRouter,
          appLinks: mockAppLinks,
        );
        await service.init();

        controller.add(Uri.parse('https://example.com'));
        await Future.delayed(Duration.zero);

        verifyNever(() => mockRouter.go(any()));

        await controller.close();
      });
    });

    group('dispose', () {
      test('取消流订阅', () async {
        final controller = StreamController<Uri>();

        when(() => mockAppLinks.getInitialLink())
            .thenAnswer((_) async => null);
        when(() => mockAppLinks.uriLinkStream)
            .thenAnswer((_) => controller.stream);

        final service = DeepLinkService(
          router: mockRouter,
          appLinks: mockAppLinks,
        );
        await service.init();

        service.dispose();

        // 流应该已经被取消监听，但 controller 本身不会被关闭
        // 我们只需验证 dispose 不抛异常即可
        expect(service.lastResult, isNull);
      });
    });

    group('DeepLinkResult', () {
      test('toString 包含路径和 URI', () {
        final result = DeepLinkResult.handled(
          path: '/detail/123',
          uri: Uri.parse('emby://detail/123'),
        );

        expect(result.toString(), contains('/detail/123'));
        expect(result.toString(), contains('emby://detail/123'));
      });
    });
  });
}
