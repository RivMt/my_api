library my_api;

import 'package:my_api/api/api_core.dart';
import 'package:my_api/exceptions.dart';
import 'package:my_api/log.dart';
import 'package:my_api/model/account.dart';
import 'package:my_api/model/model.dart';

/// Link
enum Link {
  accounts,
  transactions,
  payments,
  category,
}

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

  /// Send request
  Future<List> send<T extends Model>(ApiMethod method, Link link, Map<String, dynamic> data) async {
    final response = await _client.send(method, "$home/${link.name}", {
      "user_id": _client.id,
      "user_secret": _client.session.secret,
      "data": data,
    });
    
    return response['data'];
  }

  /// Create
  Future<List> create<T extends Model>(Link link, Map<String, dynamic> data) async {
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

  /// Read
  Future<List> read<T extends Model>(Link link, Map<String, dynamic> data) async {
    final List result = await send<T>(ApiMethod.post, link, data);
    if (result.isEmpty) {
      Log.w(_tag, "No results: $data");
      throw ActionFailedException(data);
    }
    return result;
  }

  /// Update
  Future<List> update<T extends Model>(Link link, Map<String, dynamic> data) async {
    final List result = await send<T>(ApiMethod.patch, link, data);
    if (result.isEmpty) {
      Log.e(_tag, "Update failed: $data");
      throw ActionFailedException(data);
    }
    return result;
  }

  /// Delete
  Future<List> delete<T extends Model>(Link link, Map<String, dynamic> data) async {
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

  /// Create account
  Future<bool> createAccount(Account account) async {
    late List result;
    try {
      result = await create(Link.accounts, account.map);
    } on ActionFailedException catch(_) {
      return false;
    } on MultipleDataException catch(_) {
      return false;
    }
    final Account res = Account(result[0]);
    return (res == account);
  }

  /// Read accounts
  Future<List<Account>> readAccounts(Map<String, dynamic> condition) async {
    late List response;
    try {
      response = await read(Link.accounts, condition);
    } on ActionFailedException catch(_) {
      return [];
    }
    final List<Account> result = [];
    for(var item in response) {
      result.add(Account(item));
    }
    return result;
  }

}