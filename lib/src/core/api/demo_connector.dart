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

/// Provides API behavior locally without HTTP or authentication.
class DemoConnector implements ApiConnector {
  /// Creates a demo connector.
  DemoConnector({DemoStorage? storage}) : storage = storage ?? DemoStorage();

  /// Local backend storage.
  final DemoStorage storage;

  @override
  String get uri => "${AppMode.demo.name}://local";

  @override
  AppMode get mode => AppMode.demo;

  @override
  Uri buildUri(String endpoint, Map<String, dynamic>? query) => Uri(
        scheme: AppMode.demo.name,
        host: "local",
        path: endpoint,
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
  Future<User> login() async => User.demo;

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
}
