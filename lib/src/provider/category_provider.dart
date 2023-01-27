import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_api/src/api/api_core.dart';
import 'package:my_api/src/api/finance_client.dart';
import 'package:my_api/src/model/category.dart';
import 'package:my_api/src/model/transaction.dart';

class CategoryProvider {

  static final CategoryProvider _instance = CategoryProvider._();

  factory CategoryProvider() => _instance;

  CategoryProvider._();

  /// State of categories which type is [TransactionType.expense]
  final categoryExpenseState = StateNotifierProvider<CategoryState, Map<int, Category>>((ref) {
    return CategoryState(TransactionType.expense);
  });

  /// State of categories which type is [TransactionType.income]
  final categoryIncomeState = StateNotifierProvider<CategoryState, Map<int, Category>>((ref) {
    return CategoryState(TransactionType.income);
  });

  /// Request categories
  void update(WidgetRef ref, TransactionType type) async {
    final client = FinanceClient();
    final ApiResponse<List<Category>> response = await client.readCategories({});
    // If api request failed, return
    if (response.result != ApiResultCode.success) {
      return;
    }
    // Clear previous data
    ref.read(categoryExpenseState.notifier).clear();
    ref.read(categoryIncomeState.notifier).clear();
    // Append data
    for(Category category in response.data) {
      if (category.type == TransactionType.expense) {
        ref.read(categoryExpenseState.notifier).append(category);
      } else {
        ref.read(categoryIncomeState.notifier).append(category);
      }
    }
  }

  /// List of categories which type is [TransactionType.expense]
  Map<int, Category> expenses(WidgetRef ref) {
    return ref.watch(categoryExpenseState);
  }

  /// List of categories which type is [TransactionType.income]
  Map<int, Category> incomes(WidgetRef ref) {
    return ref.watch(categoryIncomeState);
  }

}

class CategoryState extends StateNotifier<Map<int, Category>> {
  CategoryState(this.type) : super({});

  /// Type of transaction
  final TransactionType type;

  /// Clear the category
  void clear() => state = {};

  /// Update [list] as [state]
  void update(Map<int, Category> map) => state = map;

  /// Append [category] to [state]
  void append(Category category) => state[category.pid] = category;

}