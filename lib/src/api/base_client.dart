import 'package:my_api/src/api/api_core.dart';

abstract class BaseClient {

  /// Client
  final ApiClient _client = ApiClient();

  /// Home url
  String get home;

  /// Send request
  Future<ApiResponse<Map<String, dynamic>>> send(
    ApiMethod method,
    String link,
    Map<String, dynamic> data, {
    Map<String, dynamic>? options,
  }) async {
    final Map<String, dynamic> body = {
      "user_id": _client.id,
      "user_secret": _client.secret,
      "data": data,
    };
    if (options != null) {
      body['options'] = options;
    }
    final response = await _client.send(method, "$home/$link", body);
    return response;
  }

  /// Get path from [T]
  String path<T>();

  /// Covert [map] to [T]
  dynamic convert<T>(Map<String, dynamic> map, [String key = "data"]);

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
  Future<ApiResponse<List<T>>> create<T>(Map<String, dynamic> data) async {
    final result = await send(ApiMethod.put, path<T>(), data);
    return result.convert<T>(converts<T>(result.data));
  }

  /// Read [data] from [link]
  Future<ApiResponse<List<T>>> read<T>(Map<String, dynamic> data) async {
    final result = await send(ApiMethod.post, path<T>(), data);
    return result.convert<T>(converts<T>(result.data));
  }

  /// Update [data] from [link]
  Future<ApiResponse<List<T>>> update<T>(Map<String, dynamic> data) async {
    final result = await send(ApiMethod.patch, path<T>(), data);
    return result.convert<T>(converts<T>(result.data));
  }

  /// Delete [data] from [link]
  Future<ApiResponse<List<T>>> delete<T>(Map<String, dynamic> data) async {
    final result = await send(ApiMethod.delete, path<T>(), data);
    return result.convert<T>(converts<T>(result.data));
  }

  /// Request calculation result from [link] which fits to [data]
  ///
  /// [calc] defines type of calculation. And [attribute] defines column name
  /// which is calculated
  Future<ApiResponse<Map<String, dynamic>>> calculate(String link,
      Map<String, dynamic> data,
      CalculationType calc,
      String attribute,
      ) async {
    return await send(
      ApiMethod.post,
      link,
      data,
      options: _client.buildOptions(
        calcType: calc,
        calcAttribute: attribute,
      ),
    );
  }
}