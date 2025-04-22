import 'package:my_api/core/api.dart';
import 'package:my_api/core/log.dart';
import 'package:my_api/core/model/model.dart';
import 'package:my_api/core/notifier/value_state_notifier.dart';

/// A single model state notifier
class ModelStateNotifier<T extends Model> extends ValueStateNotifier<T> {

  static const String _tag = "ModelState";

  /// Initialize instance
  ///
  /// [unknown] is default value of [state] when [clear] called.
  ModelStateNotifier(super.unknown);

  /// Fetch [T] item with [query]
  Future<void> fetch([Map<String, dynamic>? query]) async {
    final client = ApiClient();
    final ApiResponse<List<T>> response = await client.read<T>(query);
    if (response.result != ApiResponseResult.success || response.data.isEmpty) {
      Log.e(_tag, "Failed to request: $query");
      state = unknown;
      return;
    }
    state = response.data[0];
  }
}