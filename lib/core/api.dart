import 'dart:io';
import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:http/http.dart' as http;
import 'package:my_api/core/exceptions.dart';
import 'package:my_api/core/log.dart';
import 'package:my_api/core/model/model_keys.dart';
import 'package:my_api/core/model/user.dart';
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

  /// Key of user id for [SharedPreferences]
  static String get keyPreferencesUserId {
    const tail = kDebugMode ? "-test" : "";
    return "api-user-id$tail";
  }

  /// Key of user secrets for [SharedPreferences]
  static String get keyPreferencesUserSecret {
    const tail = kDebugMode ? "-test" : "";
    return "api-user-secret$tail";
  }

  /// User agent
  static const String userAgent = "MyAPI-Client";

  /// Default header
  static const Map<String, String> headers = {
    "Content-Type": "application/json",
    "User-Agent": userAgent,
  };

  /// Header key for API key
  static const String keyApiKey = "X-API-Key";

  /// Getter of [_serverType]
  ServerType get serverType => _serverType;

  /// Type of currently connected server
  ServerType _serverType = ServerType.unknown;

  /// Base url of server
  String url = "";

  /// Base path of authentication
  String authPath = "auth/v1/users";

  /// User ID
  String get id => user.userId;

  /// User secret key
  String get secret => user.userSecret;

  /// Duration of [secret] is available
  DateTime validation = DateTime.now();

  /// This session is valid when [secret] is not empty string and [validation]
  /// has still left time
  bool get valid => (secret != "" && DateTime.now().compareTo(validation) < 0);

  /// [User] who currently logged in
  User user = User({});

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
    bool? useTest,
  }) async {
    // Check json file
    if (!preferences.containsKey("url") || !preferences.containsKey("test")) {
      throw const FileSystemException("Key 'url' or 'test' does not exists.");
    }
    // Load url from json
    final bool setup = useTest ?? kDebugMode;
    url = setup ? preferences["test"]! : preferences["url"]!;
    Log.v(_tag, "Trying to connect: $url");
    _serverType = setup ? ServerType.test : ServerType.production;
    // Authenticate
    user = await loadUser();
    if (!user.isValid) {
      Log.e(_tag, "Failed to connect server: $url");
      onLoginRequired();
      return;
    }
    Log.i(_tag, "Connected: $url");
    return;
  }

  /// Save user id and secret
  void saveUser(User user) async {
    if (!user.isValid) {
      return;
    }
    Log.v(_tag, "Userdata saved: ${user.userId}");
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyPreferencesUserId, user.userId);
    await prefs.setString(keyPreferencesUserSecret, user.userSecret);
  }

  /// Load user
  Future<User> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final String id = prefs.getString(keyPreferencesUserId)!;
      final String secret = prefs.getString(keyPreferencesUserSecret)!;
      Log.v(_tag, "Userdata loaded: $id");
      return await authenticate(id, secret);
    } on Error catch(e) {
      Log.e(_tag, "Error: $e");
    }
    return User({});
  }

  /// Send authenticate request using [body]
  Future<User> auth(Map<String, dynamic> body, [Map<String, String>? headers]) async {
    // Request
    final response = await _send(
      method: HttpMethod.post,
      link: authPath,
      headers: headers ?? ApiClient.headers,
      body: body,
    );

    // Check result
    if (response.result != ApiResultCode.success) {
      throw RequestFailedException();
    }
    final User user = User(response.data);

    // Check body is not valid
    if (!user.isValid) {
      throw InvalidModelException(ModelKeys.keyUserSecret);
    }

    // Valid
    saveUser(user);
    return user;
  }

  /// Request [secret] using [email] and [password]
  Future<User> login(String email, String password) async => auth({
    ModelKeys.keyEmail: email,
    ModelKeys.keyPassword: password,
  });

  /// Check user data with [id] and [secret] is valid
  Future<User> authenticate(String id, String secret) async {
    Map<String, String> map = Map.from(headers);
    map[keyApiKey] = secret;
    return auth({
      ModelKeys.keyUserId: id,
    }, map);
  }

  /// Register new user
  Future<User> register(User user, String password) async {
    final map = user.map;
    map[ModelKeys.keyPassword] = password;
    final response = await _send(
      method: HttpMethod.put,
      link: authPath,
      body: map,
    );
    if (response.result != ApiResultCode.success) {
      return user;
    }
    return auth(map);
  }

  /// Send HTTP request to [link] base on [url]
  ///
  /// [method] is instance of [HttpMethod] such as POST or GET. [link] is part
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
    required String link,
    Map<String, dynamic>? queries,
    Map<String, String> headers = headers,
    Map<String, dynamic>? body,
  }) async {
    // Url
    final StringBuffer sb = StringBuffer();
    sb.write(this.url);
    sb.write("/");
    sb.write(link);
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
    required String home,
    required String path,
    required List<Map<String, dynamic>> data,
    Map<String, dynamic>? options,
    Map<String, dynamic>? queries,
  }) async {
    // Check host name is defined
    if (url == "") {
      Log.w(_tag, "Host name is not defined yet: ${method.name.toUpperCase()} $home/$path");
      return ApiResponse(
        result: ApiResultCode.failed,
        data: {},
      );
    }
    // Headers
    final Map<String, String> headers = {
      "Content-Type": "application/json",
      "User-Agent": userAgent,
      keyApiKey: secret,
    };
    // Body
    final Map<String, dynamic> body = {
      "user_id": id,
      "now": DateTime.now().toIso8601String(),
      "data": data,
    };
    // Options
    if (options != null) {
      body['options'] = options;
    }
    // Send
    final response = await _send(
      method: method,
      link: "$home/$path",
      queries: queries,
      headers: headers,
      body: body,
    );
    return response;
  }

  /// Build options
  static Map<String, dynamic> buildOptions({
    // Calculation
    CalculationType? calcType,
    String? calcAttribute,
    // Sort Order
    List<Sort>? sorts,
    // Limit
    int? limit,
  }) {
    final Map<String, dynamic> map = {};
    // Calc
    if (calcType != null && calcAttribute != null) {
      map["calc"] = {
        "type": calcType.name.toUpperCase(),
        "attr": calcAttribute,
      };
    }
    // Sort Order
    if (sorts != null && sorts.isNotEmpty) {
      map["order"] = {
        "type": List.generate(sorts.length, (index) => sorts[index].type.name.toUpperCase()),
        "attr": List.generate(sorts.length, (index) => sorts[index].attr),
      };
    }
    // Limits
    if (limit != null) {
      map["limit"] = limit;
    }
    return map;
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
        return "finance/v1";
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

  /// Create [data] from [link]
  Future<ApiResponse<List<T>>> create<T>(List<Map<String, dynamic>> data) async {
    final result = await send(
      method: HttpMethod.put,
      home: home<T>(),
      path: path<T>(),
      data: data,
    );
    return result.converts<T>(converts<T>(result.data));
  }

  /// Read [data] from [link]
  Future<ApiResponse<List<T>>> read<T>(List<Map<String, dynamic>> data, [Map<String, dynamic>? options, Map<String, dynamic>? queries]) async {
    final result = await send(
      method: HttpMethod.post,
      home: home<T>(),
      path: path<T>(),
      data: data,
      options: options,
      queries: queries,
    );
    return result.converts<T>(converts<T>(result.data));
  }

  /// Update [data] from [link]
  Future<ApiResponse<List<T>>> update<T>(List<Map<String, dynamic>> data) async {
    final result = await send(
      method: HttpMethod.patch,
      home: home<T>(),
      path: path<T>(),
      data: data,
    );
    return result.converts<T>(converts<T>(result.data));
  }

  /// Delete [data] from [link]
  Future<ApiResponse<List<T>>> delete<T>(List<Map<String, dynamic>> data) async {
    final result = await send(
      method: HttpMethod.delete,
      home: home<T>(),
      path: path<T>(),
      data: data,
    );
    return result.converts<T>(converts<T>(result.data));
  }

  /// Request calculation result which fits to [data]
  ///
  /// [calc] defines type of calculation. And [attribute] defines column name
  /// which is calculated
  Future<ApiResponse<Decimal>> calculate<T>(
    List<Map<String, dynamic>> data,
    CalculationType calc,
    String attribute, [
      Map<String, dynamic>? queries,
  ]) async {
    final result = await send(
      method: HttpMethod.post,
      home: home<T>(),
      path: path<T>(),
      data: data,
      options: buildOptions(
        calcType: calc,
        calcAttribute: attribute,
      ),
      queries: queries,
    );
    return result.convert<Decimal>(convert<Decimal>(result.data));
  }

  /// Get preference value from [key]
  ///
  /// If [SharedPreference] does not have value about [key], it requests
  /// API server to get value and save to local. And that request also failed,
  /// return [Preference] instance that has [defaultValue].
  Future<Preference> getPreference(String key, dynamic defaultValue) async {
    // Check local preference has value
    final prefs = await SharedPreferences.getInstance();
    final local = prefs.getString(key);
    if (local != null) {
      Log.i("GetPref", "Get preference $key=$local from local strorage");
      return Preference.fromKV({},
        key: key,
        value: local,
      );
    }
    // If not exists, send request to API server
    final response = await read<Preference>([{
      ModelKeys.keyKey: key,
    }]);
    if (response.result == ApiResultCode.success && response.data.length == 1) {
      final value = response.data[0];
      // Save to local
      Log.i("GetPref", "Get preference $key=${value.rawValue} from API server");
      prefs.setString(key, value.rawValue);
      return value;
    }
    // Otherwise, return default
    Log.w("GetPref", "Unable to find $key from anywhere");
    return Preference.fromKV({},
      key: key,
      value: defaultValue,
    );
  }

  /// Set [value] about [key]
  ///
  /// It request to save [pref] to server. If it failed, don't save to local
  /// storage. It only save [pref] to local storage when request succeed.
  ///
  /// This process is required to idealize local and server.
  Future<ApiResponse<Preference>> setPreference(Preference pref) async {
    // Save in server first
    final response = await create<Preference>([pref.map]);
    if (response.result != ApiResultCode.success || response.data.length != 1) {
      // If failed, return failed response
      return response.convert(Preference.unknown);
    }
    // Save local
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(pref.key, pref.rawValue);
    //
    return response.convert(response.data[0]);
  }
}

/// Type of server
enum ServerType {
  unknown,
  test,
  production,
}

/// HTTP Method
enum HttpMethod {
  get,
  post,
  put,
  patch,
  delete,
}

/// Types of DB sort order
enum SortType {
  asc,
  desc,
}

/// Data class which has type of sort and attribute.
class Sort {

  const Sort(this.attr, this.type);

  /// Type of sort order
  final SortType type;

  /// Attribute to sort
  final String attr;

}

/// Types of DB calculation query
enum CalculationType {
  sum,
  avg,
  max,
  min,
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