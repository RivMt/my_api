import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_api/core.dart';


/// A value state notifier
///
/// If [T] is subclass of [Model], use [ModelStateNotifier] instead.
class ValueStateNotifier<T> extends StateNotifier<T> {

  /// Initialize
  ValueStateNotifier(this.unknown) : super(unknown);

  /// Default value of type [T]
  final T unknown;

  /// Clear state as [unknown]
  void clear() => state = unknown;

  /// Set [state] as [value]
  void set(T value) => state = value;
}