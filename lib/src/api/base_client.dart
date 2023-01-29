import 'package:decimal/decimal.dart';
import 'package:my_api/src/api/api_core.dart';
import 'package:my_api/src/model/account.dart';
import 'package:my_api/src/model/category.dart';
import 'package:my_api/src/model/payment.dart';
import 'package:my_api/src/model/transaction.dart';

class ApiClient {

  /// Client
  final ApiCore _client = ApiCore();

  /// Send request
  Future<ApiResponse<Map<String, dynamic>>> send(
    ApiMethod method,
    String home,
    String path,
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
    final response = await _client.send(method, "$home/$path", body);
    return response;
  }

  /// Get home from [T]
  String home<T>() {
    switch(T) {
      case Account:
      case Payment:
      case Transaction:
      case Category:
        return "finance/v1";
      default:
        throw UnimplementedError();
    }
  }

  /// Get path from [T]
  String path<T>() {
    switch(T) {
      case Account:
        return "accounts";
      case Payment:
        return "payments";
      case Transaction:
        return "transactions";
      case Category:
        return "categories";
      default:
        throw UnimplementedError();
    }
  }

  /// Covert [map] to [T]
  dynamic convert<T>(Map<String, dynamic> map, [String key = "data"]) {
    final data = (key == "") ? map : map[key];
    switch(T) {
      case Decimal:
        return Decimal.parse(data);
      case Account:
        return Account(data);
      case Payment:
        return Payment(data);
      case Transaction:
        return Transaction(data);
      case Category:
        return Category(data);
      default:
        throw UnimplementedError();
    }
  }

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
    final result = await send(ApiMethod.put, home<T>(), path<T>(), data);
    return result.converts<T>(converts<T>(result.data));
  }

  /// Read [data] from [link]
  Future<ApiResponse<List<T>>> read<T>(Map<String, dynamic> data) async {
    final result = await send(ApiMethod.post, home<T>(), path<T>(), data);
    return result.converts<T>(converts<T>(result.data));
  }

  /// Update [data] from [link]
  Future<ApiResponse<List<T>>> update<T>(Map<String, dynamic> data) async {
    final result = await send(ApiMethod.patch, home<T>(), path<T>(), data);
    return result.converts<T>(converts<T>(result.data));
  }

  /// Delete [data] from [link]
  Future<ApiResponse<List<T>>> delete<T>(Map<String, dynamic> data) async {
    final result = await send(ApiMethod.delete, home<T>(), path<T>(), data);
    return result.converts<T>(converts<T>(result.data));
  }

  /// Request calculation result from [link] which fits to [data]
  ///
  /// [calc] defines type of calculation. And [attribute] defines column name
  /// which is calculated
  Future<ApiResponse<Decimal>> calculate<T>(String link,
      Map<String, dynamic> data,
      CalculationType calc,
      String attribute,
      ) async {
    final result = await send(
      ApiMethod.post,
      home<T>(),
      path<T>(),
      data,
      options: _client.buildOptions(
        calcType: calc,
        calcAttribute: attribute,
      ),
    );
    return result.convert<Decimal>(convert<Decimal>(result.data));
  }
}