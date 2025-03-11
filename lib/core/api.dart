import 'dart:io';
import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:http/http.dart' as http;
import 'package:my_api/core/exceptions.dart';
import 'package:my_api/core/log.dart';
import 'package:my_api/core/model/model_keys.dart';
import 'package:my_api/core/model/user.dart';
import 'package:my_api/core/oidc.dart';
import 'package:my_api/finance/model/account.dart';
import 'package:my_api/finance/model/category.dart';
import 'package:my_api/finance/model/finance_search_result.dart';
import 'package:my_api/finance/model/payment.dart';
import 'package:my_api/core/model/preference.dart';
import 'package:my_api/finance/model/transaction.dart';
import 'package:my_api/finance/model/transaction_raw.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  /// Default header
  static const Map<String, String> headers = {
    "Content-Type": "application/json",
  };

  /// Header key for API key
  static const String keyApiKey = "X-API-Key";

  final OpenIDConnect oidc = OpenIDConnect();

  String _uri = "";

  String get uri => _uri;

  /// Private instance for singleton pattern
  static final ApiClient _instance = ApiClient._();

  /// Private constructor for singleton pattern
  ApiClient._();

  /// Factory constructor for singleton pattern
  factory ApiClient() => _instance;

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
  Future<void> init({
    required Function() onLoginRequired,
    required Map<String, dynamic> preferences,
  }) async {
    final serverUri = preferences["authUri"];
    final clientId = preferences["clientId"];
    final clientSecret = preferences["clientSecret"];
    final redirectUri = preferences["redirectUri"];
    // Initialize
    Log.v(_tag, "Trying to connect: $serverUri");
    oidc.init(
      serverUri: serverUri,
      clientId: clientId,
      clientSecret: clientSecret,
      redirectUri: redirectUri,
    );
    Log.i(_tag, "Connected: $serverUri");
    return;
  }

  Future<User> login() async {
    return await oidc.login();
  }

  /// Send HTTP request to [path] base on [url]
  ///
  /// [method] is instance of [HttpMethod] such as POST or GET. [path] is part
  /// of url like `test` in `http://example.com/test?query=1`. [queries] are
  /// [Map] of query strings. For example, below data converts to `?query=1` in
  /// former sample url.
  /// ```json
  /// {
  ///   "query": 1
  /// }
  /// ```
  /// And [headers] are [Map] of http request header. If it is `null`, default
  /// header is set like below.
  /// ```json
  /// {
  ///   "Content-Type": "application/json"
  /// }
  /// ```
  /// Finally, [body] is content body of http request. If [method] is [HttpMethod.get],
  /// it will not be used.
  Future<ApiResponse<Map<String, dynamic>>> _send({
    required HttpMethod method,
    required String path,
    Map<String, dynamic>? queries,
    Map<String, String> headers = headers,
    Map<String, dynamic>? body,
  }) async {
    // Url
    final StringBuffer sb = StringBuffer();
    sb.write(uri);
    sb.write("/");
    sb.write(path);
    if (queries != null && queries.isNotEmpty) {
      sb.write("?");
      final List args = [];
      for(String key in queries.keys) {
        args.add("$key=${queries[key]}");
      }
      sb.write(args.join("&"));
    }
    final String url = sb.toString();
    // Send request
    late http.Response response;
    try {
      switch (method) {
        case HttpMethod.get:
          response = await http.get(
            Uri.parse(url),
            headers: headers,
          );
          break;
        case HttpMethod.post:
          response = await http.post(
            Uri.parse(url),
            headers: headers,
            body: json.encode(body),
          );
          break;
        case HttpMethod.put:
          response = await http.put(
            Uri.parse(url),
            headers: headers,
            body: json.encode(body),
          );
          break;
        case HttpMethod.patch:
          response = await http.patch(
            Uri.parse(url),
            headers: headers,
            body: json.encode(body),
          );
          break;
        case HttpMethod.delete:
          response = await http.delete(
            Uri.parse(url),
            headers: headers,
            body: json.encode(body),
          );
          break;
      }
    } on SocketException catch(e, s) {
      Log.e(_tag, "Connection failed to $url", e, s);
      return ApiResponse.failed({});
    }
    // Check response
    if (response.statusCode != 200) {
      Log.w(_tag, "${response.statusCode} ${method.name.toUpperCase()} $url");
      return ApiResponse(
        result: ApiResultCode.failed,
        data: {},
      );
    }
    // If exception does not thrown
    Log.v(_tag, "${response.statusCode} ${method.name.toUpperCase()} $url");
    return ApiResponse(
      result: ApiResultCode.success,
      data: json.decode(response.body),
    );
  }

  /// Send API request
  Future<ApiResponse<Map<String, dynamic>>> send({
    required HttpMethod method,
    required String host,
    required String endpoint,
    dynamic body,
    Map<String, dynamic>? queries,
  }) async {
    // Check host name is defined
    if (uri == "") {
      Log.w(_tag, "Host name is not defined yet: ${method.name.toUpperCase()} $host/$endpoint");
      return ApiResponse(
        result: ApiResultCode.failed,
        data: {},
      );
    }
    // Headers
    final Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${oidc.idToken}",
    };
    // Send
    final response = await _send(
      method: method,
      path: "$host/$endpoint",
      queries: queries,
      headers: headers,
      body: body,
    );
    return response;
  }

  /// Get home from [T]
  String home<T>() {
    switch(T) {
      case Account:
      case Payment:
      case Transaction:
      case RawTransaction:
      case Category:
      case FinanceSearchResult:
        return "finance";
      case Preference:
        return "userdata/v1";
      default:
        throw UnimplementedError();
    }
  }

  /// Get path from [T]
  String path<T>() {
    switch(T) {
      case Account:
        return "accounts";
      case Payment:
        return "payments";
      case Transaction:
        return "transactions";
      case Category:
        return "categories";
      case Preference:
        return "preferences";
      case FinanceSearchResult:
        return "search";
      case RawTransaction:
        return "raw";
      default:
        throw UnimplementedError();
    }
  }

  /// Covert [map] to [T]
  dynamic convert<T>(Map<String, dynamic> map, [String key = "data"]) {
    final data = (key == "") ? map : map[key];
    switch(T) {
      case Decimal:
        if (data is! String) {
          return Decimal.zero;
        }
        return Decimal.parse(data);
      case Account:
        return Account(data);
      case Payment:
        return Payment(data);
      case Transaction:
        return Transaction(data);
      case Category:
        return Category(data);
      case Preference:
        return Preference(data);
      case FinanceSearchResult:
        return FinanceSearchResult(data);
      case RawTransaction:
        return RawTransaction(data);
      default:
        throw UnimplementedError();
    }
  }

  /// Covert multiple items in [map] to [T]
  List<T> converts<T>(Map<String, dynamic> map, [String key = "data"]) {
    final List<T> list = [];
    final data = (key == "") ? map : (map[key] ?? []);
    for (Map<String, dynamic> m in data) {
      list.add(convert<T>(m, ""));
    }
    return list;
  }

  /// Create [body] from [link]
  Future<ApiResponse<List<T>>> create<T>(List<Map<String, dynamic>> body) async {
    final result = await send(
      method: HttpMethod.post,
      host: home<T>(),
      endpoint: path<T>(),
      body: body,
    );
    return result.converts<T>(converts<T>(result.data));
  }

  /// Read [data] from [link]
  Future<ApiResponse<List<T>>> read<T>([Map<String, dynamic>? queries]) async {
    final result = await send(
      method: HttpMethod.get,
      host: home<T>(),
      endpoint: path<T>(),
      queries: queries,
    );
    return result.converts<T>(converts<T>(result.data));
  }

  /// Update [body] from [link]
  Future<ApiResponse<List<T>>> update<T>(List<Map<String, dynamic>> body) async {
    final result = await send(
      method: HttpMethod.put,
      host: home<T>(),
      endpoint: path<T>(),
      body: body,
    );
    return result.converts<T>(converts<T>(result.data));
  }

  /// Delete [body] from [link]
  Future<ApiResponse<List<T>>> delete<T>(List<Map<String, dynamic>> body) async {
    final result = await send(
      method: HttpMethod.delete,
      host: home<T>(),
      endpoint: path<T>(),
      body: body,
    );
    return result.converts<T>(converts<T>(result.data));
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
  ApiResponse<E> convert<E>(E data) => ApiResponse<E>(
    result: result,
    data: data,
  );

  /// Covert item in [data] and return new [ApiResponse]
  ApiResponse<List<E>> converts<E>(List<E> data) => ApiResponse<List<E>>(
    result: result,
    data: data,
  );

}