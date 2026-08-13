[한국어](README.ko.md)

# my_api

[API documentation](https://rivmt.github.io/my_api/)

## Introduction

`my_api` is a shared Flutter package for MySuite applications. It provides the client-side models, authentication, API access, state management, and reusable UI components needed to communicate with `kyro`, a separate backend project that serves API endpoints for multiple applications.

The package currently includes common application infrastructure and personal finance functionality used by MyFinance.

> This repository contains a client library, not the backend server. A running `kyro` instance and an OIDC (OpenID Connect) provider are required for authenticated API access.

## Features

- **REST API client**: Typed create, read, update, delete, statistics, and streaming search operations through the singleton `ApiClient`.
- **OIDC authentication**: Authorization Code Flow login, logout, token storage, and bearer token injection into API requests.
- **Finance models**: Models for accounts, payment methods, transactions, categories, currencies, and preferences.
- **Riverpod state management**: Notifiers and providers for loading, updating, searching, and calculating values from API-backed models.
- **Query support**: Sorting, date and value ranges, filtering, and text search through `ApiQuery`.
- **Reusable UI**: Themes, responsive screen planning, cards, dialogs, modals, charts, date controls, loading states, and finance-specific widgets.
- **Navigation utilities**: Reusable route path, parser, and router delegate foundations for Flutter applications.
- **Data utilities**: Model serialization and CSV-oriented `DataFrame` conversion.
- **Extensibility**: Hooks for mapping additional model types to custom endpoints and deserializers.

The main public libraries are:

| Library | Purpose |
| --- | --- |
| `package:my_api/core.dart` | API client, common models, notifiers, navigation, utilities, themes, and shared widgets |
| `package:my_api/finance.dart` | Finance models and finance-specific widgets |
| `package:my_api/provider.dart` | Core and finance Riverpod providers |

## Setup

### 1. Prepare the development environment

You will need:

- Flutter SDK compatible with Dart `>=2.18.6 <3.0.0`
- Access to a `kyro` backend serving the required application endpoints
- An OIDC provider and registered client

After cloning this repository, install its dependencies:

```bash
flutter pub get
```

To use the package from another Flutter project, add the Git dependency:

```yaml
dependencies:
  my_api:
    git:
      url: https://github.com/RivMt/my_api
      ref: master
```

For local development, use a path dependency instead:

```yaml
dependency_overrides:
  my_api:
    path: ../my_api
```

### 2. Initialize the API client

Call `ApiClient().init(...)` after Flutter binding initialization and before starting the application:

```dart
import 'package:flutter/widgets.dart';
import 'package:my_api/core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ApiClient().init({
    'apiUri': 'api.example.com',
    'authUri': 'https://auth.example.com/realms/mysuite',
    'clientId': 'my-app',
    'clientSecret': 'replace-with-your-client-secret',
    'redirectUri': 'https://app.example.com/redirect.html',
    'isDevelop': false,
  });

  runApp(const MyApp());
}
```

| Key | Description |
| --- | --- |
| `apiUri` | The `kyro` host and optional port. The current implementation expects `host` or `host:port` without a URI scheme, for example `api.example.com` or `localhost:8080`. |
| `authUri` | The full URI of the OIDC provider or realm used to discover its OpenID configuration. |
| `clientId` | The client ID registered with the OIDC provider. |
| `clientSecret` | The OIDC client secret used by the configured authentication flow. |
| `redirectUri` | The login redirect URI. It must exactly match a redirect URI registered with the OIDC provider. |
| `isDevelop` | Uses HTTP for `kyro` requests when `true` and HTTPS when `false`. |

Do not commit real credentials. Client configuration bundled in a Flutter application can be inspected by end users, so production OIDC settings must be safe for a public client environment.

### 3. Authenticate and access data

Import only the public libraries needed by the application:

```dart
import 'package:my_api/core.dart';
import 'package:my_api/finance.dart';
import 'package:my_api/provider.dart' as provider;
```

Authenticate through the shared client and use typed operations for supported models:

```dart
final client = ApiClient();

final user = await client.login();
final accounts = await client.read<Account>({
  ModelKeys.keyDeleted: false,
});

if (accounts.result == ApiResponseResult.success) {
  for (final account in accounts.data) {
    Log.i('Example', account.name);
  }
}

await client.logout();
```

Built-in model endpoints are mapped to the corresponding `kyro` routes:

- `api/core/preferences`
- `api/finance/accounts`
- `api/finance/payments`
- `api/finance/transactions`
- `api/finance/categories`
- `api/finance/currencies`

Applications can support additional model types by assigning `ApiClient.handleExtendedEndpoint` and `ApiClient.extendCast` before making typed requests.

### 4. Run checks and tests

Analyze the package and run its model tests with:

```bash
flutter analyze
flutter test
```

See the generated [API documentation](https://rivmt.github.io/my_api/) for the complete public class and method reference.
