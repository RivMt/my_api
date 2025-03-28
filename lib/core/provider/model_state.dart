import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_api/core/api.dart';
import 'package:my_api/core/log.dart';

const String _tag = "ModelProvider";

class ModelsState<T> extends StateNotifier<List<T>> {

  ModelsState(this.ref, this.endpoint) : super([]);

  final Ref ref;

  final String endpoint;

  /// Clear state
  void clear() => state = [];

  /// Request [T] items fit to [condition] and filter by [options]
  ///
  /// This method overrides [state]
  Future<void> request(Map<String, dynamic>? queries) async {
    final client = ApiClient();
    final ApiResponse<List<T>> response = await client.read<T>(endpoint, queries);
    if (response.result != ApiResultCode.success) {
      Log.e(_tag, "Failed to request $queries");
      state = [];
      return;
    }
    state = response.data;
  }

  /// Get [T] items fit to [condition] and filter by [options]
  ///
  /// This method append/update data to [state]
  Future<void> fetch(Map<String, dynamic>? queries) async {
    final client = ApiClient();
    final ApiResponse<List<T>> response = await client.read<T>(endpoint, queries);
    if (response.result != ApiResultCode.success) {
      Log.e(_tag, "Failed to request $queries");
      return;
    }
    // Apply fetched data
    final list = List<T>.from(state);
    for (T item in response.data) {
      int index = list.indexOf(item);
      if (index < 0 || index >= list.length) {
        list.add(item);
      } else {
        list[index] = item;
      }
    }
    state = list;
  }
}

class ModelState<T> extends StateNotifier<T> {

  ModelState(this.ref, this.endpoint, this.unknown) : super(unknown);

  final Ref ref;

  final String endpoint;

  final T unknown;

  /// Clear state
  void clear() => state = unknown;

  /// Request [T] item fit to [condition] and filter by [options]
  Future<void> request(Map<String, dynamic>? queries) async {
    final client = ApiClient();
    final ApiResponse<List<T>> response = await client.read<T>(endpoint, queries);
    if (response.result != ApiResultCode.success || response.data.isEmpty) {
      Log.e(_tag, "Failed to request $queries");
      state = unknown;
      return;
    }
    state = response.data[0];
  }

  /// Set [state] directly
  void set(T value) => state = value;
}