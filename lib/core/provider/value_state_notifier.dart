import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_api/core.dart';

class ValueStateNotifier<T> extends StateNotifier<T> {

  /// [StateNotifier] for value [T]
  ///
  /// [unknown] is default value.
  /// If you are looking for api related model state notifier, see [ModelState].
  ValueStateNotifier(this.ref, this.unknown) : super(unknown);

  final Ref ref;

  final T unknown;

  /// Clear state
  void clear() => state = unknown;

  /// Set [state] directly
  void set(T value) => state = value;
}