import 'package:my_api/src/core/model/model_keys.dart';
import 'package:my_api/src/core/model/preference.dart';
import 'package:my_api/src/core/model/preference_keys.dart';

/// Aligns demo target-balance dates to the end of the month containing [now].
///
/// Other preference entries are preserved. Each currency retains its configured
/// amount and receives one target date for the selected month.
List<Map<String, dynamic>> alignDemoTargetBalanceDates(
  List<Map<String, dynamic>> preferences, {
  DateTime? now,
}) {
  final target = now ?? DateTime.now();
  final monthEnd = DateTime(target.year, target.month + 1, 0);
  final targetDate = monthEnd.toIso8601String();

  return preferences.map((source) {
    final item = Map<String, dynamic>.from(source);
    if (item[ModelKeys.keyPreferenceKey] != PreferenceKeys.targetBalance) {
      return item;
    }
    final rawValue = item[ModelKeys.keyPreferenceValue];
    if (rawValue is! String) {
      return item;
    }
    final decoded = Preference.decode(rawValue);
    if (decoded is! Map) {
      return item;
    }

    final aligned = <String, dynamic>{};
    for (final entry in decoded.entries) {
      final balances = entry.value;
      if (balances is Map && balances.isNotEmpty) {
        aligned[entry.key.toString()] = {targetDate: balances.values.last};
      } else {
        aligned[entry.key.toString()] = balances;
      }
    }
    item[ModelKeys.keyPreferenceValue] = Preference.encode(aligned);
    return item;
  }).toList();
}
