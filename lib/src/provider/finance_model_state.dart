import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_api/src/api/api_core.dart';
import 'package:my_api/src/api/api_client.dart';
import 'package:my_api/src/log.dart';

const String _tag = "FinanceProvider";

class FinanceModelState<T> extends StateNotifier<List<T>> {

  FinanceModelState(this.ref) : super([]);

  final Ref ref;

  /// Clear state
  void clear() => state = [];

  /// Request [T] items fit to [condition] and filter by [options]
  void request(Map<String, dynamic> condition, [Map<String, dynamic>? options]) async {
    final client = ApiClient();
    final ApiResponse<List<T>> response = await client.read<T>(
      condition,
      options,
    );
    if (response.result != ApiResultCode.success) {
      Log.e(_tag, "Failed to request $condition");
      state = [];
      return;
    }
    state = response.data;
  }
}

class FinanceModelDetailsState<T> extends StateNotifier<T?> {

  FinanceModelDetailsState(this.ref) : super(null);

  final Ref ref;

  /// Clear state
  void clear() => state = null;

  /// Request [T] items fit to [condition] and filter by [options]
  void request(Map<String, dynamic> condition, [Map<String, dynamic>? options]) async {
    final client = ApiClient();
    final ApiResponse<List<T>> response = await client.read<T>(
      condition,
      options,
    );
    if (response.result != ApiResultCode.success) {
      Log.e(_tag, "Failed to request $condition");
      state = null;
      return;
    }
    state = response.data[0];
  }
}