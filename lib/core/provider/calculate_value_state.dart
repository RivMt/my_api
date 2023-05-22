import 'package:decimal/decimal.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_api/core/api.dart';
import 'package:my_api/core/log.dart';

class CalculateValueState<T> extends StateNotifier<Decimal> {

  static const _tag = "CalculateValueState";

  CalculateValueState(this.ref, {
    required this.conditions,
    required this.type,
    required this.attribute,
    this.queries,
  }) : super(Decimal.zero);

  final Ref ref;

  List<Map<String, dynamic>> conditions = [{}];

  final CalculationType type;

  final String attribute;

  Map<String, dynamic>? queries;

  /// Clear state
  void clear() => state = Decimal.zero;

  /// Request [T] items fit to [conditions] and filter by [options]
  Future<void> request() async {
    final client = ApiClient();
    final ApiResponse<Decimal> response = await client.calculate<T>(conditions, type, attribute, queries);
    if (response.result != ApiResultCode.success) {
      Log.e(_tag, "Failed to request $conditions");
      state = Decimal.parse("0");
      return;
    }
    state = response.data;
  }
}