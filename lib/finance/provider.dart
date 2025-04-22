import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_api/core/api.dart';
import 'package:my_api/core/model/model_keys.dart';
import 'package:my_api/core/model/preference_keys.dart';
import 'package:my_api/core/model/preference_root.dart';
import 'package:my_api/core/notifier/models_state_notifier.dart';
import 'package:my_api/core/notifier/preference_state_notifier.dart';
import 'package:my_api/finance/model/account.dart';
import 'package:my_api/finance/model/category.dart';
import 'package:my_api/finance/model/currency.dart';
import 'package:my_api/finance/model/payment.dart';
import 'package:my_api/finance/model/transaction.dart';

/// Default preferences
final initFinancePreference = {
  PreferenceKeys.defaultCurrency: Currency.unknownUuid,
  PreferenceKeys.pieChartMaxEntries: 5,
  PreferenceKeys.budgets: {},
  PreferenceKeys.targetBalance: {},
};

/// Provider of finance related preferences
final financePreference = StateNotifierProvider<PreferenceStateNotifier, PreferenceRoot>((ref) {
  return PreferenceStateNotifier(ref, "finance", initFinancePreference);
});

/// List of all accounts
final accounts = StateNotifierProvider<ModelsStateNotifier<Account>, List<Account>>((ref) {
  return ModelsStateNotifier<Account>();
});

/// Append accounts with [query]
///
/// If the sort field and order is not defined, `icon ASC, last_used DESC` will
/// be applied.
Future<void> appendAccounts(WidgetRef ref, [Map<String, dynamic>? query]) async {
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
  await ref.read(accounts.notifier).append(q);
}

/// Create account
Future<bool> createAccount(WidgetRef ref, Account account) async {
  return await ref.read(accounts.notifier).create(account);
}

/// Update account
Future<bool> updateAccount(WidgetRef ref, Account account) async {
  return await ref.read(accounts.notifier).update(account);
}

/// Delete account
///
/// This method only mark [account] as deleted.
Future<bool> deleteAccount(WidgetRef ref, Account account) async {
  account.deleted = true;
  return await ref.read(accounts.notifier).update(account);
}

/// List of all payments
final payments = StateNotifierProvider<ModelsStateNotifier<Payment>, List<Payment>>((ref) {
  return ModelsStateNotifier<Payment>();
});

/// Fetch payments
///
/// The sort order is `icon ASC, last_used DESC`.
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

/// Create payment
Future<bool> createPayment(WidgetRef ref, Payment payment) async {
  return await ref.read(payments.notifier).create(payment);
}

/// Update payment
Future<bool> updatePayment(WidgetRef ref, Payment payment) async {
  return await ref.read(payments.notifier).update(payment);
}

/// Delete payment
///
/// This method only marks [payment] as deleted.
Future<bool> deletePayment(WidgetRef ref, Payment payment) async {
  payment.deleted = true;
  return await ref.read(payments.notifier).update(payment);
}

/// List of all transactions
final transactions = StateNotifierProvider<ModelsStateNotifier<Transaction>, List<Transaction>>((ref) {
  return ModelsStateNotifier<Transaction>();
});

/// Append transactions with [query]
Future<void> appendTransactions(WidgetRef ref, Map<String, dynamic> query) async {
  query[ApiQuery.keySortField] = [ModelKeys.keyPaidDate];
  query[ApiQuery.keySortOrder] = [SortOrder.desc];
  await ref.read(transactions.notifier).append(query);
}

/// Create transaction
Future<bool> createTransaction(WidgetRef ref, Transaction transaction) async {
  final result = await ref.read(transactions.notifier).create(transaction);
  await appendAccounts(ref, {
    ModelKeys.keyUuid: transaction.accountId,
  });
  return result;
}

/// Update transaction
Future<bool> updateTransaction(WidgetRef ref, Transaction transaction) async {
  final result = await ref.read(transactions.notifier).update(transaction);
  await appendAccounts(ref);
  return result;
}

/// Delete transaction
///
/// This method only marks [transaction] as deleted.
Future<bool> deleteTransaction(WidgetRef ref, Transaction transaction) async {
  transaction.deleted = true;
  final result = await ref.read(transactions.notifier).update(transaction);
  await appendAccounts(ref, {
    ModelKeys.keyUuid: transaction.accountId,
  });
  return result;
}

/// List of all categories
final categories = StateNotifierProvider<ModelsStateNotifier<Category>, List<Category>>((ref) {
  return ModelsStateNotifier<Category>();
});

/// Fetch categories
///
/// Default sort is `deleted ASC, included DESC, uuid ASC`.
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

/// Create category
Future<bool> createCategory(WidgetRef ref, Category category) async {
  return await ref.read(categories.notifier).create(category);
}

/// Update category
Future<bool> updateCategory(WidgetRef ref, Category category) async {
  return await ref.read(categories.notifier).update(category);
}

/// Delete category
///
/// This method only marks [category] as deleted.
Future<bool> deleteCategory(WidgetRef ref, Category category) async {
  category.deleted = true;
  return await ref.read(categories.notifier).update(category);
}

/// List of all currencies
final currencies = StateNotifierProvider<ModelsStateNotifier<Currency>, List<Currency>>((ref) {
  return ModelsStateNotifier<Currency>();
});

/// Fetch currencies
///
/// Default sort is `uuid ASC`.
Future<void> fetchCurrencies(WidgetRef ref) async {
  await ref.read(currencies.notifier).fetch({
    ApiQuery.keySortField: [ModelKeys.keyUuid],
    ApiQuery.keySortOrder: [SortOrder.asc],
  });
}

/// Map of currency which has corresponding UUID as key
///
/// ```dart
/// {
///   "XXX": Currency
/// }
/// ```
final currencyMap = Provider<Map<String, Currency>>((ref) {
  final list = ref.watch(currencies);
  final map = <String, Currency>{};
  for (Currency item in list) {
    map[item.uuid] = item;
  }
  return map;
});

/// Get corresponding currency from given [uuid]
///
/// The default value is [Currency.unknown].
Currency getCurrency(ref, String? uuid) {
  final map = ref.watch(currencyMap);
  if (uuid == null || !map.containsKey(uuid)) {
    return Currency.unknown;
  }
  return map[uuid]!;
}

/// Get default currency which is set on [financePreference]
final defaultCurrency = Provider<Currency>((ref) {
  final root = ref.watch(financePreference);
  final uuid = root.get<String>(PreferenceKeys.defaultCurrency, Currency.unknownUuid).value;
  return getCurrency(ref, uuid);
});

/// Set default currency to [financePreference]
void setDefaultCurrency(WidgetRef ref, Currency currency) {
  final root = ref.watch(financePreference);
  root.set(PreferenceKeys.defaultCurrency, currency.uuid);
  setPreference(ref, financePreference, root);
}