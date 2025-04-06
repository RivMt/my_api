import 'dart:io';
import 'dart:convert';
import 'dart:math';
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

/// Send and receive HTTP request
///
/// Send API call and convert data properly which is raw received HTTP response.
/// It also handles authentication and login using [login] and [auth] method.
///
/// Generally, using [init] method to login or authenticate [User]. And process of
/// creating, updating and deleting can be done by [create], [update] and [delete].
/// It is possible that using [read] to get data from server, however, use
/// [ModelState] alternatively, to manage widgets' state easily.
class ApiClient {

  /// Header key for API key
  static const String keyApiKey = "X-API-Key";

  /// Private instance for singleton pattern
  static final ApiClient _instance = ApiClient._();

  /// Private constructor for singleton pattern
  ApiClient._();

  /// Factory constructor for singleton pattern
  factory ApiClient() => _instance;

  final OpenIDConnect oidc = OpenIDConnect();

  String _uri = "";

  String get uri => _uri;

  /// HTTP request headers
  Map<String, String> get headers => {
    "Content-Type": "application/json",
    "Authorization": "Bearer ${oidc.idToken}",
  };

  /// Value of current app is developer mode or not
  bool get isDevelop => _isDevelop;

  bool _isDevelop = false;

  /// Init
  ///
  /// Initiate server connection. If login is required, [onLoginRequired]
  /// will be triggered.
  ///
  /// [preferences] are `json` data of server addresses.
  ///
  /// You can select `Production` and `Test` server using [useTest]. If it
  /// is `null`, server will be selected by [kDebugMode]. Otherwise, follow its
  /// value.
  ///
  /// The structure of `json` file like below.
  /// ```json
  /// {
  ///   "url": PRODUCTION-SERVER-ADDRESS,
  ///   "test": TEST-SERVER-ADDRESS
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

  Future<User> login() async {
    final user = await oidc.login();
    Log.i(_tag, "Logged in: ${user.email}");
    return user;
  }

  void onUserChanges(Function(User) listener) {
    oidc.manager.userChanges().listen((OidcUser? user) {
      if (user == null) {
        return;
      }
      listener(User.fromOidc(user));
    });
  }

  /// Build uri
  Uri buildUri(String endpoint, Map<String, dynamic>? query) {
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

  /// Make HTTP request
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

  /// Request API Stream
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

  /// Send API call
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

  /// Covert [map] to [T]
  dynamic cast<T>(Map<String, dynamic> data) {
    switch(T) {
      case Account:
        return Account(data);
      case Payment:
        return Payment(data);
      case Transaction:
        return Transaction(data);
      case Category:
        return Category(data);
      case Currency:
        return Currency(data);
      case PreferenceElement:
        return PreferenceElement.fromMap(PreferenceDummy(), data);
      default:
        throw UnimplementedError();
    }
  }

  /// Covert multiple items in [map] to [T]
  List<T> casts<T>(List list) {
    final data = <T>[];
    for (Map<String, dynamic> map in list) {
      data.add(cast<T>(map));
    }
    return data;
  }

  /// Parse endpoint from generic type
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

  /// Create [body] from [link]
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

  /// Read [currency] from [link]
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

  /// Update [body] from [link]
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

  /// Delete [body] from [link]
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

  /// Calculate value by [query]
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

  /// Search query
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

enum ApiResultCode {
  success,
  failed,
  unknown,
}

class ApiResponse<T> {

  /// Result
  final ApiResultCode result;

  /// Data
  final T data;

  ApiResponse({
    required this.result,
    required this.data,
  });

  ApiResponse.failed(this.data, [
    this.result = ApiResultCode.failed,
  ]);

  /// Covert item in [data] and return new [ApiResponse]
  ApiResponse<E> cast<E>(E data) => ApiResponse<E>(
    result: result,
    data: data,
  );

  /// Covert item in [data] and return new [ApiResponse]
  ApiResponse<List<E>> casts<E>(List<E> data) => ApiResponse<List<E>>(
    result: result,
    data: data,
  );
}

class ApiQuery {

  static const String keySortField = "sort_field";

  static const String keySortOrder = "sort_order";

  static const String keyQueryRangeBegin = "begin";

  static const String keyQueryRangeEnd = "end";

  static const String keyQueryString = "q";

  final Map<String, dynamic>? conditions;

  const ApiQuery(this.conditions);

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

enum SortOrder {
  asc(true),
  desc(false);

  final bool order;

  const SortOrder(this.order);

  @override
  String toString() => order ? "asc" : "desc";
}