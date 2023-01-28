library my_api;

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:my_api/src/exceptions.dart';
import 'package:my_api/src/log.dart';
import 'package:my_api/src/model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// TAG for log
const String _tag = "Core";

/// HTTP Method
enum ApiMethod {
  get,
  post,
  put,
  patch,
  delete,
}

/// Types of DB sort order
enum OrderType {
  asc,
  desc,
}

/// Types of DB calculation query
enum CalculationType {
  sum,
  avg,
  max,
  min,
}

/// Raise exception by [code]
void checkCode(int code, String url) {
  switch(code) {
    case 200:
      break;
    case 301:
      throw UriChangedException(url);
    case 400:
      throw RequestInvalidException(url);
    case 401:
      throw NotAuthenticatedException(url);
    case 405:
      throw PermissionDeniedException(url);
    case 500:
      throw HttpErrorException(url);
    default:
      throw UnimplementedError();
  }
}

class ApiClient {

  /// Key of user id for [SharedPreferences]
  static const String keyPreferencesUserId = "api-user-id";

  /// Key of user secrets for [SharedPreferences]
  static const String keyPreferencesUserSecret = "api-user-secret";

  /// Base header of all requests
  static const Map<String, String> headers = {
    "Content-Type": "application/json",
  };

  /// Base url of server
  String url = "";

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

  /// Private instance for Singleton pattern
  static final ApiClient _coreApi = ApiClient._();

  /// Private constructor for [_coreApi]
  ApiClient._();

  /// Factory constructor for singleton pattern
  factory ApiClient() => _coreApi;

  /// Init settings
  ///
  /// Throws [NullThrownError] when user data does not exists.
  /// Throws [NotAuthenticatedException] when re-login required
  Future<void> init({
    required Function() onLoginRequired,
  }) async {
    // Read server data
    final String data = await rootBundle.loadString('key/server.json');
    final json = jsonDecode(data);
    url = json["url"];
    // Authenticate
    user = await loadUser();
    if (!user.valid) {
      Log.e(_tag, "Failed to login");
      onLoginRequired();
    }
    Log.i(_tag, "Login successful: ${user.email}");
    return;
  }

  /// Send POST request
  Future<Map<String, dynamic>> send(ApiMethod method, String link, Map<String, dynamic>? body) async {
    // Url
    final String url = "${this.url}/$link";
    // Send request
    late http.Response response;
    switch(method) {
      case ApiMethod.get:
        response = await http.get(
          Uri.parse(url),
          headers: ApiClient.headers,
        );
        break;
      case ApiMethod.post:
        response = await http.post(
          Uri.parse(url),
          headers: ApiClient.headers,
          body: json.encode(body),
        );
        break;
      case ApiMethod.put:
        response = await http.put(
          Uri.parse(url),
          headers: ApiClient.headers,
          body: json.encode(body),
        );
        break;
      case ApiMethod.patch:
        response = await http.patch(
          Uri.parse(url),
          headers: ApiClient.headers,
          body: json.encode(body),
        );
        break;
      case ApiMethod.delete:
        response = await http.delete(
          Uri.parse(url),
          headers: ApiClient.headers,
          body: json.encode(body),
        );
        break;
    }
    // Check response
    checkCode(response.statusCode, url);
    // If exception does not thrown
    return json.decode(response.body);
  }

  /// Save user id and secret
  void saveUser(User user) async {
    if (!user.valid) {
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
  Future<User> auth(Map<String, dynamic> body) async {
    // Request
    final response = await send(
        ApiMethod.post,
        "auth/v1/users",
        body,
    );
    final User user = User(response);

    // Check body is not valid
    if (!user.valid) {
      throw InvalidModelException(User.keyUserSecret);
    }

    // Valid
    saveUser(user);
    return user;
  }

  /// Request [secret] using [password]
  Future<User> login(String email, String password) async => auth({
    "user_email": email,
    "user_password": password,
  });

  /// Check user data is valid
  Future<User> authenticate(String id, String secret) async => auth({
    "user_id": id,
    "user_secret": secret,
  });

  /// Build options
  Map<String, dynamic> buildOptions({
    // Calculation
    CalculationType? calcType,
    String? calcAttribute,
    // Order
    OrderType? orderType,
    String? orderAttribute,
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
    // Order
    if (orderType != null && orderAttribute != null) {
      map["order"] = {
        "type": orderType.name.toUpperCase(),
        "attr": orderAttribute,
      };
    }
    // Limits
    if (limit != null) {
      map["limit"] = limit;
    }
    return map;
  }

}

enum ApiResultCode {
  success,
  failed,
  unknown,
}

class ApiResponse<T> {

  final ApiResultCode result;

  final T data;

  ApiResponse({
    required this.result,
    required this.data,
  });

}