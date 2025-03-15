import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_api/core/api.dart';
import 'package:my_api/core/model/model_keys.dart';
import 'package:my_api/core/model/preference_keys.dart';
import 'package:my_api/core/provider/model_state.dart';
import 'package:my_api/core/provider/provider.dart' as core_provider;
import 'package:my_api/finance/model/account.dart';
import 'package:my_api/finance/model/category.dart';
import 'package:my_api/finance/model/currency.dart';
import 'package:my_api/finance/model/payment.dart';
import 'package:my_api/finance/model/transaction.dart';

final initFinancePreference = {
  PreferenceKeys.defaultCurrency: Currency.unknown.value,
  PreferenceKeys.pieChartMaxEntries: 5,
  PreferenceKeys.budgets: {},
  PreferenceKeys.targetBalance: {},
};

final accounts = StateNotifierProvider<ModelsState<Account>, List<Account>>((ref) {
  return ModelsState<Account>(ref);
});

void refreshAccounts(WidgetRef ref) {
  ref.read(accounts.notifier).request({
    ApiQuery.keySortField: [ModelKeys.keyIcon],
    ApiQuery.keySortOrder: [ModelKeys.keyLastUsed]
  });
}

final payments = StateNotifierProvider<ModelsState<Payment>, List<Payment>>((ref) {
  return ModelsState<Payment>(ref);
});

void refreshPayments(WidgetRef ref) {
  ref.read(payments.notifier).request({
    ApiQuery.keySortField: [
      ModelKeys.keyIcon,
      ModelKeys.keyLastUsed
    ],
    ApiQuery.keySortOrder: [
      SortOrder.asc,
      SortOrder.desc
    ]
  });
}

final transactions = StateNotifierProvider<ModelsState<Transaction>, List<Transaction>>((ref) {
  return ModelsState<Transaction>(ref);
});

void fetchTransactions(WidgetRef ref, Map<String, dynamic> condition) async {
  condition[ApiQuery.keySortField] = [ModelKeys.keyPaidDate];
  condition[ApiQuery.keySortOrder] = [SortOrder.desc];
  ref.read(transactions.notifier).fetch(condition);
}

final categories = StateNotifierProvider<ModelsState<Category>, List<Category>>((ref) {
  return ModelsState<Category>(ref);
});

void refreshCategories(WidgetRef ref) {
  ref.read(categories.notifier).request({
    ApiQuery.keySortField: [
      ModelKeys.keyDeleted,
      ModelKeys.keyIncluded,
      ModelKeys.keyPid
    ],
    ApiQuery.keySortOrder: [
      SortOrder.asc,
      SortOrder.desc,
      SortOrder.asc
    ]
  });
}

Currency getDefaultCurrency(ref) {
  return Currency.fromValue(core_provider.getPreference<int>(ref, PreferenceKeys.defaultCurrency));
}

void setDefaultCurrency(WidgetRef ref, Currency value) {
  core_provider.setPreference(ref, PreferenceKeys.defaultCurrency, value.value);
}

final transactionTypeFilter = StateNotifierProvider<ModelState<TransactionType>, TransactionType>((ref) {
  return ModelState<TransactionType>(ref, TransactionType.expense);
});

final transactionIncludedFilter = StateNotifierProvider<ModelState<bool?>, bool?>((ref) {
  return ModelState<bool?>(ref, true);
});