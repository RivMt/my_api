import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
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

DemoConnector createDemoConnector([List<Uri>? requests]) {
  final assets = <String, Object>{
    'accounts': [
      {
        'uuid': 'demo-account',
        'owner_id': User.demoId,
        'name': 'Demo Account',
        'currency_id': 'USD',
      },
    ],
    'categories': <Object>[],
    'currencies': [
      {
        'uuid': 'USD',
        'region_code': 'US',
        'currency_code': 'D',
        'symbol': r'$',
        'icon_url': '',
        'decimal_point': 2,
      },
    ],
    'payments': <Object>[],
    'transactions': [
      {
        'uuid': 'demo-transaction',
        'paid_date': '2020-01-31',
        'calculated_date': '2020-01-31',
      },
    ],
    'preferences': <Object>[],
  };
  return DemoConnector(
    endpoints: const [
      Account.endpoint,
      Currency.endpoint,
      Transaction.endpoint,
    ],
    transformers: {
      Transaction.endpoint: (items) => alignDemoTransactionDates(
            items,
            now: DateTime(2026, 2, 15),
          ),
    },
    baseUri: Uri.parse('https://app.example/assets/assets/demo'),
    client: MockClient((request) async {
      requests?.add(request.url);
      final data = assets[request.url.pathSegments.last];
      if (data == null) {
        return http.Response('', 404);
      }
      return http.Response.bytes(utf8.encode(json.encode(data)), 200);
    }),
  );
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

    test('loads demo assets with GET and seeds local storage', () async {
      final requests = <Uri>[];
      final connector = createDemoConnector(requests);
      await connector.init(const {});

      expect(
        connector.buildUri('api/finance/accounts', {'deleted': false}),
        Uri.parse(
          '${connector.uri}/accounts?deleted=false',
        ),
      );
      final user = await connector.login();
      expect(user.isValid, isTrue);
      expect(user, same(User.demo));
      expect(user.userId, User.demoId);
      expect(requests.map((uri) => uri.pathSegments.last).toSet(), {
        'accounts',
        'currencies',
        'transactions',
      });
      expect(
        (await connector.storage.read('api/finance/accounts')).single['name'],
        'Demo Account',
      );
      expect(
        (await connector.storage.read(Transaction.endpoint))
            .single['paid_date'],
        '2026-02-28',
      );
      expect(await connector.logout(), same(User.unknown));
      expect(await connector.storage.read(Account.endpoint), isEmpty);
      expect(await connector.storage.read(Currency.endpoint), isEmpty);
      expect(await connector.storage.read(Transaction.endpoint), isEmpty);
    });

    test('is selected by the API client in demo mode', () async {
      await ApiClient.instance.init(
        {'mode': AppMode.demo.name},
        demoEndpoints: const [Account.endpoint],
      );

      expect(ApiClient.instance.connector, isA<DemoConnector>());
      expect(
        (ApiClient.instance.connector as DemoConnector).endpoints,
        [Account.endpoint],
      );
      expect(ApiClient.instance.mode, AppMode.demo);
      expect(
        ApiClient.instance.buildUri('api/finance/accounts', null),
        Uri.parse('${DemoConnector.demoUri}/accounts'),
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
