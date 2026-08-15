import 'dart:convert';
import 'dart:io';

import 'package:decimal/decimal.dart';
import 'package:http/http.dart' as http;
import 'package:my_api/src/core/api/api_mode.dart';
import 'package:my_api/src/core/api/api_query.dart';
import 'package:my_api/src/core/api/api_response.dart';
import 'package:my_api/src/core/api/api_response_result.dart';
import 'package:my_api/src/core/api/http_method.dart';
import 'package:my_api/src/core/log.dart';
import 'package:my_api/src/core/model/model_keys.dart';
import 'package:my_api/src/core/model/preference.dart';
import 'package:my_api/src/core/model/preference_element.dart';
import 'package:my_api/src/core/model/user.dart';
import 'package:my_api/src/core/oidc.dart';
import 'package:my_api/src/finance/model/account.dart';
import 'package:my_api/src/finance/model/category.dart';
import 'package:my_api/src/finance/model/currency.dart';
import 'package:my_api/src/finance/model/payment.dart';
import 'package:my_api/src/finance/model/transaction.dart';

const String _tag = "API";

/// Sends and receives HTTP requests to the backend server.
class ApiClient {
  /// Private instance for singleton pattern.
  static final ApiClient _instance = ApiClient._();

  /// Private constructor for singleton pattern.
  ApiClient._();

  /// Factory constructor for singleton pattern.
  factory ApiClient() => _instance;

  /// Instance for OIDC management.
  final OpenIDConnect oidc = OpenIDConnect();

  /// Address of backend server.
  String _uri = "";

  /// Address of backend server (read-only).
  String get uri => _uri;

  /// HTTP request headers.
  ///
  /// This header includes the authentication token. Be careful when using it.
  Map<String, String> get headers => {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${oidc.accessToken}",
      };

  /// Current application mode (read-only).
  ApiMode get mode => _mode;

  /// Whether the current app is in developer mode (read-only).
  @Deprecated('Use mode == ApiMode.dev instead.')
  bool get isDevelop => mode == ApiMode.dev;

  /// Current application mode.
  ApiMode _mode = ApiMode.production;

  /// Function to extend endpoint handling.
  String Function<T>()? handleExtendedEndpoint;

  /// Function to extend casting.
  Function<T>(Map<String, dynamic> map)? extendCast;

  /// Initializes the client with [preferences].
  Future<void> init(Map<String, dynamic> preferences) async {
    _uri = preferences["apiUri"] ?? "";
    final serverUri = preferences["authUri"] ?? "";
    final clientId = preferences["clientId"] ?? "";
    final redirectUri = preferences["redirectUri"] ?? "";
    _mode = ApiMode.values.byName(preferences["mode"] ?? "production");
    await oidc.init(
      serverUri: serverUri,
      clientId: clientId,
      redirectUri: redirectUri,
    );
    Log.i(_tag, "API Client initialized");
  }

  /// Logs in.
  Future<User> login() async {
    final user = await oidc.login();
    Log.i(_tag, "Logged in: ${user.email}");
    return user;
  }

  /// Logs out.
  ///
  /// Returns [User.unknown] when logout succeeds.
  Future<User> logout() async {
    await oidc.logout();
    Log.i(_tag, "Logged out");
    return User.unknown;
  }

  /// Returns the REST API [Uri] for [endpoint] and [query].
  Uri buildUri(String endpoint, Map<String, dynamic>? query) {
    final split = uri.split(":");
    final host = split[0];
    final port = (split.length > 1) ? int.parse(split[1]) : null;
    return Uri(
      scheme: mode == ApiMode.dev ? "http" : "https",
      host: host,
      port: port,
      path: endpoint,
      queryParameters: query,
    );
  }

  Future<http.StreamedResponse> _request({
    required HttpMethod method,
    required String endpoint,
    Object? body,
    Map<String, dynamic>? query,
  }) async {
    final uri = buildUri(endpoint, query);
    final client = http.Client();
    final request = http.Request(method.name.toUpperCase(), uri);
    for (String key in headers.keys) {
      request.headers[key] = headers[key]!;
    }
    if (body != null) {
      request.body = json.encode(body);
    }
    try {
      final response = await client.send(request);
      final logMessage = "${response.statusCode} $method $uri";
      if (response.statusCode != 200) {
        Log.w(_tag, logMessage);
      } else {
        Log.v(_tag, logMessage);
      }
      return response;
    } on SocketException catch (e, s) {
      Log.e(_tag, "Socket Exception: $method $uri", e, s);
    } on http.ClientException catch (e, s) {
      Log.e(_tag, "Client Exception: $method $uri", e, s);
    }
    return http.StreamedResponse(const Stream.empty(), 400);
  }

  /// Sends an HTTP stream request with [method] and [endpoint].
  Future<ApiResponse<Stream>> requestStream<T>({
    required HttpMethod method,
    required String endpoint,
    Object? body,
    ApiQuery? query,
  }) async {
    final response = await _request(
      method: method,
      endpoint: endpoint,
      body: body,
      query: query?.params,
    );
    if (response.statusCode != 200) {
      return ApiResponse.failed(const Stream.empty());
    }
    return ApiResponse(
      result: ApiResponseResult.success,
      data: response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .map((line) => json.decode(line) as Map<String, dynamic>),
    );
  }

  /// Sends an HTTP request with [method] and [endpoint].
  Future<ApiResponse> request<T>({
    required HttpMethod method,
    required String endpoint,
    Object? body,
    ApiQuery? query,
  }) async {
    final defaultValue = method == HttpMethod.get ? <T>[] : <String, dynamic>{};
    final response = await _request(
      method: method,
      endpoint: endpoint,
      body: body,
      query: query?.params,
    );
    if (response.statusCode != 200) {
      return ApiResponse.failed(defaultValue);
    }
    final bytes = await response.stream.toBytes();
    return ApiResponse(
      result: ApiResponseResult.success,
      data: json.decode(utf8.decode(bytes)),
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
      endpoint: "${endpoint<T>()}/stat",
      query: query,
    );
    final Map<String, Decimal> data = {};
    for (String key in result.data) {
      try {
        data[key] = Decimal.parse(result.data[key]);
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
