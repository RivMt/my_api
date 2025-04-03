import 'dart:collection';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_api/core/api.dart';
import 'package:my_api/core/model/model.dart';

class ModelStreamNotifier<T extends Model> extends StateNotifier<Set<T>> {
  ModelStreamNotifier(this.ref) : super(LinkedHashSet<T>(
    equals: (a, b) => a.isEquivalent(b),
    hashCode: (a) => a.representativeCode,
  ));

  final Ref ref;

  String get currentQuery => _query;

  String _query = "";

  Future<void> search(String query) async {
    if (query == _query) {
      return;
    }
    _query = query;
    state = LinkedHashSet<T>(
      equals: (a, b) => a.isEquivalent(b),
      hashCode: (a) => a.representativeCode,
    );
    final response = await ApiClient().search<T>(query);
    await for (T item in response.data) {
      if (_query != query) return;
      state = {...state, item};
    }
  }
}