enum StatefulDataStateLevel {
  ready(0),
  loading(1),
  error(2);

  final int level;

  const StatefulDataStateLevel(this.level);

}

class StatefulDataState {

  StatefulDataState._(this.code, this.message);

  static StatefulDataState ready = StatefulDataState._(StatefulDataStateLevel.ready, "");

  static StatefulDataState loading = StatefulDataState._(StatefulDataStateLevel.loading, "");

  static error(String message) {
    return StatefulDataState._(StatefulDataStateLevel.error, message);
  }

  final StatefulDataStateLevel code;

  final String message;
}

class StatefulData<T> {

  final T data;

  final StatefulDataState state;

  const StatefulData(this.data, this.state);

}