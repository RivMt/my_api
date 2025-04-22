import 'dart:collection';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_api/core/api.dart';
import 'package:my_api/core/model/model.dart';


/// A stream notifier of model
class ModelStreamNotifier<T extends Model> extends StateNotifier<Set<T>> {

  /// Initialize instance
  ModelStreamNotifier() : super(LinkedHashSet<T>(
    equals: (a, b) => a.isEquivalent(b),
    hashCode: (a) => a.representativeCode,
  ));

  /// Current query string (Read-only)
  String get currentQuery => _query;

  /// Current query string
  String _query = "";

  /// Search about [query]
  ///
  /// If [query] is equal to [_query], method aborted.
  /// Results will be discarded if [currentQuery] is changed during async.
  Future<void> search(String query) async {
    if (query == currentQuery) {
      return;
    }
    _query = query;
    state = LinkedHashSet<T>(
      equals: (a, b) => a.isEquivalent(b),
      hashCode: (a) => a.representativeCode,
    );
    final response = await ApiClient().search<T>(query);
    await for (T item in response.data) {
      // Check current query string
      // because there is possibility of changing during async
      if (_query != query) return;
      state = {...state, item};
    }
  }
}