import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_api/core/api.dart';
import 'package:my_api/core/log.dart';
import 'package:my_api/core/model/model.dart';

// TODO: Separate two classes

/// A state of model list
class ModelsState<T extends Model> extends StateNotifier<List<T>> {  // TODO: rename

  static const String _tag = "ModelsState";

  /// Initialize state notifier
  ModelsState(this.ref) : super([]);  // TODO: remove ref

  final Ref ref;

  /// Clear state as empty list
  void clear() => state = [];

  /// Fetch [T] items with [query]
  ///
  /// This method set [state] as new response. If there is a necessary to append
  /// items to current state, use [append].
  Future<void> fetch([Map<String, dynamic>? query]) async {
    final client = ApiClient();
    final ApiResponse<List<T>> response = await client.read<T>(query);
    if (response.result != ApiResultCode.success) {
      Log.e(_tag, "Failed to fetch: $query");
      state = [];
      return;
    }
    state = response.data;
  }

  /// Append [T] items with [query]
  ///
  /// This method append/update data of [state]. If there is a necessary to reset
  /// [state] as response, use [fetch].
  Future<void> append(Map<String, dynamic>? query) async {
    final client = ApiClient();
    final ApiResponse<List<T>> response = await client.read<T>(query);
    if (response.result != ApiResultCode.success) {
      Log.e(_tag, "Failed to append: $query");
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
    state = List<T>.from(list);
  }

  /// Create [data] and returns value whether success or not
  Future<bool> create(T data) async {
    final result = await ApiClient().create<T>(data.map);
    if (result.result != ApiResultCode.success) {
      Log.e(_tag, "Failed to create: ${data.map}");
      return false;
    }
    state = [...state, result.data];
    return true;
  }

  /// Update [data] and returns value whether success or not
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

  /// Delete [data] and returns value whether success or not
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

/// A single model state notifier
class ModelState<T> extends StateNotifier<T> {  // TODO: rename, inherit value state notifier

  static const String _tag = "ModelState";

  /// Initialize instance
  ///
  /// [unknown] is default value of [state] when [clear] called.
  ModelState(this.ref, this.unknown) : super(unknown);

  final Ref ref;  // TODO: remove ref

  /// Default value of [T]
  final T unknown;

  /// Clear state as [unknown]
  void clear() => state = unknown;

  /// Fetch [T] item with [query]
  Future<void> fetch([Map<String, dynamic>? query]) async {
    final client = ApiClient();
    final ApiResponse<List<T>> response = await client.read<T>(query);
    if (response.result != ApiResultCode.success || response.data.isEmpty) {
      Log.e(_tag, "Failed to request: $query");
      state = unknown;
      return;
    }
    state = response.data[0];
  }

  /// Set [state] as [value] directly
  void set(T value) => state = value;  // TODO: check this is necessary
}