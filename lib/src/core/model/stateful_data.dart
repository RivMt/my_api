/// A level of [StatefulDataState]
enum StatefulDataStateLevel {
  ready(0),
  loading(1),
  error(2);

  final int level;

  const StatefulDataStateLevel(this.level);

}

/// A state of stateful data
class StatefulDataState {

  /// Initialize from [code] and [message]
  StatefulDataState._(this.code, this.message);

  /// State ready
  static StatefulDataState ready = StatefulDataState._(StatefulDataStateLevel.ready, "");

  /// State loading
  static StatefulDataState loading = StatefulDataState._(StatefulDataStateLevel.loading, "");

  /// State error with [message]
  static error(String message) {
    return StatefulDataState._(StatefulDataStateLevel.error, message);
  }

  /// Level of this state
  final StatefulDataStateLevel code;

  final String message;
}

/// A data with state
///
/// It is recommended to specify type
class StatefulData<T> {

  /// Date with type [T]
  final T data;

  /// State of this data
  final StatefulDataState state;

  /// Initialize from [data] and [state]
  const StatefulData(this.data, this.state);

  @override
  String toString() => "$data (${state.code.name})";

  @override
  int get hashCode => data.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is StatefulData) {
      return data==other.data;
    }
    return super==(other);
  }
}