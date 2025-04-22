import 'package:decimal/decimal.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_api/core/api.dart';
import 'package:my_api/core/log.dart';
import 'package:my_api/core/model/model.dart';


/// A state notifier of calculated value
///
/// It is necessary to specify type to find API endpoint.
class CalculateValueStateNotifier<T extends Model> extends StateNotifier<Decimal> {

  static const _tag = "CalculateValueState";

  /// Initialize from [conditions] and [type]
  CalculateValueStateNotifier({
    required this.conditions,
    required this.type,
  }) : super(Decimal.zero);

  /// Query conditions
  final Map<String, dynamic> conditions;

  /// Type of calculation
  final CalculationType type;

  /// Clear value as zero
  void clear() => state = Decimal.zero;

  /// Requests calculated value with [conditions]
  Future<void> request() async {
    final client = ApiClient();
    final ApiResponse<Map<String, Decimal>> response = await client.stat<T>(ApiQuery(conditions));
    if (response.result != ApiResponseResult.success) {
      Log.e(_tag, "Failed to request $conditions");
      state = Decimal.zero;
      return;
    }
    state = response.data[type.key]!;
  }
}

/// Type of calculation
enum CalculationType {
  sum("total"),
  average("average"),
  count("count");

  /// Key of calculation
  final String key;

  const CalculationType(this.key);

}