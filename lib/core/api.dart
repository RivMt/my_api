import 'dart:io';
import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:http/http.dart' as http;
import 'package:my_api/core/log.dart';
import 'package:my_api/core/model/user.dart';
import 'package:my_api/core/oidc.dart';
import 'package:my_api/finance/model/account.dart';
import 'package:my_api/finance/model/category.dart';
import 'package:my_api/finance/model/finance_search_result.dart';
import 'package:my_api/finance/model/payment.dart';
import 'package:my_api/core/model/preference.dart';
import 'package:my_api/finance/model/transaction.dart';
import 'package:my_api/finance/model/transaction_raw.dart';

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
    _uri = preferences["apiUri"];
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

  /// Send API request
  Future<ApiResponse> send(
    HttpMethod method,
    String endpoint, [
    dynamic body,
    ApiQuery? queries,
  ]) async {
    // Check host name is defined
    if (uri == "") {
      Log.w(_tag, "Host name is not defined yet: ${method.name.toUpperCase()} $uri/$endpoint");
      return ApiResponse.failed({});
    }
    final url = Uri.https(uri, endpoint, queries?.queries);
    // Headers
    final Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${oidc.idToken}",
    };
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

  /// Get path from [T]
  static String endpoint<T>() {
    switch(T) {
      case Account:
        return "api/finance/accounts";
      case Payment:
        return "api/finance/payments";
      case Transaction:
        return "api/finance/transactions";
      case Category:
        return "api/finance/categories";
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

  /// Create [body] from [link]
  Future<ApiResponse<T>> create<T>(Map<String, dynamic> body) async {
    final result = await send(HttpMethod.post, endpoint<T>(), body);
    return result.convert<T>(result.data);
  }

  /// Read [data] from [link]
  Future<ApiResponse<List<T>>> read<T>([Map<String, dynamic>? queries]) async {
    final result = await send(HttpMethod.get, endpoint<T>(), null, ApiQuery(queries));
    return result.converts<T>(result.data);
  }

  /// Update [body] from [link]
  Future<ApiResponse<T>> update<T>(Map<String, dynamic> body) async {
    final result = await send(HttpMethod.put, endpoint<T>(), body);
    return result.convert<T>(result.data);
  }

  /// Delete [body] from [link]
  Future<ApiResponse<T>> delete<T>(String uuid) async {
    final result = await send(HttpMethod.delete, "${endpoint<T>()}/$uuid");
    return result.convert<T>(result.data);
  }

  /// Read [data] from [link]
  Future<ApiResponse<Map<String, Decimal>>> stat<T>([ApiQuery? queries]) async {
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

class ApiQuery {

  static const String keySortField = "sort_field";

  static const String keySortOrder = "sort_order";

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