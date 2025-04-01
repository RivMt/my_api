import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_api/core/api.dart';
import 'package:my_api/core/model/model_keys.dart';
import 'package:my_api/core/model/preference_keys.dart';
import 'package:my_api/core/model/preference_root.dart';
import 'package:my_api/core/provider/model_state.dart';
import 'package:my_api/core/provider/preference_state.dart';
import 'package:my_api/finance/model/account.dart';
import 'package:my_api/finance/model/category.dart';
import 'package:my_api/finance/model/currency.dart';
import 'package:my_api/finance/model/payment.dart';
import 'package:my_api/finance/model/transaction.dart';

final initFinancePreference = {
  PreferenceKeys.defaultCurrency: Currency.unknownUuid,
  PreferenceKeys.pieChartMaxEntries: 5,
  PreferenceKeys.budgets: {},
  PreferenceKeys.targetBalance: {},
};

final financePreference = StateNotifierProvider<PreferenceState, PreferenceRoot>((ref) {
  return PreferenceState(ref, "finance", initFinancePreference);
});

final accounts = StateNotifierProvider<ModelsState<Account>, List<Account>>((ref) {
  return ModelsState<Account>(ref);
});

Future<void> fetchAccounts(WidgetRef ref, [Map<String, dynamic>? query]) async {
  final Map<String, dynamic> q = query ?? {};
  if (!q.containsKey(ApiQuery.keySortField)) {
    q[ApiQuery.keySortField] = [
      ModelKeys.keyIcon,
      ModelKeys.keyLastUsed
    ];
  }
  if (!q.containsKey(ApiQuery.keySortOrder)) {
    q[ApiQuery.keySortOrder] = [
      SortOrder.asc,
      SortOrder.desc
    ];
  }
  await ref.read(accounts.notifier).fetch(q);
}

Future<bool> createAccount(WidgetRef ref, Account account) async {
  return await ref.read(accounts.notifier).create(account);
}

Future<bool> updateAccount(WidgetRef ref, Account account) async {
  return await ref.read(accounts.notifier).update(account);
}

Future<bool> deleteAccount(WidgetRef ref, Account account) async {
  return await ref.read(accounts.notifier).delete(account);
}

final payments = StateNotifierProvider<ModelsState<Payment>, List<Payment>>((ref) {
  return ModelsState<Payment>(ref);
});

Future<void> fetchPayments(WidgetRef ref) async {
  await ref.read(payments.notifier).fetch({
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

Future<bool> createPayment(WidgetRef ref, Payment payment) async {
  return await ref.read(payments.notifier).create(payment);
}

Future<bool> updatePayment(WidgetRef ref, Payment payment) async {
  return await ref.read(payments.notifier).update(payment);
}

Future<bool> deletePayment(WidgetRef ref, Payment payment) async {
  return await ref.read(payments.notifier).delete(payment);
}

final transactions = StateNotifierProvider<ModelsState<Transaction>, List<Transaction>>((ref) {
  return ModelsState<Transaction>(ref);
});

Future<void> fetchTransactions(WidgetRef ref, Map<String, dynamic> condition) async {
  condition[ApiQuery.keySortField] = [ModelKeys.keyPaidDate];
  condition[ApiQuery.keySortOrder] = [SortOrder.desc];
  await ref.read(transactions.notifier).append(condition);
}

Future<bool> createTransaction(WidgetRef ref, Transaction transaction) async {
  final result = await ref.read(transactions.notifier).create(transaction);
  await fetchAccounts(ref, {
    ModelKeys.keyUuid: transaction.accountId,
  });
  return result;
}

Future<bool> updateTransaction(WidgetRef ref, Transaction transaction) async {
  final result = await ref.read(transactions.notifier).update(transaction);
  await fetchAccounts(ref);
  return result;
}

Future<bool> deleteTransaction(WidgetRef ref, Transaction transaction) async {
  final result = await ref.read(transactions.notifier).delete(transaction);
  await fetchAccounts(ref, {
    ModelKeys.keyUuid: transaction.accountId,
  });
  return result;
}

final categories = StateNotifierProvider<ModelsState<Category>, List<Category>>((ref) {
  return ModelsState<Category>(ref);
});

Future<void> fetchCategories(WidgetRef ref) async {
  await ref.read(categories.notifier).fetch({
    ApiQuery.keySortField: [
      ModelKeys.keyDeleted,
      ModelKeys.keyIncluded,
      ModelKeys.keyUuid
    ],
    ApiQuery.keySortOrder: [
      SortOrder.asc,
      SortOrder.desc,
      SortOrder.asc
    ]
  });
}

Future<bool> createCategory(WidgetRef ref, Category category) async {
  return await ref.read(categories.notifier).create(category);
}

Future<bool> updateCategory(WidgetRef ref, Category category) async {
  return await ref.read(categories.notifier).update(category);
}

Future<bool> deleteCategory(WidgetRef ref, Category category) async {
  return await ref.read(categories.notifier).delete(category);
}

final currencies = StateNotifierProvider<ModelsState<Currency>, List<Currency>>((ref) {
  return ModelsState<Currency>(ref);
});

Future<void> fetchCurrencies(WidgetRef ref) async {
  await ref.read(currencies.notifier).fetch();
}

final currencyMap = Provider<Map<String, Currency>>((ref) {
  final list = ref.watch(currencies);
  final map = <String, Currency>{};
  for (Currency item in list) {
    map[item.uuid] = item;
  }
  return map;
});

Currency getCurrency(ref, String? uuid) {
  final map = ref.watch(currencyMap);
  if (uuid == null || !map.containsKey(uuid)) {
    return Currency.unknown;
  }
  return map[uuid]!;
}

final defaultCurrency = Provider<Currency>((ref) {
  final root = ref.watch(financePreference);
  final uuid = root.get<String>(PreferenceKeys.defaultCurrency, Currency.unknownUuid).value;
  return getCurrency(ref, uuid);
});

void setDefaultCurrency(WidgetRef ref, Currency currency) {
  final root = ref.watch(financePreference);
  root.set(PreferenceKeys.defaultCurrency, currency.uuid);
  setPreference(ref, financePreference, root);
}