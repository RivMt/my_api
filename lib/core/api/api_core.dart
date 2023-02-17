library my_api;

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:my_api/core/exceptions.dart';
import 'package:my_api/core/log.dart';
import 'package:my_api/core/model/user.dart';
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
enum SortOrderType {
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

class ApiCore {

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

  /// Private instance for Singleton pattern
  static final ApiCore _coreApi = ApiCore._();

  /// Private constructor for [_coreApi]
  ApiCore._();

  /// Factory constructor for singleton pattern
  factory ApiCore() => _coreApi;

  /// Init settings
  ///
  /// [onLoginRequired] triggers when login failed.
  /// [url] is URL of API server. [filename] is location of `json` file
  /// which has url information. One of parameter **MUST** be used among
  /// [url] and [filename].
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
    required String url,
  }) async {
    this.url = url;
    // Authenticate
    user = await loadUser();
    if (!user.isValid) {
      Log.e(_tag, "Failed to connect server: $url");
      onLoginRequired();
    }
    Log.i(_tag, "Connected: $url");
    return;
  }

  /// Send POST request
  Future<ApiResponse<Map<String, dynamic>>> send(ApiMethod method, String link, Map<String, dynamic>? body) async {
    // Url
    final String url = "${this.url}/$link";
    // Send request
    late http.Response response;
    switch(method) {
      case ApiMethod.get:
        response = await http.get(
          Uri.parse(url),
          headers: ApiCore.headers,
        );
        break;
      case ApiMethod.post:
        response = await http.post(
          Uri.parse(url),
          headers: ApiCore.headers,
          body: json.encode(body),
        );
        break;
      case ApiMethod.put:
        response = await http.put(
          Uri.parse(url),
          headers: ApiCore.headers,
          body: json.encode(body),
        );
        break;
      case ApiMethod.patch:
        response = await http.patch(
          Uri.parse(url),
          headers: ApiCore.headers,
          body: json.encode(body),
        );
        break;
      case ApiMethod.delete:
        response = await http.delete(
          Uri.parse(url),
          headers: ApiCore.headers,
          body: json.encode(body),
        );
        break;
    }
    // Check response
    if (response.statusCode != 200) {
      Log.w(_tag, "Failed to request: ${method.name.toUpperCase()}/ $url");
      return ApiResponse(
        result: ApiResultCode.failed,
        data: {},
      );
    }
    // If exception does not thrown
    return ApiResponse(
      result: ApiResultCode.success,
      data: json.decode(response.body),
    );
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
  Future<User> auth(Map<String, dynamic> body) async {
    // Request
    final response = await send(
        ApiMethod.post,
        authPath,
        body,
    );

    // Check result
    if (response.result != ApiResultCode.success) {
      throw RequestFailedException();
    }
    final User user = User(response.data);

    // Check body is not valid
    if (!user.isValid) {
      throw InvalidModelException(User.keyUserSecret);
    }

    // Valid
    saveUser(user);
    return user;
  }

  /// Request [secret] using [email] and [password]
  Future<User> login(String email, String password) async => auth({
    User.keyEmail: email,
    User.keyPassword: password,
  });

  /// Check user data with [id] and [secret] is valid
  Future<User> authenticate(String id, String secret) async => auth({
    User.keyUserId: id,
    User.keyUserSecret: secret,
  });

  /// Register new user
  Future<User> register(User user, String password) async {
    final map = user.map;
    map[User.keyPassword] = password;
    final response = await send(
      ApiMethod.put,
      authPath,
      map
    );
    if (response.result != ApiResultCode.success) {
      return user;
    }
    return auth(map);
  }

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