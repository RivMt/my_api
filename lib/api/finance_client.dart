library my_api;

import 'package:my_api/api/api_core.dart';
import 'package:my_api/log.dart';
import 'package:my_api/model/account.dart';
import 'package:my_api/model/model.dart';

class FinanceClient {

  /// TAG for log system
  static const _tag = "FinanceClient";

  /// Client
  final ApiClient _client = ApiClient();

  /// Private instance for singleton pattern
  static final FinanceClient _instance = FinanceClient._();

  /// Private constructor for singleton pattern
  FinanceClient._();

  /// Factory constructor for singleton pattern
  factory FinanceClient() => _instance;

  /// Home link
  final String home = "finance/v1";

  /// Set [_client]
  void set({
    required String url,
    required String id,
  }) {
    _client.set(url: url, id: id);
  }

  /// Get type link
  String link<T>() {
    if (T == Account) {
      return "$home/accounts";
    }
    Log.e(_tag, "$T is not supported type");
    throw Exception();
  }

  /// Get accounts
  Future<List> get<T extends Model>(Map<String, dynamic> condition) async {
    final response = await _client.post(link<T>(), {
      "user_id": _client.id,
      "user_secret": _client.session.secret,
      "data": condition,
    });
    
    return response['data'];
  }

}