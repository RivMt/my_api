import 'dart:io';
import 'dart:convert';
import 'package:decimal/decimal.dart';
import 'package:http/http.dart' as http;
import 'package:my_api/core/log.dart';
import 'package:my_api/core/model/model_keys.dart';
import 'package:my_api/core/model/preference_element.dart';
import 'package:my_api/core/model/user.dart';
import 'package:my_api/core/oidc.dart';
import 'package:my_api/finance/model/account.dart';
import 'package:my_api/finance/model/category.dart';
import 'package:my_api/finance/model/currency.dart';
import 'package:my_api/finance/model/payment.dart';
import 'package:my_api/finance/model/transaction.dart';
import 'package:oidc/oidc.dart';

import 'model/preference.dart';

const String _tag = "API";

/// Send and receive HTTP request to backend server
class ApiClient {

  /// Header key for API key
  static const String keyApiKey = "X-API-Key";  // TODO: remove

  /// Private instance for singleton pattern
  static final ApiClient _instance = ApiClient._();

  /// Private constructor for singleton pattern
  ApiClient._();

  /// Factory constructor for singleton pattern
  factory ApiClient() => _instance;

  /// Instance for OIDC management
  final OpenIDConnect oidc = OpenIDConnect();

  /// Address of backend server
  String _uri = "";

  /// Address of backend server (Read-only)
  String get uri => _uri;

  /// HTTP request headers
  ///
  /// This header includes authenticate token also. Be careful when using this.
  Map<String, String> get headers => {
    "Content-Type": "application/json",
    "Authorization": "Bearer ${oidc.idToken}",
  };

  /// Whether current app is developer mode (Read-only)
  bool get isDevelop => _isDevelop;

  /// Whether current app is developer mode
  bool _isDevelop = false;

  /// Init client with [preferences]
  ///
  /// The structure of [preferences] likes below.
  /// ```json
  /// {
  ///   "apiUri": Uri of server (e.g. https://example.com),
  ///   "clientId": Client ID of registered OIDC server,
  ///   "clientSecret": Client secret of registered OIDC server,
  ///   "redirectUri": Redirect uri of catch oidc result (e.g. https://example.com/redirect.html),
  ///   "isDevelop": Whether current app is developer mode or not
  /// }
  /// ```
  Future<void> init(Map<String, dynamic> preferences) async {
    _uri = preferences["apiUri"] ?? "";
    final serverUri = preferences["authUri"] ?? "";
    final clientId = preferences["clientId"] ?? "";
    final clientSecret = preferences["clientSecret"] ?? "";
    final redirectUri = preferences["redirectUri"] ?? "";
    _isDevelop = preferences["isDevelop"] ?? false;
    // Initialize
    await oidc.init(
      serverUri: serverUri,
      clientId: clientId,
      clientSecret: clientSecret,
      redirectUri: redirectUri,
    );
    Log.i(_tag, "API Client initialized");
    return;
  }

  /// Login
  Future<User> login() async {
    final user = await oidc.login();
    Log.i(_tag, "Logged in: ${user.email}");
    return user;
  }

  /// Logout
  Future<User> logout() async {
    await oidc.logout();
    Log.i(_tag, "Logged out");
    return User.unknown;
  }

  void onUserChanges(Function(User) listener) {  // TODO: remove
    oidc.manager.userChanges().listen((OidcUser? user) {
      if (user == null) {
        return;
      }
      listener(User.fromOidc(user));
    });
  }

  /// Returns [Uri] of REST API address with [endpoint] and [query]
  Uri buildUri(String endpoint, Map<String, dynamic>? query) {  // TODO: rename
    final split = uri.split(":");
    final host = split[0];
    final port = (split.length > 1) ? int.parse(split[1]) : null;
    return Uri(
      scheme: isDevelop ? "http" : "https",
      host: host,
      port: port,
      path: endpoint,
      queryParameters: query,
    );
  }

  /// Send HTTP request with [method] and [endpoint]
  ///
  /// This returns raw http response. Use [request] or [requestStream] instead.
  ///
  /// [body] is not required and should be a `null` when [method] is [HttpMethod.get].
  /// Otherwise, it is required usually.
  ///
  /// [query] is query parameters
  Future<http.StreamedResponse> _request({
    required HttpMethod method,
    required String endpoint,
    Object? body,
    Map<String, dynamic>? query,
  }) async {
    final uri = buildUri(endpoint, query);final client = http.Client();
    final request = http.Request(method.name.toUpperCase(), uri);
    for(String key in headers.keys) {
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

  /// Send HTTP stream request with [method] and [endpoint]
  ///
  /// Returns [Stream]. Use [request] if completed data is needed.
  ///
  /// [body] is not required and should be a `null` if [method] is [HttpMethod.get].
  /// [query] is query parameter.
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
      result: ApiResultCode.success,
      data: response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .map((line) => json.decode(line) as Map<String, dynamic>),
    );
  }

  /// Send HTTP request with [method] and [endpoint]
  ///
  /// Returns completed data. Use [requestStream] if data stream is needed.
  ///
  /// [body] is not required and should be a `null` if [method] is [HttpMethod.get].
  /// [query] is query parameter.
  Future<ApiResponse> request<T>({
    required HttpMethod method,
    required String endpoint,
    Object? body,
    ApiQuery? query,
  }) async {
    final defaultValue = (method == HttpMethod.get) ? <T>[] : <String, dynamic>{};
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
      result: ApiResultCode.success,
      data: json.decode(utf8.decode(bytes)),
    );
  }

  /// Casts [map] to instance of [T]
  dynamic cast<T>(Map<String, dynamic> map) {
    switch(T) {
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
        throw UnimplementedError();
    }
  }

  /// Casts multiple items in [list] to instances of [T]
  List<T> casts<T>(List list) {
    final data = <T>[];
    for (Map<String, dynamic> map in list) {
      data.add(cast<T>(map));
    }
    return data;
  }

  /// Get api endpoint from type [T]
  ///
  /// Throws [UnimplementedError] if endpoint is not specified yet.
  String endpoint<T>() {
    switch(T) {
      case Account: return Account.endpoint;
      case Payment: return Payment.endpoint;
      case Transaction: return Transaction.endpoint;
      case Category: return Category.endpoint;
      case Currency: return Currency.endpoint;
      case PreferenceElement: return Preference.endpoint;
      default: throw UnimplementedError();
    }
  }

  /// Create [body] using HTTP POST
  ///
  /// [T] must be specified and it is not specified, throws [TypeError].
  Future<ApiResponse<T>> create<T>(Map<String, dynamic> body) async {  // TODO: extends model
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

  /// Read data with [query] using HTTP GET
  ///
  /// [T] must be specified and it is not specified, throws [TypeError].
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

  /// Update [body] using HTTP PUT
  ///
  /// [T] must be specified and it is not specified, throws [TypeError].
  Future<ApiResponse<T>> update<T>(Map<String, dynamic> body) async {  // TODO: extends
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

  /// Delete [body] using HTTP DELETE
  ///
  /// [T] must be specified and it is not specified, throws [TypeError].
  Future<ApiResponse<T>> delete<T>(Map<String, dynamic> body) async {  // TODO: extends
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

  /// Calculate value with [query] using HTTP GET
  ///
  /// [T] must be specified and it is not specified, throws [TypeError].
  /// Below is example of result.
  /// ```json
  /// {
  ///   "total": 0,
  ///   "average": 0,
  ///   "count": 0
  /// }
  /// ```
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

  /// Search [query] using HTTP GET
  ///
  /// [T] must be specified and it is not specified, throws [TypeError].
  Future<ApiResponse<Stream<T>>> search<T>(String query) async {
    if (T == dynamic) {
      throw TypeError();
    }
    final result = await requestStream(
      method: HttpMethod.get,
      endpoint: "${endpoint<T>()}/search",
      query: ApiQuery({
        ApiQuery.keyQueryString: query,
      }),
    );
    return ApiResponse<Stream<T>>(
      result: result.result,
      data: result.data.map((data) => cast<T>(data)),
    );
  }
}

/// HTTP Method
enum HttpMethod {
  get,
  post,
  put,
  patch,
  delete;

  @override
  String toString() => name.toUpperCase();
}

/// A code of result
enum ApiResultCode {  // TODO: rename
  success,
  failed,
  unknown,
}

/// A response of type [T]
class ApiResponse<T> {

  /// Result
  final ApiResultCode result;

  /// Data
  final T data;

  /// Initialize
  ApiResponse({
    required this.result,
    required this.data,
  });

  /// Failed response
  ApiResponse.failed(this.data, [
    this.result = ApiResultCode.failed,
  ]);

  /// Casts [data] as [E] and return new [ApiResponse]
  ApiResponse<E> cast<E>(E data) => ApiResponse<E>(
    result: result,
    data: data,
  );

  /// Casts [data] as List of [E] and return new [ApiResponse]
  ApiResponse<List<E>> casts<E>(List<E> data) => ApiResponse<List<E>>(
    result: result,
    data: data,
  );
}

/// A query parameter
class ApiQuery {

  /// Key of sort fields
  static const String keySortField = "sort_field";

  /// Key of sort orders
  static const String keySortOrder = "sort_order";

  /// Key of query range begin
  static const String keyQueryRangeBegin = "begin";

  /// Key of query range end
  static const String keyQueryRangeEnd = "end";

  /// Key of search query
  static const String keyQueryString = "q";

  final Map<String, dynamic>? conditions;  // TODO: remove

  /// Initialize
  const ApiQuery(this.conditions);

  /// Query parameters
  Map<String, String> get params {
    if (conditions == null) {
      return {};
    }
    final Map<String, String> result = {};
    for(String key in conditions!.keys) {
      var value = conditions![key];
      if (value is List) {
        result[key] =
            value.map((item) => item.toString()).toList(growable: false).join(
                ",");
      } else if (value is Map<String, dynamic>) {
        for (String subkey in value.keys) {
          result["${subkey}_$key"] = value[subkey].toString();
        }
      } else {
        result[key] = value.toString();
      }
    }
    return result;
  }
}

/// A order of sort
///
/// `true` is ascending, `false` is descending.
enum SortOrder {
  asc(true),
  desc(false);

  final bool order;

  const SortOrder(this.order);

  @override
  String toString() => order ? "asc" : "desc";
}