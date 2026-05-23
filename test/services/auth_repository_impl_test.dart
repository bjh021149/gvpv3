import 'package:dio/dio.dart';
import 'package:emby_client/services/repositories/auth_repository_impl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

class MockDio extends Mock implements Dio {}

class FakeRequestOptions extends Fake implements RequestOptions {}

class FakeOptions extends Fake implements Options {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeRequestOptions());
    registerFallbackValue(FakeOptions());
  });

  group('AuthRepositoryImpl', () {
    late MockFlutterSecureStorage mockStorage;
    late AuthRepositoryImpl repository;

    const testServerUrl = 'http://192.168.1.100:8096';
    const testUsername = 'testuser';
    const testPassword = 'testpass';
    const testAccessToken = 'abc123-token';
    const testSessionId = 'session-xyz-789';
    const testUserId = 'user-id-456';

    setUp(() async {
      SharedPreferences.setMockInitialValues({});

      mockStorage = MockFlutterSecureStorage();

      // Setup mock storage responses
      when(() => mockStorage.write(
        key: any(named: 'key'),
        value: any(named: 'value'),
      )).thenAnswer((_) async {});

      when(() => mockStorage.delete(
        key: any(named: 'key'),
      )).thenAnswer((_) async {});

      when(() => mockStorage.read(
        key: any(named: 'key'),
      )).thenAnswer((_) async => null);

      repository = AuthRepositoryImpl(
        secureStorage: mockStorage,
      );
    });

    group('authenticate with mocked Dio', () {
      late MockDio mockDio;

      setUp(() {
        mockDio = MockDio();
        repository = AuthRepositoryImpl(
          secureStorage: mockStorage,
          authDio: mockDio,
        );
      });

      test('successful login persists all 5 credentials', () async {
        // Arrange
        final mockResponse = Response<Map<String, dynamic>>(
          data: {
            'AccessToken': testAccessToken,
            'ServerId': 'server-123',
            'User': {'Id': testUserId, 'Name': testUsername},
            'SessionInfo': {'Id': testSessionId},
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: '/Users/AuthenticateByName'),
        );

        when(() => mockDio.post<Map<String, dynamic>>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await repository.authenticate(
          testServerUrl,
          testUsername,
          testPassword,
        );

        // Assert result
        expect(result.accessToken, equals(testAccessToken));
        expect(result.user?.id, equals(testUserId));

        // Assert SecureStorage writes (4 sensitive items)
        final writeCalls = verify(() => mockStorage.write(
          key: captureAny(named: 'key'),
          value: captureAny(named: 'value'),
        )).captured;

        // write() returns flat list: [key1, value1, key2, value2, ...]
        final writtenKeys = <String>{};
        for (var i = 0; i < writeCalls.length; i += 2) {
          writtenKeys.add(writeCalls[i] as String);
        }

        expect(writtenKeys, contains('emby_access_token'));
        expect(writtenKeys, contains('emby_server_url'));
        expect(writtenKeys, contains('emby_password'));
        expect(writtenKeys, contains('emby_session_id'));

        // Assert SharedPreferences writes (2 non-sensitive items)
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('emby_user_id'), equals(testUserId));
        expect(prefs.getString('emby_username'), equals(testUsername));
      });

      test('login without SessionInfo skips session_id write', () async {
        final mockResponse = Response<Map<String, dynamic>>(
          data: {
            'AccessToken': testAccessToken,
            'ServerId': 'server-123',
            'User': {'Id': testUserId, 'Name': testUsername},
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: '/Users/AuthenticateByName'),
        );

        when(() => mockDio.post<Map<String, dynamic>>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
        )).thenAnswer((_) async => mockResponse);

        await repository.authenticate(testServerUrl, testUsername, testPassword);

        // Verify session_id was NOT written
        verifyNever(() => mockStorage.write(
          key: 'emby_session_id',
          value: any(named: 'value'),
        ));

        // But other keys were written
        verify(() => mockStorage.write(
          key: 'emby_access_token',
          value: any(named: 'value'),
        )).called(1);
      });

      test('failed login clears credentials via logout', () async {
        when(() => mockDio.post<Map<String, dynamic>>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
        )).thenThrow(DioException(
          requestOptions: RequestOptions(path: '/Users/AuthenticateByName'),
          response: Response(
            statusCode: 401,
            requestOptions: RequestOptions(path: '/Users/AuthenticateByName'),
          ),
          type: DioExceptionType.badResponse,
        ));

        // Act & Assert: authenticate throws and logout cleans up
        try {
          await repository.authenticate(testServerUrl, testUsername, testPassword);
          fail('should throw DioException');
        } on DioException catch (_) {
          // expected
        }

        // Verify SecureStorage deletes were issued by logout
        verify(() => mockStorage.delete(key: any(named: 'key'))).called(greaterThanOrEqualTo(1));
      });
    });

    group('logout', () {
      test('clears all credentials', () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('emby_user_id', testUserId);
        await prefs.setString('emby_username', testUsername);

        await repository.logout();

        final deleteCalls = verify(() => mockStorage.delete(
          key: captureAny(named: 'key'),
        )).captured;
        final deletedKeys = deleteCalls.cast<String>().toSet();

        expect(deletedKeys, contains('emby_access_token'));
        expect(deletedKeys, contains('emby_server_url'));
        expect(deletedKeys, contains('emby_password'));
        expect(deletedKeys, contains('emby_session_id'));

        expect(prefs.getString('emby_user_id'), isNull);
        expect(prefs.getString('emby_username'), isNull);
      });
    });

    group('refreshAuthentication', () {
      test('re-authenticates with stored credentials', () async {
        when(() => mockStorage.read(key: 'emby_server_url'))
            .thenAnswer((_) async => testServerUrl);
        when(() => mockStorage.read(key: 'emby_username'))
            .thenAnswer((_) async => testUsername);
        when(() => mockStorage.read(key: 'emby_password'))
            .thenAnswer((_) async => testPassword);

        final mockDio = MockDio();
        repository = AuthRepositoryImpl(
          secureStorage: mockStorage,
          authDio: mockDio,
        );

        when(() => mockDio.post<Map<String, dynamic>>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
        )).thenAnswer((_) async => Response<Map<String, dynamic>>(
          data: {
            'AccessToken': 'new-token-789',
            'ServerId': 'server-123',
            'User': {'Id': testUserId, 'Name': testUsername},
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: '/Users/AuthenticateByName'),
        ));

        final result = await repository.refreshAuthentication();
        expect(result, isTrue);

        verify(() => mockStorage.write(
          key: 'emby_access_token',
          value: 'new-token-789',
        )).called(1);
      });

      test('returns false when credentials are missing', () async {
        when(() => mockStorage.read(key: any(named: 'key')))
            .thenAnswer((_) async => null);

        final result = await repository.refreshAuthentication();
        expect(result, isFalse);
      });
    });

    group('getSessionId', () {
      test('returns stored session id', () async {
        when(() => mockStorage.read(key: 'emby_session_id'))
            .thenAnswer((_) async => testSessionId);

        final result = await repository.getSessionId();
        expect(result, equals(testSessionId));
      });

      test('returns null when not stored', () async {
        when(() => mockStorage.read(key: 'emby_session_id'))
            .thenAnswer((_) async => null);

        final result = await repository.getSessionId();
        expect(result, isNull);
      });
    });

    group('REAL SERVER integration test', () {
      const realServerUrl = 'http://qqpyf.vip:7001';
      const realUsername = 'haoyuzhishijie';
      const realPassword = 'hi021149';

      test('authenticate against real Emby server', () async {
        // Use REAL Dio and mock storage to verify persistence
        final realRepo = AuthRepositoryImpl(secureStorage: mockStorage);

        // Act: authenticate against real server
        final result = await realRepo.authenticate(
          realServerUrl,
          realUsername,
          realPassword,
        );

        // Assert: got valid result
        expect(result.accessToken, isNotNull);
        expect(result.accessToken, isNotEmpty);
        expect(result.user, isNotNull);
        expect(result.user!.id, isNotNull);

        // Assert: SecureStorage received all 5 credentials
        final writeCalls = verify(() => mockStorage.write(
          key: captureAny(named: 'key'),
          value: captureAny(named: 'value'),
        )).captured;

        final stored = <String, String>{};
        for (var i = 0; i < writeCalls.length; i += 2) {
          stored[writeCalls[i] as String] = writeCalls[i + 1] as String;
        }

        // 1. username (SharedPreferences)
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('emby_username'), equals(realUsername));

        // 2. pw (SecureStorage)
        expect(stored['emby_password'], equals(realPassword));

        // 3. apiKey / accessToken (SecureStorage)
        expect(stored['emby_access_token'], equals(result.accessToken));
        expect(stored['emby_access_token'], isNotEmpty);

        // 4. serverUrl (SecureStorage)
        expect(stored['emby_server_url'], equals(realServerUrl));

        // 5. sessionId (SecureStorage) - may or may not be present
        print('Stored keys: ${stored.keys.toList()}');
        print('AccessToken: ${result.accessToken}');
        print('UserId: ${result.user!.id}');
        if (stored.containsKey('emby_session_id')) {
          print('SessionId: ${stored['emby_session_id']}');
        } else {
          print('SessionId: not present in response');
        }

        // 6. userId (SharedPreferences)
        expect(prefs.getString('emby_user_id'), equals(result.user!.id));
      });
    });
  });
}
