library my_api;

import 'package:my_api/src/api/api_core.dart';
import 'package:my_api/src/exceptions.dart';
import 'package:my_api/src/log.dart';
import 'package:my_api/src/model/account.dart';
import 'package:my_api/src/model/model.dart';

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

  /// Create [data] from [link]
  ///
  /// It throws [ActionFailedException] on result is empty list.
  /// It throws [MultipleDataException] on length of result is more than `1`.
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

  /// Read [data] from [link]
  ///
  /// It throws [ActionFailedException] on result is empty list.
  Future<List> read<T extends Model>(Link link, Map<String, dynamic> data) async {
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
  Future<List> update<T extends Model>(Link link, Map<String, dynamic> data) async {
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

  /// Create [account]
  Future<ApiResponse<Account?>> createAccount(Account account) async {
    late List result;
    try {
      result = await create(Link.accounts, account.map);
    } on ActionFailedException catch(_) {
      return ApiResponse<Account?>(
        result: ApiResultCode.failed,
        data: null,
      );
    } on MultipleDataException catch(_) {
      return ApiResponse<Account?>(
        result: ApiResultCode.failed,
        data: null,
      );
    }
    final Account res = Account(result[0]);
    return ApiResponse<Account?>(
      result: account == res ? ApiResultCode.success : ApiResultCode.failed,
      data: res,
    );
  }

  /// Read accounts filtered by [condition]
  Future<ApiResponse<List<Account>>> readAccounts(Map<String, dynamic> condition) async {
    late List response;
    try {
      response = await read(Link.accounts, condition);
    } on ActionFailedException catch(_) {
      return ApiResponse(
        result: ApiResultCode.failed,
        data: [],
      );
    }
    final List<Account> result = [];
    for(var item in response) {
      result.add(Account(item));
    }
    return ApiResponse(
      result: ApiResultCode.success,
      data: result,
    );
  }

  /// Update [account]
  Future<ApiResponse<Account?>> updateAccount(Account account) async {
    late List result;
    try {
      result = await update(Link.accounts, account.map);
    } on ActionFailedException catch(_) {
      return ApiResponse<Account?>(
        result: ApiResultCode.failed,
        data: null,
      );
    } on MultipleDataException catch(_) {
      return ApiResponse<Account?>(
        result: ApiResultCode.failed,
        data: null,
      );
    }
    final Account res = Account(result[0]);
    return ApiResponse<Account?>(
      result: account == res ? ApiResultCode.success : ApiResultCode.failed,
      data: res,
    );
  }

  /// Delete [account]
  Future<ApiResponse<Account?>> deleteAccount(Account account) async {
    late List result;
    try {
      result = await delete(Link.accounts, account.map);
    } on ActionFailedException catch(_) {
      return ApiResponse<Account?>(
        result: ApiResultCode.failed,
        data: null,
      );
    } on MultipleDataException catch(_) {
      return ApiResponse<Account?>(
        result: ApiResultCode.failed,
        data: null,
      );
    }
    final Account res = Account(result[0]);
    return ApiResponse<Account?>(
      result: (account == res && res.deleted == true)
          ? ApiResultCode.success
          : ApiResultCode.failed,
      data: res,
    );
  }

}