library my_api;

import 'package:my_api/src/api/api_core.dart';
import 'package:my_api/src/exceptions.dart';
import 'package:my_api/src/log.dart';
import 'package:my_api/src/model/account.dart';
import 'package:my_api/src/model/category.dart';
import 'package:my_api/src/model/payment.dart';
import 'package:my_api/src/model/model.dart';
import 'package:my_api/src/model/transaction.dart';

/// Link
enum Link {
  accounts,
  transactions,
  payments,
  categories,
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
  Future<dynamic> send<T extends Model>(
    ApiMethod method,
    Link link,
    Map<String, dynamic> data, {
    Map<String, dynamic>? options,
  }) async {
    final Map<String, dynamic> body = {
      "user_id": _client.id,
      "user_secret": _client.session.secret,
      "data": data,
    };
    if (options != null) {
      body['options'] = options;
    }
    final response = await _client.send(method, "$home/${link.name}", body);
    
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

  /// Request calculation result from [link] which fits to [data]
  ///
  /// [calc] defines type of calculation. And [attributes] defines column name
  /// which is calculated
  Future<BigInt> calculate(Link link,
    Map<String, dynamic> data,
    CalculationType calc,
    String attributes,
  ) async {
    final result = await send(ApiMethod.post, link, data, options: {
      "calc": calc.name.toUpperCase(),
      "attr": attributes,
    });
    // Check result is String
    if (result is! String) {
      throw ActionFailedException(data);
    }
    // Check result string is number
    final RegExp regex = RegExp(r"[0-9.]");
    if (!regex.hasMatch(result)) {
      throw ActionFailedException(data);
    }
    return BigInt.parse(result);
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

  /// Create [payment]
  Future<ApiResponse<Payment?>> createPayment(Payment payment) async {
    late List result;
    try {
      result = await create(Link.payments, payment.map);
    } on ActionFailedException catch(_) {
      return ApiResponse<Payment?>(
        result: ApiResultCode.failed,
        data: null,
      );
    } on MultipleDataException catch(_) {
      return ApiResponse<Payment?>(
        result: ApiResultCode.failed,
        data: null,
      );
    }
    final Payment res = Payment(result[0]);
    return ApiResponse<Payment?>(
      result: payment == res ? ApiResultCode.success : ApiResultCode.failed,
      data: res,
    );
  }

  /// Read payments filtered by [condition]
  Future<ApiResponse<List<Payment>>> readPayments(Map<String, dynamic> condition) async {
    late List response;
    try {
      response = await read(Link.payments, condition);
    } on ActionFailedException catch(_) {
      return ApiResponse(
        result: ApiResultCode.failed,
        data: [],
      );
    }
    final List<Payment> result = [];
    for(var item in response) {
      result.add(Payment(item));
    }
    return ApiResponse(
      result: ApiResultCode.success,
      data: result,
    );
  }

  /// Update [payment]
  Future<ApiResponse<Payment?>> updatePayment(Payment payment) async {
    late List result;
    try {
      result = await update(Link.payments, payment.map);
    } on ActionFailedException catch(_) {
      return ApiResponse<Payment?>(
        result: ApiResultCode.failed,
        data: null,
      );
    } on MultipleDataException catch(_) {
      return ApiResponse<Payment?>(
        result: ApiResultCode.failed,
        data: null,
      );
    }
    final Payment res = Payment(result[0]);
    return ApiResponse<Payment?>(
      result: payment == res ? ApiResultCode.success : ApiResultCode.failed,
      data: res,
    );
  }

  /// Delete [payment]
  Future<ApiResponse<Payment?>> deletePayment(Payment payment) async {
    late List result;
    try {
      result = await delete(Link.payments, payment.map);
    } on ActionFailedException catch(_) {
      return ApiResponse<Payment?>(
        result: ApiResultCode.failed,
        data: null,
      );
    } on MultipleDataException catch(_) {
      return ApiResponse<Payment?>(
        result: ApiResultCode.failed,
        data: null,
      );
    }
    final Payment res = Payment(result[0]);
    return ApiResponse<Payment?>(
      result: (payment == res && res.deleted == true)
          ? ApiResultCode.success
          : ApiResultCode.failed,
      data: res,
    );
  }

  /// Create [transaction]
  Future<ApiResponse<Transaction?>> createTransaction(Transaction transaction) async {
    late List result;
    try {
      result = await create(Link.transactions, transaction.map);
    } on ActionFailedException catch(_) {
      return ApiResponse<Transaction?>(
        result: ApiResultCode.failed,
        data: null,
      );
    } on MultipleDataException catch(_) {
      return ApiResponse<Transaction?>(
        result: ApiResultCode.failed,
        data: null,
      );
    }
    final Transaction res = Transaction(result[0]);
    return ApiResponse<Transaction?>(
      result: transaction == res ? ApiResultCode.success : ApiResultCode.failed,
      data: res,
    );
  }

  /// Read transactions filtered by [condition]
  Future<ApiResponse<List<Transaction>>> readTransactions(Map<String, dynamic> condition) async {
    late List response;
    try {
      response = await read(Link.transactions, condition);
    } on ActionFailedException catch(_) {
      return ApiResponse(
        result: ApiResultCode.failed,
        data: [],
      );
    }
    final List<Transaction> result = [];
    for(var item in response) {
      result.add(Transaction(item));
    }
    return ApiResponse(
      result: ApiResultCode.success,
      data: result,
    );
  }

  /// Update [transaction]
  Future<ApiResponse<Transaction?>> updateTransaction(Transaction transaction) async {
    late List result;
    try {
      result = await update(Link.transactions, transaction.map);
    } on ActionFailedException catch(_) {
      return ApiResponse<Transaction?>(
        result: ApiResultCode.failed,
        data: null,
      );
    } on MultipleDataException catch(_) {
      return ApiResponse<Transaction?>(
        result: ApiResultCode.failed,
        data: null,
      );
    }
    final Transaction res = Transaction(result[0]);
    return ApiResponse<Transaction?>(
      result: transaction == res ? ApiResultCode.success : ApiResultCode.failed,
      data: res,
    );
  }

  /// Delete [transaction]
  Future<ApiResponse<Transaction?>> deleteTransaction(Transaction transaction) async {
    late List result;
    try {
      result = await delete(Link.transactions, transaction.map);
    } on ActionFailedException catch(_) {
      return ApiResponse<Transaction?>(
        result: ApiResultCode.failed,
        data: null,
      );
    } on MultipleDataException catch(_) {
      return ApiResponse<Transaction?>(
        result: ApiResultCode.failed,
        data: null,
      );
    }
    final Transaction res = Transaction(result[0]);
    return ApiResponse<Transaction?>(
      result: (transaction == res && res.deleted == true)
          ? ApiResultCode.success
          : ApiResultCode.failed,
      data: res,
    );
  }

  /// Create [category]
  Future<ApiResponse<Category?>> createCategory(Category category) async {
    late List result;
    try {
      result = await create(Link.categories, category.map);
    } on ActionFailedException catch(_) {
      return ApiResponse<Category?>(
        result: ApiResultCode.failed,
        data: null,
      );
    } on MultipleDataException catch(_) {
      return ApiResponse<Category?>(
        result: ApiResultCode.failed,
        data: null,
      );
    }
    final Category res = Category(result[0]);
    return ApiResponse<Category?>(
      result: category == res ? ApiResultCode.success : ApiResultCode.failed,
      data: res,
    );
  }

  /// Read categorys filtered by [condition]
  Future<ApiResponse<List<Category>>> readCategories(Map<String, dynamic> condition) async {
    late List response;
    try {
      response = await read(Link.categories, condition);
    } on ActionFailedException catch(_) {
      return ApiResponse(
        result: ApiResultCode.failed,
        data: [],
      );
    }
    final List<Category> result = [];
    for(var item in response) {
      result.add(Category(item));
    }
    return ApiResponse(
      result: ApiResultCode.success,
      data: result,
    );
  }

  /// Update [category]
  Future<ApiResponse<Category?>> updateCategory(Category category) async {
    late List result;
    try {
      result = await update(Link.categories, category.map);
    } on ActionFailedException catch(_) {
      return ApiResponse<Category?>(
        result: ApiResultCode.failed,
        data: null,
      );
    } on MultipleDataException catch(_) {
      return ApiResponse<Category?>(
        result: ApiResultCode.failed,
        data: null,
      );
    }
    final Category res = Category(result[0]);
    return ApiResponse<Category?>(
      result: category == res ? ApiResultCode.success : ApiResultCode.failed,
      data: res,
    );
  }

  /// Delete [category]
  Future<ApiResponse<Category?>> deleteCategory(Category category) async {
    late List result;
    try {
      result = await delete(Link.categories, category.map);
    } on ActionFailedException catch(_) {
      return ApiResponse<Category?>(
        result: ApiResultCode.failed,
        data: null,
      );
    } on MultipleDataException catch(_) {
      return ApiResponse<Category?>(
        result: ApiResultCode.failed,
        data: null,
      );
    }
    final Category res = Category(result[0]);
    return ApiResponse<Category?>(
      result: (category == res && res.deleted == true)
          ? ApiResultCode.success
          : ApiResultCode.failed,
      data: res,
    );
  }

}