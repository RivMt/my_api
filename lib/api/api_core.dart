library my_api;

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:my_api/exceptions.dart';
import 'package:my_api/log.dart';

/// TAG for log
const String _tag = "Core";

/// Raise exception by [code]
void checkCode(int code, String url) {
  switch(code) {
    case 200:
      break;
    case 301:
      throw RequestedUriChangedException(url);
    case 400:
      throw RequestInvalidException(url);
    case 401:
      throw RequestNonAuthenticatedException(url);
    case 405:
      throw RequestPermissionDeniedException(url);
    case 500:
      throw RequestErrorException(url);
    default:
      throw UnimplementedError();
  }
}

class ApiClient {

  /// Base header of all requests
  static const Map<String, String> headers = {
    "Content-Type": "application/json",
  };

  /// Base url of server
  String url = "";

  /// User ID
  String id = "";

  /// Session for currently connected user
  final ApiSession session = ApiSession(url: "", id: '');

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
  }) {
    this.url = url;
    this.id = id;
    if (!session.valid) {
      session.set(
        url: url,
        id: id,
      );
      session.refresh(""); //TODO: Input hash
    }
  }

  /// Send POST request
  Future<Map<String, dynamic>> post(String link, Map<String, dynamic>? body) async {
    // Url
    final String url = "${this.url}/$link";
    // Send request
    http.Response response = await http.post(
      Uri.parse(url),
      headers: ApiClient.headers,
      body: json.encode(body),
    );
    // Check response
    checkCode(response.statusCode, url);
    // If exception does not thrown
    return json.decode(response.body);
  }

}

class ApiSession {

  /// Base url of server
  String url = "";

  /// User ID
  String id = "";

  /// User secret key
  String secret = "";

  /// Duration of [secret] is available
  DateTime validation = DateTime.now();

  ApiSession({
    required String url,
    required String id,
  }) {
    set(
      url: url,
      id: id,
    );
  }

  /// This session is valid when [secret] is not empty string and [validation]
  /// has still left time
  bool get valid => (secret != "" && DateTime.now().compareTo(validation) < 0);

  /// Set [url] and [id] to request [secret]
  void set({
    required String url,
    required String id,
  }) {
    this.url = url;
    this.id = id;
  }

  /// Request [secret] using [hash]
  void refresh(String hash) async {
    final String url = "${this.url}/auth";
    // Request
    final response = await http.post(Uri.parse(url),
      body: {
        "user_id": id,
        "hash": hash,
      }
    );

    // Check status code is error
    try {
      checkCode(response.statusCode, url);
    } on Exception catch (_) {
      Log.e(_tag, "Exception");
      return;
    } on Error catch (_) {
      Log.e(_tag, "Error");
      return;
    }

    // Check body is valid
    final Map<String, dynamic> map = json.decode(response.body);
    if (map.containsKey("user_secret")) {
      secret = map["user_secret"];
      return;
    }

    // Error
    throw InvalidModelException("user_secret");
  }

}