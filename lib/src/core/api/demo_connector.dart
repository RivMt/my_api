import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:my_api/src/core/api/api_connector.dart';
import 'package:my_api/src/core/app_mode.dart';
import 'package:my_api/src/core/api/api_query.dart';
import 'package:my_api/src/core/api/api_response.dart';
import 'package:my_api/src/core/api/api_response_result.dart';
import 'package:my_api/src/core/api/demo_storage.dart';
import 'package:my_api/src/core/api/http_method.dart';
import 'package:my_api/src/core/log.dart';
import 'package:my_api/src/core/model/user.dart';

const String _tag = "DemoConnector";

/// Transforms items loaded from a demo endpoint before they are persisted.
typedef DemoDataTransformer = List<Map<String, dynamic>> Function(
  List<Map<String, dynamic>> items,
);

/// Loads static seed assets and provides local API behavior without authentication.
class DemoConnector implements ApiConnector {
  /// Base URI used to represent demo API resources.
  static final Uri demoUri = Uri.base.resolve("assets/assets/demo");

  /// Creates a demo connector.
  DemoConnector({
    required Iterable<String> endpoints,
    Map<String, DemoDataTransformer> transformers = const {},
    DemoStorage? storage,
    http.Client? client,
    Uri? baseUri,
  })  : endpoints = List.unmodifiable(endpoints),
        transformers = Map.unmodifiable(transformers),
        storage = storage ?? DemoStorage(),
        _client = client ?? http.Client(),
        _baseUri = baseUri ?? demoUri;

  /// API endpoints loaded from demo assets during login.
  final List<String> endpoints;

  /// Endpoint-specific transformations selected by the host application.
  final Map<String, DemoDataTransformer> transformers;

  /// Local backend storage.
  final DemoStorage storage;

  final http.Client _client;

  final Uri _baseUri;

  @override
  String get uri => _baseUri.toString();

  @override
  AppMode get mode => AppMode.demo;

  @override
  Uri buildUri(String endpoint, Map<String, dynamic>? query) =>
      _baseUri.replace(
        pathSegments: [
          ..._baseUri.pathSegments.where((segment) => segment.isNotEmpty),
          endpoint.split("/").lastWhere((segment) => segment.isNotEmpty),
        ],
        queryParameters: query?.map(
          (key, value) => MapEntry(
            key,
            value is Iterable ? value.join(",") : value.toString(),
          ),
        ),
      );

  @override
  Future<void> init(Map<String, dynamic> preferences) async {
    await storage.init();
    Log.i(_tag, "Demo connector initialized");
  }

  @override
  Future<User> login() async {
    await storage.init();
    final responses = await Future.wait(endpoints.map(_getJson));
    for (var index = 0; index < endpoints.length; index++) {
      final data = responses[index];
      if (data is! List) {
        throw const FormatException(
            "Demo table asset must contain a JSON list.");
      }
      final endpoint = endpoints[index];
      final items =
          data.map((item) => Map<String, dynamic>.from(item as Map)).toList();
      await storage.seed(
          endpoint, transformers[endpoint]?.call(items) ?? items);
    }
    return User.demo;
  }

  @override
  Future<User> logout() async => User.unknown;

  @override
  Future<ApiResponse> request<T>({
    required HttpMethod method,
    required String endpoint,
    Object? body,
    ApiQuery? query,
  }) async {
    final defaultValue = method == HttpMethod.get ? <T>[] : <String, dynamic>{};
    try {
      final data = switch (method) {
        HttpMethod.get when endpoint.endsWith("/stats") =>
          await storage.stats(endpoint, query?.params),
        HttpMethod.get => await storage.read(endpoint, query?.params),
        HttpMethod.post => await storage.create(endpoint, _bodyMap(body)),
        HttpMethod.put ||
        HttpMethod.patch =>
          await storage.update(endpoint, _bodyMap(body)),
        HttpMethod.delete => await storage.delete(endpoint),
      };
      return ApiResponse(result: ApiResponseResult.success, data: data);
    } catch (error, stackTrace) {
      Log.e(_tag, "Demo request failed: $method $endpoint", error, stackTrace);
      return ApiResponse.failed(defaultValue);
    }
  }

  @override
  Future<ApiResponse<Stream>> requestStream<T>({
    required HttpMethod method,
    required String endpoint,
    Object? body,
    ApiQuery? query,
  }) async {
    try {
      final data = endpoint.endsWith("/search")
          ? await storage.search(
              endpoint,
              query?.params[ApiQuery.keyQueryString] ?? "",
            )
          : await storage.read(endpoint, query?.params);
      return ApiResponse(
        result: ApiResponseResult.success,
        data: Stream.fromIterable(data),
      );
    } catch (error, stackTrace) {
      Log.e(
        _tag,
        "Demo stream request failed: $method $endpoint",
        error,
        stackTrace,
      );
      return ApiResponse.failed(const Stream.empty());
    }
  }

  Map<String, dynamic> _bodyMap(Object? body) {
    if (body is Map<String, dynamic>) {
      return body;
    }
    throw ArgumentError.value(body, "body", "A JSON map is required.");
  }

  Future<dynamic> _getJson(String fileName) async {
    final response = await _client.get(buildUri(fileName, null));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw http.ClientException(
        "Unable to load demo asset $fileName: ${response.statusCode}",
        response.request?.url,
      );
    }
    return json.decode(utf8.decode(response.bodyBytes));
  }
}
