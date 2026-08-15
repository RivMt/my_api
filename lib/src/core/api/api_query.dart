/// A query parameter.
class ApiQuery {
  /// Key of sort fields.
  static const String keySortField = "sort_field";

  /// Key of sort orders.
  static const String keySortOrder = "sort_order";

  /// Key of query range begin.
  static const String keyQueryRangeBegin = "begin";

  /// Key of query range end.
  static const String keyQueryRangeEnd = "end";

  /// Key of search query.
  static const String keyQueryString = "q";

  final Map<String, dynamic>? conditions; // TODO: remove

  /// Initialize.
  const ApiQuery(this.conditions);

  /// Query parameters.
  Map<String, String> get params {
    if (conditions == null) {
      return {};
    }
    final Map<String, String> result = {};
    for (String key in conditions!.keys) {
      final value = conditions![key];
      if (value is List) {
        result[key] = value
            .map((item) => item.toString())
            .toList(growable: false)
            .join(",");
      } else if (value is Map<String, dynamic>) {
        for (String subkey in value.keys) {
          result["${subkey}_$key"] = value[subkey].toString();
        }
      } else {
        result[key] = value.toString();
      }
    }
    return result;
  }
}
