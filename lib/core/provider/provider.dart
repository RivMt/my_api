import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_api/core/api.dart';
import 'package:my_api/core/model/model_keys.dart';
import 'package:my_api/core/provider/model_state.dart';
import 'package:my_api/finance/model/account.dart';
import 'package:my_api/finance/model/category.dart';
import 'package:my_api/finance/model/currency.dart';
import 'package:my_api/finance/model/payment.dart';
import 'package:my_api/finance/model/transaction.dart';

final accounts = StateNotifierProvider<ModelsState<Account>, List<Account>>((ref) {
  return ModelsState<Account>(ref);
});

final filteredAccounts = Provider<List<Account>>((ref) {
  final min = ref.watch(minPriorityFilter);
  final max = ref.watch(maxPriorityFilter);
  final sort = ref.watch(sortFilter);
  final list = ref.watch(accounts);
  List<Account> result = list
      .where((account) => (account.priority >= min && account.priority <= max)).toList();
  if (Account.unknown.map.containsKey(sort)) {
    result.sort((a1, a2) =>
        (a1.map[sort] as Comparable).compareTo(a2.map[sort]));
  }
  return result;
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

final filteredPayments = Provider<List<Payment>>((ref) {
  final min = ref.watch(minPriorityFilter);
  final max = ref.watch(maxPriorityFilter);
  final sort = ref.watch(sortFilter);
  final list = ref.watch(payments);
  List<Payment> result = list
      .where((payment) => (payment.priority >= min && payment.priority <= max)).toList();
  if ( Payment.unknown.map.containsKey(sort)) {
    result.sort((a1, a2) =>
        (a1.map[sort] as Comparable).compareTo(a2.map[sort]));
  }
  return result;
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

final categories = StateNotifierProvider<ModelsState<Category>, List<Category>>((ref) {
  return ModelsState<Category>(ref);
});

final filteredCategories = Provider<List<Category>>((ref) {
  final type = ref.watch(transactionTypeFilter);
  final isIncluded = ref.watch(transactionIncludedFilter);
  List<Category> list = ref.watch(categories);
  if (type != TransactionType.unknown) {
    list = list.where((category) => category.type == type).toList();
  }
  if (isIncluded != null) {
    list = list.where((category) => category.isIncluded == isIncluded).toList();
  }
  return list;
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