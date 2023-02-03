import 'package:decimal/decimal.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_api/src/api/api_core.dart';
import 'package:my_api/src/api/api_client.dart';
import 'package:my_api/src/log.dart';
import 'package:my_api/src/model/account.dart';
import 'package:my_api/src/model/category.dart';
import 'package:my_api/src/model/payment.dart';
import 'package:my_api/src/model/transaction.dart';
import 'package:my_api/src/provider/calculate_value_state.dart';

const String _tag = "FinanceProvider";

class FinanceProvider {

  static final account = StateNotifierProvider<FinanceModelDetailsState<Account>, Account?>((ref) {
    return FinanceModelDetailsState<Account>(ref);
  });

  static final payment = StateNotifierProvider<FinanceModelDetailsState<Payment>, Payment?>((ref) {
    return FinanceModelDetailsState<Payment>(ref);
  });

  static final transaction = StateNotifierProvider<FinanceModelDetailsState<Transaction>, Transaction?>((ref) {
    return FinanceModelDetailsState<Transaction>(ref);
  });

  static final category = StateNotifierProvider<FinanceModelDetailsState<Category>, Category?>((ref) {
    return FinanceModelDetailsState<Category>(ref);
  });

  static final accounts = StateNotifierProvider<FinanceModelState<Account>, List<Account>>((ref) {
    return FinanceModelState<Account>(ref);
  });

  static final payments = StateNotifierProvider<FinanceModelState<Payment>, List<Payment>>((ref) {
    return FinanceModelState<Payment>(ref);
  });

  static final transactions = StateNotifierProvider<FinanceModelState<Transaction>, List<Transaction>>((ref) {
    return FinanceModelState<Transaction>(ref);
  });

  static final categories = StateNotifierProvider<FinanceModelState<Category>, List<Category>>((ref) {
    return FinanceModelState<Category>(ref);
  });

  static final expenses = StateNotifierProvider<CalculateValueState<Transaction>, Decimal>((ref) {
    return CalculateValueState<Transaction>(ref,
      condition: conditionCurrentMonthExpense(),
      type: CalculationType.sum,
      attribute: Transaction.keyAmount,
    );
  });

  static final amountBePaid = StateNotifierProvider<CalculateValueState<Transaction>, Decimal>((ref) {
    return CalculateValueState<Transaction>(ref,
      condition: conditionAmountBePaid(),
      type: CalculationType.sum,
      attribute: Transaction.keyAmount,
    );
  });

  static conditionCurrentMonthExpense() {
    final now = DateTime.now();
    return {
      Transaction.keyType: TransactionType.expense,
      Transaction.keyPaidDate: [
        DateTime(now.year, now.month, 1, 0, 0, 0, 0).millisecondsSinceEpoch,
        DateTime(now.year, now.month+1, 1, 0, 0, 0, 0).millisecondsSinceEpoch,
      ],
      Transaction.keyIncluded: true,
    };
  }

  static conditionAmountBePaid() {
    final now = DateTime.now();
    return {
      Transaction.keyType: TransactionType.expense,
      Transaction.keyCalculatedDate: [
        now.millisecondsSinceEpoch,
      ],
      Transaction.keyIncluded: true,
    };
  }

}

class FinanceModelState<T> extends StateNotifier<List<T>> {

  FinanceModelState(this.ref) : super([]);

  final Ref ref;

  /// Clear state
  void clear() => state = [];

  /// Request [T] items fit to [condition] and filter by [options]
  void request(Map<String, dynamic> condition, [Map<String, dynamic>? options]) async {
    final client = ApiClient();
    final ApiResponse<List<T>> response = await client.read<T>(
      condition,
      options,
    );
    if (response.result != ApiResultCode.success) {
      Log.e(_tag, "Failed to request $condition");
      state = [];
      return;
    }
    state = response.data;
  }
}

class FinanceModelDetailsState<T> extends StateNotifier<T?> {

  FinanceModelDetailsState(this.ref) : super(null);

  final Ref ref;

  /// Clear state
  void clear() => state = null;

  /// Request [T] items fit to [condition] and filter by [options]
  void request(Map<String, dynamic> condition, [Map<String, dynamic>? options]) async {
    final client = ApiClient();
    final ApiResponse<List<T>> response = await client.read<T>(
      condition,
      options,
    );
    if (response.result != ApiResultCode.success) {
      Log.e(_tag, "Failed to request $condition");
      state = null;
      return;
    }
    state = response.data[0];
  }
}