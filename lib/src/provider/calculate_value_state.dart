import 'package:decimal/decimal.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_api/src/api/api_core.dart';
import 'package:my_api/src/api/api_client.dart';
import 'package:my_api/src/log.dart';

class CalculateValueState<T> extends StateNotifier<Decimal> {

  static const _tag = "CalculateValueState";

  CalculateValueState(this.ref, {
    required this.condition,
    required this.type,
    required this.attribute,
  }) : super(Decimal.parse("0"));

  final Ref ref;

  Map<String, dynamic> condition;

  final CalculationType type;

  final String attribute;

  /// Clear state
  void clear() => state = Decimal.parse("0");

  /// Request [T] items fit to [condition] and filter by [options]
  void request(Map<String, dynamic> condition, [Map<String, dynamic>? options]) async {
    final client = ApiClient();
    final ApiResponse<Decimal> response = await client.calculate<T>(condition, type, attribute);
    if (response.result != ApiResultCode.success) {
      Log.e(_tag, "Failed to request $condition");
      state = Decimal.parse("0");
      return;
    }
    state = response.data;
  }
}