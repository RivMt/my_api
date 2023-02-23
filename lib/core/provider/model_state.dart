import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_api/core/api.dart';
import 'package:my_api/core/log.dart';

const String _tag = "ModelProvider";

class ModelsState<T> extends StateNotifier<List<T>> {

  ModelsState(this.ref) : super([]);

  final Ref ref;

  /// Clear state
  void clear() => state = [];

  /// Request [T] items fit to [condition] and filter by [options]
  Future<void> request(List<Map<String, dynamic>> condition, [Map<String, dynamic>? options]) async {
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

class ModelState<T> extends StateNotifier<T?> {

  ModelState(this.ref) : super(null);

  final Ref ref;

  /// Clear state
  void clear() => state = null;

  /// Request [T] items fit to [condition] and filter by [options]
  Future<void> request(Map<String, dynamic> condition, [Map<String, dynamic>? options]) async {
    final client = ApiClient();
    final ApiResponse<List<T>> response = await client.read<T>(
      [condition],
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