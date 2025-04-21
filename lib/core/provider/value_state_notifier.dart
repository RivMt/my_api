import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_api/core.dart';


/// A value state notifier
///
/// If [T] is subclass of [Model], use [ModelState] instead.
class ValueStateNotifier<T> extends StateNotifier<T> {

  /// Initialize
  ValueStateNotifier(this.ref, this.unknown) : super(unknown);

  final Ref ref;  // TODO: remove

  /// Default value of type [T]
  final T unknown;

  /// Clear state as [unknown]
  void clear() => state = unknown;

  /// Set [state] as [value]
  void set(T value) => state = value;
}