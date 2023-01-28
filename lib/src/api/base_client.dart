import 'package:decimal/decimal.dart';
import 'package:my_api/src/api/api_core.dart';
import 'package:my_api/src/exceptions.dart';
import 'package:my_api/src/log.dart';

abstract class BaseClient {

  /// TAG for log system
  static const _tag = "BaseClient";

  /// Client
  final ApiClient _client = ApiClient();

  /// Home url
  String get home;

  /// Send request
  Future<dynamic> send<T>(
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

    return response['data'];
  }

  /// Create [data] from [link]
  ///
  /// It throws [ActionFailedException] on result is empty list.
  /// It throws [MultipleDataException] on length of result is more than `1`.
  Future<List> create<T>(String link, Map<String, dynamic> data) async {
    final List result = await send<T>(ApiMethod.put, link, data);
    if (result.isEmpty) {
      Log.e(_tag, "Data creation failed: $data");
      throw ActionFailedException(data);
    }
    if (result.length > 1) {
      Log.e(_tag, "Multiple data created: $data");
      throw MultipleDataException(data);
    }
    return result;
  }

  /// Read [data] from [link]
  ///
  /// It throws [ActionFailedException] on result is empty list.
  Future<List> read<T>(String link, Map<String, dynamic> data) async {
    final List result = await send<T>(ApiMethod.post, link, data);
    if (result.isEmpty) {
      Log.w(_tag, "No results: $data");
      throw ActionFailedException(data);
    }
    return result;
  }

  /// Update [data] from [link]
  ///
  /// throws [ActionFailedException] on result is empty list
  Future<List> update<T>(String link, Map<String, dynamic> data) async {
    final List result = await send<T>(ApiMethod.patch, link, data);
    if (result.isEmpty) {
      Log.e(_tag, "Update failed: $data");
      throw ActionFailedException(data);
    }
    return result;
  }

  /// Delete [data] from [link]
  ///
  /// It throws [ActionFailedException] on result is empty list.
  /// It throws [MultipleDataException] on length of result is more than `1`.
  Future<List> delete<T>(String link, Map<String, dynamic> data) async {
    final List result = await send<T>(ApiMethod.delete, link, data);
    if (result.isEmpty) {
      Log.e(_tag, "Failed to delete: $data");
      throw ActionFailedException(data);
    }
    if (result.length > 1) {
      Log.w(_tag, "Multiple data deleted: $data");
      throw MultipleDataException(data);
    }
    return result;
  }

  /// Request calculation result from [link] which fits to [data]
  ///
  /// [calc] defines type of calculation. And [attribute] defines column name
  /// which is calculated
  Future<Decimal> calculate(String link,
      Map<String, dynamic> data,
      CalculationType calc,
      String attribute,
      ) async {
    final result = await send(ApiMethod.post, link, data, options: _client.buildOptions(
      calcType: calc,
      calcAttribute: attribute,
    ),);
    // Check result is String
    if (result is! String) {
      throw ActionFailedException(data);
    }
    // Check result string is number
    final RegExp regex = RegExp(r"[\d.]");
    if (!regex.hasMatch(result)) {
      throw ActionFailedException(data);
    }
    return Decimal.parse(result);
  }
}