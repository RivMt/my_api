import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_api/core/api.dart';
import 'package:my_api/core/model/model_keys.dart';
import 'package:my_api/core/model/preference.dart';
import 'package:my_api/core/provider/model_state.dart';
import 'package:my_api/core/provider/preference_state.dart';
import 'package:my_api/finance/model/account.dart';
import 'package:my_api/finance/model/category.dart';
import 'package:my_api/finance/model/currency.dart';
import 'package:my_api/finance/model/payment.dart';
import 'package:my_api/finance/model/transaction.dart';

final preferences = StateNotifierProvider<PreferenceState, Map<String, Preference>>((ref) {
  return PreferenceState(ref);
});

void syncPreferences(WidgetRef ref, [Map<String, dynamic>? init]) {
  ref.read(preferences.notifier).sync(init);
}

Future<bool> setPreference(WidgetRef ref, Preference pref) async {
  return await ref.read(preferences.notifier).set(pref);
}

Future<bool> deletePreference(WidgetRef ref, String key) async {
  return await ref.read(preferences.notifier).delete(key);
}

final accounts = StateNotifierProvider<ModelsState<Account>, List<Account>>((ref) {
  return ModelsState<Account>(ref);
});

void refreshAccounts(WidgetRef ref) {
  ref.read(accounts.notifier).request(
    [{
      ModelKeys.keyDeleted: false,
    }],
    ApiClient.buildOptions(
      sorts: [
        const Sort(ModelKeys.keyIcon, SortType.asc),
        const Sort(ModelKeys.keyLastUsed, SortType.desc),
      ],
    ),
  );
}

final payments = StateNotifierProvider<ModelsState<Payment>, List<Payment>>((ref) {
  return ModelsState<Payment>(ref);
});

void refreshPayments(WidgetRef ref) {
  ref.read(payments.notifier).request(
    [{
      ModelKeys.keyDeleted: false,
    }],
    ApiClient.buildOptions(
      sorts: [
        const Sort(ModelKeys.keyIcon, SortType.asc),
        const Sort(ModelKeys.keyLastUsed, SortType.desc),
      ],
    ),
  );
}

final transactions = StateNotifierProvider<ModelsState<Transaction>, List<Transaction>>((ref) {
  return ModelsState<Transaction>(ref);
});

void refreshTransactions(WidgetRef ref, {int? accountId, int? paymentId}) async {
  Map<String, dynamic> map = {};
  if (accountId != null) map[ModelKeys.keyAccountID] = accountId;
  if (paymentId != null) map[ModelKeys.keyPaymentID] = paymentId;
  ref.read(transactions.notifier).request([map], ApiClient.buildOptions(
    sorts: [
      const Sort(ModelKeys.keyPaidDate, SortType.desc),
    ],
  ));
}

final categories = StateNotifierProvider<ModelsState<Category>, List<Category>>((ref) {
  return ModelsState<Category>(ref);
});

void refreshCategories(WidgetRef ref) {
  ref.read(categories.notifier).request([{
    ModelKeys.keyDeleted: false,
  }], ApiClient.buildOptions(
    sorts: [
      const Sort(ModelKeys.keyPid, SortType.asc),
    ],
  ));
}

final sortFilter = StateNotifierProvider<ModelState<String>, String>((ref) {
  return ModelState<String>(ref, ModelKeys.keyPid);
});

final currencyFilter = StateNotifierProvider<ModelState<Currency>, Currency>((ref) {
  return ModelState<Currency>(ref, Currency.unknown);
});

final minPriorityFilter = StateNotifierProvider<ModelState<int>, int>((ref) {
  return ModelState<int>(ref, 0);
});

final maxPriorityFilter = StateNotifierProvider<ModelState<int>, int>((ref) {
  return ModelState<int>(ref, 1000);
});

final transactionTypeFilter = StateNotifierProvider<ModelState<TransactionType>, TransactionType>((ref) {
  return ModelState<TransactionType>(ref, TransactionType.expense);
});

final transactionIncludedFilter = StateNotifierProvider<ModelState<bool?>, bool?>((ref) {
  return ModelState<bool?>(ref, true);
});