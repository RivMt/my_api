import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:my_api/src/core/api/api_connector.dart';
import 'package:my_api/src/core/app_mode.dart';
import 'package:my_api/src/core/api/api_query.dart';
import 'package:my_api/src/core/api/api_response.dart';
import 'package:my_api/src/core/api/api_response_result.dart';
import 'package:my_api/src/core/api/http_method.dart';
import 'package:my_api/src/core/log.dart';
import 'package:my_api/src/core/model/user.dart';
import 'package:my_api/src/core/oidc.dart';

const String _tag = "RemoteConnector";

/// Connects to a remote backend using HTTP.
class RemoteConnector implements ApiConnector {
  /// Creates a remote connector.
  RemoteConnector({
    String uri = "",
    AppMode mode = AppMode.production,
    OpenIDConnect? oidc,
  })  : _uri = uri,
        _mode = mode,
        oidc = oidc ?? OpenIDConnect();

  /// Address of the backend server.
  @override
  String get uri => _uri;

  String _uri;

  String _scheme = "https";

  /// Current application mode.
  @override
  AppMode get mode => _mode;

  final AppMode _mode;

  /// OIDC authentication manager.
  final OpenIDConnect oidc;

  /// HTTP headers containing the current authentication token.
  Map<String, String> get headers => {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${oidc.accessToken}",
      };

  @override
  Future<void> init(Map<String, dynamic> preferences) async {
    _uri = preferences["apiUri"] ?? "";
    _scheme = preferences["apiScheme"] ?? "https";
    await oidc.init(
      serverUri: preferences["authUri"] ?? "",
      clientId: preferences["clientId"] ?? "",
      redirectUri: preferences["redirectUri"] ?? "",
    );
    Log.i(_tag, "Remote connector initialized");
  }

  @override
  Future<User> login() async {
    final user = await oidc.login();
    Log.i(_tag, "Logged in: ${user.email}");
    return user;
  }

  @override
  Future<User> logout() async {
    await oidc.logout();
    Log.i(_tag, "Logged out");
    return User.unknown;
  }

  /// Returns the REST API [Uri] for [endpoint] and [query].
  @override
  Uri buildUri(String endpoint, Map<String, dynamic>? query) {
    final split = uri.split(":");
    final host = split[0];
    final port = split.length > 1 ? int.parse(split[1]) : null;
    return Uri(
      scheme: _scheme,
      host: host,
      port: port,
      path: endpoint,
      queryParameters: query?.map(
        (key, value) => MapEntry(
          key,
          value is Iterable ? value.join(",") : value.toString(),
        ),
      ),
    );
  }

  Future<http.StreamedResponse> _request({
    required HttpMethod method,
    required String endpoint,
    Object? body,
    Map<String, dynamic>? query,
  }) async {
    final uri = buildUri(endpoint, query);
    final client = http.Client();
    final request = http.Request(method.name.toUpperCase(), uri);
    for (final entry in headers.entries) {
      request.headers[entry.key] = entry.value;
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
    } on http.ClientException catch (e, s) {
      Log.e(_tag, "Client Exception: $method $uri", e, s);
    }
    return http.StreamedResponse(const Stream.empty(), 400);
  }

  @override
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
      result: ApiResponseResult.success,
      data: response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .map((line) => json.decode(line) as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse> request<T>({
    required HttpMethod method,
    required String endpoint,
    Object? body,
    ApiQuery? query,
  }) async {
    final defaultValue = method == HttpMethod.get ? <T>[] : <String, dynamic>{};
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
      result: ApiResponseResult.success,
      data: json.decode(utf8.decode(bytes)),
    );
  }
}
