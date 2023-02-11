import 'package:decimal/decimal.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_api/core/api/api_core.dart';
import 'package:my_api/core/api/api_client.dart';
import 'package:my_api/core/log.dart';

class CalculateValueState<T> extends StateNotifier<Decimal> {

  static const _tag = "CalculateValueState";

  CalculateValueState(this.ref, {
    required this.conditions,
    required this.type,
    required this.attribute,
  }) : super(Decimal.zero);

  final Ref ref;

  List<Map<String, dynamic>> conditions = [{}];

  final CalculationType type;

  final String attribute;

  /// Clear state
  void clear() => state = Decimal.zero;

  /// Request [T] items fit to [conditions] and filter by [options]
  void request() async {
    final client = ApiClient();
    final ApiResponse<Decimal> response = await client.calculate<T>(conditions, type, attribute);
    if (response.result != ApiResultCode.success) {
      Log.e(_tag, "Failed to request $conditions");
      state = Decimal.parse("0");
      return;
    }
    state = response.data;
  }
}