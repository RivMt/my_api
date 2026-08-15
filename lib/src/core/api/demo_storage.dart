import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:my_api/src/core/model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A small local backend persisted with [SharedPreferences].
class DemoStorage {
  /// Creates demo storage.
  DemoStorage({SharedPreferences? preferences}) : _preferences = preferences;

  static const String _keyPrefix = "my_api.${User.demoId}.";
  static const String _defaultCurrencyId = "USD";
  static const String _accounts = "api/finance/accounts";
  static const String _categories = "api/finance/categories";
  static const String _currencies = "api/finance/currencies";
  static const String _payments = "api/finance/payments";
  static const String _transactions = "api/finance/transactions";
  static const String _preferencesEndpoint = "api/core/preferences";
  static int _idSequence = 0;

  static const List<String> _tables = [
    _accounts,
    _categories,
    _currencies,
    _payments,
    _transactions,
    _preferencesEndpoint,
  ];

  SharedPreferences? _preferences;

  SharedPreferences get _store {
    final store = _preferences;
    if (store == null) {
      throw StateError("DemoStorage is not initialized.");
    }
    return store;
  }

  /// Initializes the local storage.
  Future<void> init() async {
    _preferences ??= await SharedPreferences.getInstance();
  }

  /// Creates and persists an item for [endpoint].
  Future<Map<String, dynamic>> create(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final table = _table(endpoint);
    if (table == _currencies) {
      throw UnsupportedError("Demo currencies are read-only.");
    }
    if (table == _preferencesEndpoint) {
      return _setPreference(body);
    }

    final items = _readTable(table);
    final item = _withDefaults(table, body, isNew: true);
    items.add(item);
    await _writeTable(table, items);
    return _withComputedFields(table, item);
  }

  /// Reads items for [endpoint] using flattened API query parameters.
  Future<List<Map<String, dynamic>>> read(
    String endpoint, [
    Map<String, String>? query,
  ]) async {
    final table = _table(endpoint);
    final items = table == _currencies
        ? _currencyItems.map(Map<String, dynamic>.from).toList()
        : _readTable(table);
    final result = _filter(items, query ?? const {});
    _sort(result, query ?? const {});
    return result.map((item) => _withComputedFields(table, item)).toList();
  }

  /// Updates and persists an item for [endpoint].
  Future<Map<String, dynamic>> update(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final table = _table(endpoint);
    if (table == _currencies) {
      throw UnsupportedError("Demo currencies are read-only.");
    }
    if (table == _preferencesEndpoint) {
      return _setPreference(body);
    }

    final uuid = body["uuid"]?.toString();
    if (uuid == null || uuid.isEmpty) {
      throw ArgumentError.value(uuid, "uuid", "UUID is required.");
    }
    final items = _readTable(table);
    final index = items.indexWhere((item) => item["uuid"] == uuid);
    if (index < 0) {
      throw StateError("No item with UUID $uuid.");
    }
    final item = _withDefaults(
      table,
      {...items[index], ...body},
      isNew: false,
    );
    items[index] = item;
    await _writeTable(table, items);
    return _withComputedFields(table, item);
  }

  /// Deletes and returns the item identified in [endpoint].
  Future<Map<String, dynamic>> delete(String endpoint) async {
    final table = _table(endpoint);
    final id = _itemId(endpoint, table);
    if (id == null || id.isEmpty) {
      throw ArgumentError("The endpoint does not contain an item ID.");
    }
    final items = _readTable(table);
    final index = items.indexWhere((item) => item["uuid"] == id);
    if (index < 0) {
      throw StateError("No item with UUID $id.");
    }
    final item = items.removeAt(index);
    await _writeTable(table, items);
    return _withComputedFields(table, item);
  }

  /// Calculates transaction values using the same filters as [read].
  Future<Map<String, dynamic>> stats(
    String endpoint, [
    Map<String, String>? query,
  ]) async {
    final table = _table(endpoint);
    if (table != _transactions) {
      throw UnsupportedError("Statistics are only available for transactions.");
    }
    final items = _filter(_readTable(table), query ?? const {});
    final values = items.map((item) => _decimal(item["amount"])).toList();
    final total = values.fold<Decimal>(
      Decimal.zero,
      (sum, value) => sum + value,
    );
    final average =
        values.isEmpty ? 0.0 : double.parse(total.toString()) / values.length;
    return {
      "total": total.toString(),
      "average": average.toStringAsFixed(2),
      "count": values.length.toString(),
    };
  }

  /// Searches transactions and related wallet/category text fields.
  Future<List<Map<String, dynamic>>> search(
    String endpoint,
    String query,
  ) async {
    final table = _table(endpoint);
    if (table != _transactions) {
      throw UnsupportedError("Search is only available for transactions.");
    }
    final accounts = _indexByUuid(_readTable(_accounts));
    final payments = _indexByUuid(_readTable(_payments));
    final categories = _indexByUuid(_readTable(_categories));
    final terms = query
        .split(",")
        .map((term) => term.trim().toLowerCase())
        .where((term) => term.isNotEmpty)
        .toList();

    final result = _readTable(_transactions).where((item) {
      if (item["deleted"] == true) {
        return false;
      }
      final related = [
        accounts[item["account_id"]],
        payments[item["payment_id"]],
        categories[item["category_id"]],
      ].whereType<Map<String, dynamic>>();
      final text = [
        ...item.values,
        ...related.expand((entry) => [entry["name"], entry["description"]]),
      ].join(" ").toLowerCase();
      return terms.every(text.contains);
    }).toList();
    result.sort((a, b) => _compare(b["paid_date"], a["paid_date"]));
    return result;
  }

  /// Removes all demo backend data.
  Future<void> clear() async {
    for (final table in _tables) {
      await _store.remove(_storageKey(table));
    }
  }

  String _table(String endpoint) {
    final normalized = endpoint.replaceAll(RegExp(r"^/+|/+$"), "");
    return _tables.firstWhere(
      (table) => normalized == table || normalized.startsWith("$table/"),
      orElse: () => throw UnsupportedError("Unknown demo endpoint: $endpoint"),
    );
  }

  String? _itemId(String endpoint, String table) {
    final normalized = endpoint.replaceAll(RegExp(r"^/+|/+$"), "");
    if (normalized.length <= table.length) {
      return null;
    }
    return normalized.substring(table.length + 1).split("/").first;
  }

  String _storageKey(String table) => "$_keyPrefix$table";

  List<Map<String, dynamic>> _readTable(String table) {
    final raw = _store.getString(_storageKey(table));
    if (raw == null || raw.isEmpty) {
      return [];
    }
    return (json.decode(raw) as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  Future<void> _writeTable(
    String table,
    List<Map<String, dynamic>> items,
  ) async {
    await _store.setString(_storageKey(table), json.encode(items));
  }

  Future<Map<String, dynamic>> _setPreference(
    Map<String, dynamic> body,
  ) async {
    final item = {
      "section": body["section"] ?? "",
      "owner_id": body["owner_id"] ?? User.demoId,
      "pref_key": body["pref_key"] ?? "",
      "pref_value": body["pref_value"] ?? "",
    };
    final items = _readTable(_preferencesEndpoint);
    final index = items.indexWhere(
      (entry) =>
          entry["section"] == item["section"] &&
          entry["owner_id"] == item["owner_id"] &&
          entry["pref_key"] == item["pref_key"],
    );
    if (index < 0) {
      items.add(item);
    } else {
      items[index] = item;
    }
    await _writeTable(_preferencesEndpoint, items);
    return item;
  }

  Map<String, dynamic> _withDefaults(
    String table,
    Map<String, dynamic> source, {
    required bool isNew,
  }) {
    final now = DateTime.now().toIso8601String();
    final item = Map<String, dynamic>.from(source);
    if (isNew) {
      item["uuid"] = _newUuid();
    }
    item["last_used"] = now;
    item["owner_id"] ??= User.demoId;
    item["editors_id"] ??= <String>[];
    item["viewers_id"] ??= <String>[];
    item["deleted"] ??= false;
    item["name"] ??= "";
    item["description"] ??= "";

    if (table == _accounts || table == _payments) {
      item["icon"] ??= 0;
      item["priority"] ??= 0;
      item["limitation"] ??= "0";
      item["currency_id"] ??= _defaultCurrencyId;
      item["serial_number"] ??= "";
      item["foreground"] ??= -1;
      item["background"] ??= -16777216;
    }
    if (table == _accounts) {
      item["is_cash"] ??= true;
      if (isNew) {
        item["balance"] = "0";
      }
    } else if (table == _payments) {
      item["is_credit"] ??= false;
      item["pay_begin"] ??= 101;
      item["pay_end"] ??= 130;
      item["pay_date"] ??= 14;
    } else if (table == _categories) {
      item["type"] ??= 0;
      item["included"] ??= true;
      item["icon"] ??= 0;
    } else if (table == _transactions) {
      final today = now.substring(0, 10);
      item["paid_date"] ??= today;
      item["calculated_date"] ??= today;
      item["type"] ??= 0;
      item["account_id"] ??= "-1";
      item["payment_id"] ??= "-1";
      item["category_id"] ??= "-1";
      item["currency_id"] ??= _defaultCurrencyId;
      item["amount"] ??= "0";
      item["included"] ??= false;
    }
    return item;
  }

  Map<String, dynamic> _withComputedFields(
    String table,
    Map<String, dynamic> source,
  ) {
    final item = Map<String, dynamic>.from(source);
    if (table == _accounts) {
      item["balance"] = _accountBalance(item["uuid"]?.toString());
    }
    return item;
  }

  String _accountBalance(String? uuid) {
    var total = Decimal.zero;
    final now = DateTime.now();
    for (final transaction in _readTable(_transactions)) {
      if (transaction["account_id"]?.toString() != uuid ||
          transaction["deleted"] == true) {
        continue;
      }
      final calculated = DateTime.tryParse(
        transaction["calculated_date"]?.toString() ?? "",
      );
      if (calculated != null && calculated.isAfter(now)) {
        continue;
      }
      final amount = _decimal(transaction["amount"]);
      total += transaction["type"].toString() == "1" ? amount : -amount;
    }
    return total.toString();
  }

  List<Map<String, dynamic>> _filter(
    List<Map<String, dynamic>> items,
    Map<String, String> query,
  ) {
    return items.where((item) {
      for (final entry in query.entries) {
        final key = entry.key;
        if (key == "sort_field" || key == "sort_order" || key == "q") {
          continue;
        }
        if (key.startsWith("begin_")) {
          final field = key.substring("begin_".length);
          if (!_atLeast(item[field], entry.value)) {
            return false;
          }
        } else if (key.startsWith("end_")) {
          final field = key.substring("end_".length);
          if (!_atMost(item[field], entry.value)) {
            return false;
          }
        } else if (key != "begin" &&
            key != "end" &&
            !_equals(item[key], entry.value)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  void _sort(List<Map<String, dynamic>> items, Map<String, String> query) {
    final fields = query["sort_field"]?.split(",") ?? const [];
    final orders = query["sort_order"]?.split(",") ?? const [];
    if (fields.isEmpty) {
      return;
    }
    items.sort((a, b) {
      for (var index = 0; index < fields.length; index++) {
        final comparison = _compare(a[fields[index]], b[fields[index]]);
        if (comparison != 0) {
          final descending =
              index < orders.length && orders[index].toLowerCase() == "desc";
          return descending ? -comparison : comparison;
        }
      }
      return 0;
    });
  }

  bool _equals(dynamic value, String expected) {
    if (value is bool) {
      return value == (expected.toLowerCase() == "true");
    }
    if (value is num) {
      return value == num.tryParse(expected);
    }
    return value?.toString() == expected;
  }

  bool _atLeast(dynamic value, String lower) => _compare(value, lower) >= 0;

  bool _atMost(dynamic value, String upper) => _compare(value, upper) <= 0;

  int _compare(dynamic left, dynamic right) {
    if (left == null && right == null) {
      return 0;
    }
    if (left == null) {
      return -1;
    }
    if (right == null) {
      return 1;
    }
    final leftNumber = num.tryParse(left.toString());
    final rightNumber = num.tryParse(right.toString());
    if (leftNumber != null && rightNumber != null) {
      return leftNumber.compareTo(rightNumber);
    }
    final leftDate = DateTime.tryParse(left.toString());
    final rightDate = DateTime.tryParse(right.toString());
    if (leftDate != null && rightDate != null) {
      return leftDate.compareTo(rightDate);
    }
    if (left is bool && right is bool) {
      return (left ? 1 : 0).compareTo(right ? 1 : 0);
    }
    return left.toString().compareTo(right.toString());
  }

  Decimal _decimal(dynamic value) {
    try {
      return Decimal.parse(value?.toString() ?? "0");
    } on FormatException {
      return Decimal.zero;
    }
  }

  Map<String, Map<String, dynamic>> _indexByUuid(
    List<Map<String, dynamic>> items,
  ) =>
      {
        for (final item in items)
          if (item["uuid"] != null) item["uuid"].toString(): item,
      };

  String _newUuid() =>
      "${User.demoId}-${DateTime.now().microsecondsSinceEpoch}-${_idSequence++}";

  static const List<Map<String, dynamic>> _currencyItems = [
    {
      "uuid": _defaultCurrencyId,
      "region_code": "US",
      "currency_code": "D",
      "symbol": "\$",
      "icon_url": "",
      "decimal_point": 2
    },
  ];
}
