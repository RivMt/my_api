import 'package:decimal/decimal.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_api/core/api.dart';
import 'package:my_api/core/log.dart';

class CalculateValueState<T> extends StateNotifier<Decimal> {

  static const _tag = "CalculateValueState";

  CalculateValueState(this.ref, {
    required this.conditions,
    required this.type,
  }) : super(Decimal.zero);

  final Ref ref;

  final Map<String, dynamic> conditions;

  final CalculationType type;

  /// Clear state
  void clear() => state = Decimal.zero;

  /// Request [T] items fit to [conditions] and filter by [options]
  Future<void> request() async {
    final client = ApiClient();
    final ApiResponse<Map<String, Decimal>> response = await client.stat<T>(ApiQuery(conditions));
    if (response.result != ApiResultCode.success) {
      Log.e(_tag, "Failed to request $conditions");
      state = Decimal.parse("0");
      return;
    }
    state = response.data[type.key]!;
  }
}

enum CalculationType {
  sum("total"),
  average("average"),
  count("count");

  final String key;

  const CalculationType(this.key);

}