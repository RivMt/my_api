import 'package:flutter_test/flutter_test.dart';
import 'package:my_api/core.dart';
import 'package:my_api/finance.dart';
import 'package:my_api/src/core/oidc.dart';
import 'package:oidc/oidc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeOpenIDConnect implements OpenIDConnect {
  @override
  String get accessToken => '';

  @override
  late OidcUserManager manager;

  @override
  Future<void> init({
    required String serverUri,
    required String clientId,
    required String redirectUri,
  }) async {}

  @override
  Future<User> login() async => User.unknown;

  @override
  Future<void> logout() async {}
}

void main() {
  group('ApiClient', () {
    test('provides a single instance', () {
      expect(identical(ApiClient(), ApiClient.instance), isTrue);
    });

    test('uses a remote connector by default', () {
      expect(ApiClient.instance.connector, isA<RemoteConnector>());
    });

    test('prefers valid environment modes over config', () {
      for (final mode in AppMode.values) {
        expect(
          ApiClient.resolveMode(
            {'mode': AppMode.production.name},
            environment: {ApiClient.modeEnvironmentKey: mode.name},
          ),
          mode,
        );
      }
    });

    test('uses config when the environment mode is invalid', () {
      expect(
        ApiClient.resolveMode(
          {'mode': AppMode.demo.name},
          environment: {ApiClient.modeEnvironmentKey: 'invalid'},
        ),
        AppMode.demo,
      );
    });
  });

  group('RemoteConnector', () {
    test('builds a URI with the configured API scheme', () async {
      final connector = RemoteConnector(
        mode: AppMode.production,
        oidc: FakeOpenIDConnect(),
      );
      await connector.init({
        'apiScheme': 'http',
        'apiUri': 'localhost:8080',
      });

      expect(
        connector.buildUri('/items', {'page': '1'}),
        Uri.parse('http://localhost:8080/items?page=1'),
      );
    });

    test('defaults the API scheme to HTTPS regardless of mode', () async {
      final connector = RemoteConnector(
        mode: AppMode.dev,
        oidc: FakeOpenIDConnect(),
      );
      await connector.init({'apiUri': 'api.example.com'});

      expect(
        connector.buildUri('/items', null),
        Uri.parse('https://api.example.com/items'),
      );
    });
  });

  group('DemoConnector', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('uses a dummy URI and does not authenticate', () async {
      final connector = DemoConnector();
      await connector.init(const {});

      expect(
        connector.buildUri('api/finance/accounts', {'deleted': false}),
        Uri.parse(
          '${AppMode.demo.name}://local/api/finance/accounts?deleted=false',
        ),
      );
      final user = await connector.login();
      expect(user.isValid, isTrue);
      expect(user, same(User.demo));
      expect(user.userId, User.demoId);
      expect(await connector.logout(), same(User.unknown));
    });

    test('is selected by the API client in demo mode', () async {
      await ApiClient.instance.init({'mode': AppMode.demo.name});

      expect(ApiClient.instance.connector, isA<DemoConnector>());
      expect(ApiClient.instance.mode, AppMode.demo);
      expect(
        ApiClient.instance.buildUri('api/finance/accounts', null).scheme,
        AppMode.demo.name,
      );
    });

    test('serves model CRUD through the API client', () async {
      await ApiClient.instance.init({'mode': AppMode.demo.name});

      final created = await ApiClient.instance.create<Category>({
        'name': 'Food',
        'type': 0,
        'included': true,
        'icon': 1,
      });
      final items = await ApiClient.instance.read<Category>();

      expect(created.result, ApiResponseResult.success);
      expect(created.data.uuid, startsWith('${User.demoId}-'));
      expect(items.data.map((item) => item.name), contains('Food'));
    });
  });
}
