import 'package:my_api/src/core/app_mode.dart';
import 'package:my_api/src/core/api/api_query.dart';
import 'package:my_api/src/core/api/api_response.dart';
import 'package:my_api/src/core/api/http_method.dart';
import 'package:my_api/src/core/model/user.dart';

/// Defines the common request schema for API connectors.
abstract class ApiConnector {
  /// Address represented by this connector.
  String get uri;

  /// Current application mode.
  AppMode get mode;

  /// Builds a connector-specific URI for [endpoint] and [query].
  Uri buildUri(String endpoint, Map<String, dynamic>? query);

  /// Initializes the connector with [preferences].
  Future<void> init(Map<String, dynamic> preferences);

  /// Authenticates and returns the current user.
  Future<User> login();

  /// Ends the current authentication session.
  Future<User> logout();

  /// Sends a request and returns the completed response data.
  Future<ApiResponse> request<T>({
    required HttpMethod method,
    required String endpoint,
    Object? body,
    ApiQuery? query,
  });

  /// Sends a request and returns the response data as a stream.
  Future<ApiResponse<Stream>> requestStream<T>({
    required HttpMethod method,
    required String endpoint,
    Object? body,
    ApiQuery? query,
  });
}
