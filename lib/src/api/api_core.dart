library my_api;

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:my_api/src/exceptions.dart';
import 'package:my_api/src/log.dart';
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

  /// Key of user secrets for [SharedPreferences]
  static const String keyPreferencesSecret = "api-secret";

  /// Base header of all requests
  static const Map<String, String> headers = {
    "Content-Type": "application/json",
  };

  /// Base url of server
  String url = "";

  /// User ID
  String id = "";

  /// User secret key
  String secret = "";

  /// Duration of [secret] is available
  DateTime validation = DateTime.now();

  /// This session is valid when [secret] is not empty string and [validation]
  /// has still left time
  bool get valid => (secret != "" && DateTime.now().compareTo(validation) < 0);

  /// Private instance for Singleton pattern
  static final ApiClient _coreApi = ApiClient._();

  /// Private constructor for [_coreApi]
  ApiClient._();

  /// Factory constructor for singleton pattern
  factory ApiClient() => _coreApi;

  /// Set [url] and [id] to connect server
  void set({
    required String url,
    required String id,
  }) async {
    this.url = url;
    this.id = id;
    // Get secret
    final prefs = await SharedPreferences.getInstance();
    final String? result = await prefs.get(keyPreferencesSecret);
    if (result == null) {
      throw NullThrownError();
    } else {
      secret = result;
    }
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

  /// Request [secret] using [password]
  Future<bool> authenticate(String password) async {
    final String url = "${this.url}/auth/v1/user";
    // Request
    final response = await http.post(Uri.parse(url),
        body: {
          "user_id": id,
          "user_password": password,
        }
    );

    // Check status code is error
    try {
      checkCode(response.statusCode, url);
    } on Exception catch (_) {
      Log.e(_tag, "Exception");
      return false;
    } on Error catch (_) {
      Log.e(_tag, "Error");
      return false;
    }

    // Check body is valid
    final Map<String, dynamic> map = json.decode(response.body);
    if (map.containsKey("user_secret")) {
      secret = map["user_secret"];
      // Save
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(keyPreferencesSecret, secret);
      return true;
    }

    // Error
    throw InvalidModelException("user_secret");
  }

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