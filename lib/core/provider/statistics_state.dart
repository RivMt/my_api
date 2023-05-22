import 'package:decimal/decimal.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_api/core/api.dart';
import 'package:my_api/core/provider/calculate_value_state.dart';

class StatisticsState<T, V> extends StateNotifier<Map<T, Decimal>> {

  final Ref ref;

  List<T> _keys = [];

  String _attribute = "";

  List<Map<String, dynamic>> _conditions = [];

  List<CalculateValueState<V>> _states = [];

  StatisticsState(this.ref) : super({});

  /// Update condition
  Future<void> updateCondition({
    required List<T> keys,
    required String attribute,
    required List<Map<String, dynamic>> conditions,
    required Map<String, dynamic> Function(Map<String, dynamic>, T) addCondition,
  }) async {
    _keys = keys;
    _attribute = attribute;
    _conditions = conditions;
    _states = [];
    for(int i=0; i < keys.length; i++) {
      final cons = _conditions;
      for(int j=0; j < cons.length; j++) {
        cons[j] = addCondition(cons[j], keys[i]);
      }
      _states.add(CalculateValueState(ref,
        conditions: cons,
        type: CalculationType.sum,
        attribute: _attribute,
      ));
    }
  }

  /// Clear
  void clear() => state = {};

  /// Request data using [conditions]
  Future<void> request() async {
    clear();
    for(int i=0; i < _keys.length; i++) {
      await _states[i].request();
      final T item = _keys[i];
      state[item] = _states[i].state;
    }
  }

}