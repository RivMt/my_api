import 'dart:io';
import 'dart:convert';
import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
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
  Uri buildUri(String endpoint, Map<String, dynamic>? queries) {
    final split = uri.split(":");
    final host = split[0];
    final port = (split.length > 1) ? int.parse(split[1]) : null;
    return Uri(
      scheme: kDebugMode ? "http" : "https",
      host: host,
      port: port,
      path: endpoint,
      queryParameters: queries,
    );
  }

  /// Request API
  Future<ApiResponse<Stream>> request<T>({
    required HttpMethod method,
    required String endpoint,
    dynamic body,
    ApiQuery? query,
  }) async {
    final uri = buildUri(endpoint, query?.queries);
    final client = http.Client();
    final request = http.Request(method.name.toUpperCase(), uri);
    for(String key in headers.keys) {
      request.headers[key] = headers[key]!;
    }
    final response = await client.send(request);
    if (response.statusCode != 200) {
      Log.w(_tag, "${response.statusCode} ${method.name.toUpperCase()} $uri");
      return ApiResponse.failed(const Stream.empty());
    }
    Log.v(_tag, "${response.statusCode} ${method.name.toUpperCase()} $uri");
    return ApiResponse(
      result: ApiResultCode.success,
      data: response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .map((line) => json.decode(line) as Map<String, dynamic>),
    );
  }

  /// Send API call
  Future<ApiResponse> send<T>(
    HttpMethod method,
    String endpoint, [
    dynamic body,
    ApiQuery? queries,
  ]) async {
    final defaultValue = (method == HttpMethod.get) ? <T>[] : <String, dynamic>{};
    // Check host name is defined
    if (uri == "") {
      Log.w(_tag, "Host name is not defined yet: ${method.name.toUpperCase()} $uri/$endpoint");
      return ApiResponse.failed(defaultValue);
    }
    final url = buildUri(endpoint, queries?.queries);
    // Send request
    late http.Response response;
    try {
      switch (method) {
        case HttpMethod.get:
          response = await http.get(
            url,
            headers: headers,
          );
          break;
        case HttpMethod.post:
          response = await http.post(
            url,
            headers: headers,
            body: json.encode(body),
          );
          break;
        case HttpMethod.put:
          response = await http.put(
            url,
            headers: headers,
            body: json.encode(body),
          );
          break;
        case HttpMethod.patch:
          response = await http.patch(
            url,
            headers: headers,
            body: json.encode(body),
          );
          break;
        case HttpMethod.delete:
          response = await http.delete(
            url,
            headers: headers,
            body: json.encode(body),
          );
          break;
      }
    } on SocketException catch(e, s) {
      Log.e(_tag, "Connection failed to $url", e, s);
      return ApiResponse.failed(defaultValue);
    }
    // Check response
    if (response.statusCode != 200) {
      Log.w(_tag, "${response.statusCode} ${method.name.toUpperCase()} $url");
      return ApiResponse.failed(defaultValue);
    }
    // If exception does not thrown
    Log.v(_tag, "${response.statusCode} ${method.name.toUpperCase()} $url");
    return ApiResponse(
      result: ApiResultCode.success,
      data: json.decode(utf8.decode(response.bodyBytes)),
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
    final result = await send<T>(HttpMethod.post, endpoint<T>(), body);
    return result.cast<T>(cast<T>(result.data));
  }

  /// Read [currency] from [link]
  Future<ApiResponse<List<T>>> read<T>([Map<String, dynamic>? queries]) async {
    if (T == dynamic) {
      throw TypeError();
    }
    final result = await send<T>(HttpMethod.get, endpoint<T>(), null, ApiQuery(queries));
    return result.casts<T>(casts<T>(result.data));
  }

  /// Update [body] from [link]
  Future<ApiResponse<T>> update<T>(Map<String, dynamic> body) async {
    if (T == dynamic) {
      throw TypeError();
    }
    final result = await send<T>(HttpMethod.put, endpoint<T>(), body);
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
    final result = await send<T>(HttpMethod.delete, "${endpoint<T>()}/$uuid");
    return result.cast<T>(cast<T>(result.data));
  }

  /// Calculate value by [queries]
  Future<ApiResponse<Map<String, Decimal>>> stat<T>([ApiQuery? queries]) async {
    if (T == dynamic) {
      throw TypeError();
    }
    final result = await send(HttpMethod.get, "${endpoint<T>()}/stat", null, queries);
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
    final result = await request(
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
  delete,
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

  Map<String, String> get queries {
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