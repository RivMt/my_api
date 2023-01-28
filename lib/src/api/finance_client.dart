library my_api;

import 'package:my_api/src/api/api_core.dart';
import 'package:my_api/src/api/base_client.dart';
import 'package:my_api/src/exceptions.dart';
import 'package:my_api/src/model/account.dart';
import 'package:my_api/src/model/category.dart';
import 'package:my_api/src/model/payment.dart';
import 'package:my_api/src/model/transaction.dart';

class FinanceClient extends BaseClient {

  /// Private instance for singleton pattern
  static final FinanceClient _instance = FinanceClient._();

  /// Private constructor for singleton pattern
  FinanceClient._();

  /// Factory constructor for singleton pattern
  factory FinanceClient() => _instance;
  
  /// Accounts link
  final String accounts = "accounts";
  
  /// Payments link
  final String payments = "payments";
  
  /// Transactions link
  final String transactions = "transactions";
  
  /// Categories link
  final String categories = "categories";

  /// Home link
  @override
  final String home = "finance/v1";

  /// Create [account]
  Future<ApiResponse<Account?>> createAccount(Account account) async {
    late List result;
    try {
      result = await create(accounts, account.map);
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
      response = await read(accounts, condition);
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
      result = await update(accounts, account.map);
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
      result = await delete(accounts, account.map);
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
      result = await create(payments, payment.map);
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
      response = await read(payments, condition);
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
      result = await update(payments, payment.map);
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
      result = await delete(payments, payment.map);
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
      result = await create(transactions, transaction.map);
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
      response = await read(transactions, condition);
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
      result = await update(transactions, transaction.map);
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
      result = await delete(transactions, transaction.map);
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
      result = await create(categories, category.map);
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

  /// Read categories filtered by [condition]
  Future<ApiResponse<List<Category>>> readCategories(Map<String, dynamic> condition) async {
    late List response;
    try {
      response = await read(categories, condition);
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
      result = await update(categories, category.map);
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
      result = await delete(categories, category.map);
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