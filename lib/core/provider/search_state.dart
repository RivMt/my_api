import 'dart:convert';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_api/core/api.dart';
import 'package:my_api/core/log.dart';

const String _tag = "SearchProvider";

// TODO: T extends SearchModel
class SearchState<T> extends StateNotifier<List<T>> {

  SearchState(this.ref) : super([]);

  final Ref ref;

  /// Clear state
  void clear() => state = [];

  /// Request [SearchResult] items searching by [query]
  void request(String query) async {
    final client = ApiClient();
    final text = base64Encode(utf8.encode(query));
    Log.v(_tag, "Search: $query ($text)");
    final ApiResponse<List<T>> response = await client.read<T>(
      [{}],
      {},
      {
        "query": text,
      },
    );
    if (response.result != ApiResultCode.success) {
      Log.e(_tag, "Failed to request $query");
      state = [];
      return;
    }
    state = response.data;
  }
}