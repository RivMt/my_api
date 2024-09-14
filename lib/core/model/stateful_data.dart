class StatefulDataState {

  StatefulDataState._(this.code, this.message);

  static StatefulDataState ready = StatefulDataState._(0, "");

  static StatefulDataState loading = StatefulDataState._(1, "");

  static error(String message) {
    return StatefulDataState._(2, message);
  }

  final int code;

  final String message;
}

class StatefulData<T> {

  final T data;

  final StatefulDataState state;

  const StatefulData(this.data, this.state);

}