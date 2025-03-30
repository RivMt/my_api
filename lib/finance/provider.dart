import 'package:decimal/decimal.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_api/core/api.dart';
import 'package:my_api/core/model/model_keys.dart';
import 'package:my_api/core/model/preference_element.dart';
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
  return PreferenceState(ref, "finance");
});

void addTargetBalance(WidgetRef ref, DateTime date, Currency currency, Decimal amount) {
  final root = ref.watch(financePreference);
  final targets = root.get(PreferenceKeys.targetBalance, null).get(currency.uuid, null);
  targets.set<Decimal>(date.toIso8601String(), amount);
  setPreference(ref, financePreference, root);
}

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
      ModelKeys.keyUuid
    ],
    ApiQuery.keySortOrder: [
      SortOrder.asc,
      SortOrder.desc,
      SortOrder.asc
    ]
  });
}

final currencies = StateNotifierProvider<ModelsState<Currency>, List<Currency>>((ref) {
  return ModelsState<Currency>(ref);
});

void fetchCurrencies(WidgetRef ref) {
  ref.read(currencies.notifier).request({
    ApiQuery.keySortField: [
      ModelKeys.keyUuid,
    ],
    ApiQuery.keySortOrder: [
      SortOrder.asc,
    ]
  });
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