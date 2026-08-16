import 'package:decimal/decimal.dart';
import 'package:my_api/src/core/api/api_connector.dart';
import 'package:my_api/src/core/api/demo_connector.dart';
import 'package:my_api/src/core/app_mode.dart';
import 'package:my_api/src/core/api/api_query.dart';
import 'package:my_api/src/core/api/api_response.dart';
import 'package:my_api/src/core/api/http_method.dart';
import 'package:my_api/src/core/api/remote_connector.dart';
import 'package:my_api/src/core/log.dart';
import 'package:my_api/src/core/model/model_keys.dart';
import 'package:my_api/src/core/model/preference.dart';
import 'package:my_api/src/core/model/preference_element.dart';
import 'package:my_api/src/core/model/user.dart';
import 'package:my_api/src/finance/model/account.dart';
import 'package:my_api/src/finance/model/category.dart';
import 'package:my_api/src/finance/model/currency.dart';
import 'package:my_api/src/finance/model/payment.dart';
import 'package:my_api/src/finance/model/transaction.dart';

const String _tag = "API";

/// Sends and receives HTTP requests to the backend server.
class ApiClient {
  /// Environment variable used to override the configured API mode.
  static const String modeEnvironmentKey = "MYSUITE_MODE";

  static const String _environmentMode = String.fromEnvironment(
    modeEnvironmentKey,
  );

  /// Private instance for singleton pattern.
  static final ApiClient _instance = ApiClient._();

  /// Private constructor for singleton pattern.
  ApiClient._() {
    _connector = RemoteConnector();
  }

  /// Factory constructor for singleton pattern.
  factory ApiClient() => _instance;

  /// Singleton instance.
  static ApiClient get instance => _instance;

  /// Address of backend server (read-only).
  String get uri => _connector.uri;

  /// Current application mode (read-only).
  AppMode get mode => _connector.mode;

  /// Whether the current app is in developer mode (read-only).
  @Deprecated('Use mode == ApiMode.dev instead.')
  bool get isDevelop => mode == AppMode.dev;

  /// Connector used to send API requests.
  ApiConnector get connector => _connector;

  late ApiConnector _connector;

  /// Function to extend endpoint handling.
  String Function<T>()? handleExtendedEndpoint;

  /// Function to extend casting.
  Function<T>(Map<String, dynamic> map)? extendCast;

  /// Initializes the client with [preferences].
  ///
  /// [demoEndpoints] selects the assets loaded when demo mode logs in.
  /// [demoTransformers] customizes loaded data for individual endpoints.
  Future<void> init(
    Map<String, dynamic> preferences, {
    Iterable<String> demoEndpoints = const [],
    Map<String, DemoDataTransformer> demoTransformers = const {},
  }) async {
    final mode = resolveMode(preferences);
    _connector = _createConnector(mode, demoEndpoints, demoTransformers);
    await _connector.init(preferences);
    Log.i(_tag, "API Client initialized");
  }

  /// Resolves the API mode, preferring a valid environment override.
  static AppMode resolveMode(
    Map<String, dynamic> preferences, {
    Map<String, String>? environment,
  }) {
    final modeName = environment == null
        ? (_environmentMode.isEmpty ? null : _environmentMode)
        : environment[modeEnvironmentKey];
    if (modeName != null &&
        AppMode.values.any((mode) => mode.name == modeName)) {
      return AppMode.values.byName(modeName);
    }
    return AppMode.values.byName(
      preferences["mode"] ?? AppMode.production.name,
    );
  }

  ApiConnector _createConnector(
    AppMode mode,
    Iterable<String> demoEndpoints,
    Map<String, DemoDataTransformer> demoTransformers,
  ) =>
      switch (mode) {
        AppMode.demo => DemoConnector(
            endpoints: demoEndpoints,
            transformers: demoTransformers,
          ),
        AppMode.production ||
        AppMode.dev ||
        AppMode.edge ||
        AppMode.test =>
          RemoteConnector(mode: mode),
      };

  /// Logs in.
  Future<User> login() => _connector.login();

  /// Logs out.
  ///
  /// Returns [User.unknown] when logout succeeds.
  Future<User> logout() => _connector.logout();

  /// Returns the REST API [Uri] for [endpoint] and [query].
  Uri buildUri(String endpoint, Map<String, dynamic>? query) =>
      _connector.buildUri(endpoint, query);

  /// Sends an HTTP stream request with [method] and [endpoint].
  Future<ApiResponse<Stream>> requestStream<T>({
    required HttpMethod method,
    required String endpoint,
    Object? body,
    ApiQuery? query,
  }) {
    return _connector.requestStream<T>(
      method: method,
      endpoint: endpoint,
      body: body,
      query: query,
    );
  }

  /// Sends an HTTP request with [method] and [endpoint].
  Future<ApiResponse> request<T>({
    required HttpMethod method,
    required String endpoint,
    Object? body,
    ApiQuery? query,
  }) {
    return _connector.request<T>(
      method: method,
      endpoint: endpoint,
      body: body,
      query: query,
    );
  }

  /// Casts [map] to an instance of [T].
  dynamic cast<T>(Map<String, dynamic> map) {
    switch (T) {
      case Account:
        return Account(map);
      case Payment:
        return Payment(map);
      case Transaction:
        return Transaction(map);
      case Category:
        return Category(map);
      case Currency:
        return Currency(map);
      case PreferenceElement:
        return PreferenceElement.fromMap(PreferenceDummy(), map);
      default:
        if (extendCast == null) {
          throw UnimplementedError();
        }
        return extendCast!<T>(map);
    }
  }

  /// Casts multiple items in [list] to instances of [T].
  List<T> casts<T>(List list) {
    final data = <T>[];
    for (Map<String, dynamic> map in list) {
      data.add(cast<T>(map));
    }
    return data;
  }

  /// Gets the API endpoint from type [T].
  String endpoint<T>() {
    switch (T) {
      case Account:
        return Account.endpoint;
      case Payment:
        return Payment.endpoint;
      case Transaction:
        return Transaction.endpoint;
      case Category:
        return Category.endpoint;
      case Currency:
        return Currency.endpoint;
      case PreferenceElement:
        return Preference.endpoint;
      default:
        if (handleExtendedEndpoint == null) {
          throw UnimplementedError();
        }
        return handleExtendedEndpoint!<T>();
    }
  }

  /// Creates [body] using HTTP POST.
  Future<ApiResponse<T>> create<T>(Map<String, dynamic> body) async {
    if (T == dynamic) {
      throw TypeError();
    }
    final result = await request<T>(
      method: HttpMethod.post,
      endpoint: endpoint<T>(),
      body: body,
    );
    return result.cast<T>(cast<T>(result.data));
  }

  /// Reads data with [query] using HTTP GET.
  Future<ApiResponse<List<T>>> read<T>([Map<String, dynamic>? query]) async {
    if (T == dynamic) {
      throw TypeError();
    }
    final result = await request<T>(
      method: HttpMethod.get,
      endpoint: endpoint<T>(),
      query: ApiQuery(query),
    );
    return result.casts<T>(casts<T>(result.data));
  }

  /// Updates [body] using HTTP PUT.
  Future<ApiResponse<T>> update<T>(Map<String, dynamic> body) async {
    if (T == dynamic) {
      throw TypeError();
    }
    final result = await request<T>(
      method: HttpMethod.put,
      endpoint: endpoint<T>(),
      body: body,
    );
    return result.cast<T>(cast<T>(result.data));
  }

  /// Deletes [body] using HTTP DELETE.
  Future<ApiResponse<T>> delete<T>(Map<String, dynamic> body) async {
    if (T == dynamic) {
      throw TypeError();
    }
    final uuid = body[ModelKeys.keyUuid];
    if (uuid == null || uuid == "") {
      throw UnsupportedError("Unable to retrieve UUID: $body");
    }
    final result = await request<T>(
      method: HttpMethod.delete,
      endpoint: "${endpoint<T>()}/$uuid",
    );
    return result.cast<T>(cast<T>(result.data));
  }

  /// Calculates values with [query] using HTTP GET.
  Future<ApiResponse<Map<String, Decimal>>> stat<T>([ApiQuery? query]) async {
    if (T == dynamic) {
      throw TypeError();
    }
    final result = await request(
      method: HttpMethod.get,
      endpoint: "${endpoint<T>()}/stats",
      query: query,
    );
    final Map<String, Decimal> data = {};
    for (String key in result.data) {
      try {
        data[key] = Decimal.parse(result.data[key].toString());
      } on FormatException {
        Log.w(_tag, "Unable to parse: ${result.data[key]}");
        data[key] = Decimal.zero;
      }
    }
    return ApiResponse(result: result.result, data: data);
  }

  /// Searches [query] using HTTP GET.
  Future<ApiResponse<Stream<T>>> search<T>(String query) async {
    if (T == dynamic) {
      throw TypeError();
    }
    final result = await requestStream(
      method: HttpMethod.get,
      endpoint: "${endpoint<T>()}/search",
      query: ApiQuery({ApiQuery.keyQueryString: query}),
    );
    return ApiResponse<Stream<T>>(
      result: result.result,
      data: result.data.map((data) => cast<T>(data)),
    );
  }
}
