import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_api/core/api.dart';
import 'package:my_api/core/log.dart';
import 'package:my_api/core/model/model.dart';

class ModelsState<T extends Model> extends StateNotifier<List<T>> {

  static const String _tag = "ModelsState";

  ModelsState(this.ref) : super([]);

  final Ref ref;

  /// Clear state
  void clear() => state = [];

  /// Fetch [T] items fit to [condition] and filter by [options]
  ///
  /// This method overrides [state]
  Future<void> fetch([Map<String, dynamic>? queries]) async {
    final client = ApiClient();
    final ApiResponse<List<T>> response = await client.read<T>(queries);
    if (response.result != ApiResultCode.success) {
      Log.e(_tag, "Failed to fetch: $queries");
      state = [];
      return;
    }
    state = response.data;
  }

  /// Get [T] items fit to [condition] and filter by [options]
  ///
  /// This method append/update data to [state]
  Future<void> append(Map<String, dynamic>? queries) async {
    final client = ApiClient();
    final ApiResponse<List<T>> response = await client.read<T>(queries);
    if (response.result != ApiResultCode.success) {
      Log.e(_tag, "Failed to append: $queries");
      return;
    }
    // Apply fetched data
    final list = List<T>.from(state);
    for (T item in response.data) {
      final index = list.indexWhere((element) => element.isEquivalent(item));
      if (index < 0 || index >= list.length) {
        list.add(item);
      } else {
        list[index] = item;
      }
    }
    state = list;
  }

  /// Create [data] to server
  Future<bool> create(T data) async {
    final result = await ApiClient().create<T>(data.map);
    if (result.result != ApiResultCode.success) {
      Log.e(_tag, "Failed to create: ${data.map}");
      return false;
    }
    state = [...state, result.data];
    return true;
  }

  /// Update [data] to server
  Future<bool> update(T data) async {
    final result = await ApiClient().update<T>(data.map);
    if (result.result != ApiResultCode.success) {
      Log.e(_tag, "Failed to update: ${data.map}");
      return false;
    }
    final list = state;
    final index = list.indexWhere((element) => element.isEquivalent(data));
    if (index < 0) {
      Log.w(_tag, "Updated data does not included in state: $data");
    }
    list[index] = result.data;
    state = List.from(list);
    return true;
  }

  /// Delete [data] to server
  Future<bool> delete(T data) async {
    final result = await ApiClient().delete<T>(data.map);
    if (result.result != ApiResultCode.success) {
      Log.e(_tag, "Failed to update: ${data.map}");
      return false;
    }
    final list = state;
    final index = list.indexWhere((element) => element.isEquivalent(data));
    if (index < 0) {
      Log.w(_tag, "Updated data does not included in state: $data");
    }
    list.removeAt(index);
    state = List.from(list);
    return true;
  }

}

class ModelState<T> extends StateNotifier<T> {

  static const String _tag = "ModelState";

  ModelState(this.ref, this.unknown) : super(unknown);

  final Ref ref;

  final T unknown;

  /// Clear state
  void clear() => state = unknown;

  /// Fetch [T] item fit to [condition] and filter by [options]
  Future<void> fetch([Map<String, dynamic>? queries]) async {
    final client = ApiClient();
    final ApiResponse<List<T>> response = await client.read<T>(queries);
    if (response.result != ApiResultCode.success || response.data.isEmpty) {
      Log.e(_tag, "Failed to request: $queries");
      state = unknown;
      return;
    }
    state = response.data[0];
  }

  /// Set [state] directly
  void set(T value) => state = value;
}