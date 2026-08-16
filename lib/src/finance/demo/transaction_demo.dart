import 'package:my_api/src/core/model/model_keys.dart';

/// Aligns demo transaction dates to the month containing [now].
///
/// Invalid or missing dates are preserved. Days beyond the end of the target
/// month are clamped to its final day.
List<Map<String, dynamic>> alignDemoTransactionDates(
  List<Map<String, dynamic>> transactions, {
  DateTime? now,
}) {
  final target = now ?? DateTime.now();
  return transactions.map((source) {
    final transaction = Map<String, dynamic>.from(source);
    for (final key in [
      ModelKeys.keyPaidDate,
      ModelKeys.keyCalculatedDate,
    ]) {
      final date = DateTime.tryParse(transaction[key]?.toString() ?? "");
      if (date == null) {
        continue;
      }
      final lastDay = DateTime(target.year, target.month + 1, 0).day;
      final day = date.day > lastDay ? lastDay : date.day;
      transaction[key] = _date(DateTime(target.year, target.month, day));
    }
    return transaction;
  }).toList();
}

String _date(DateTime value) => "${value.year.toString().padLeft(4, '0')}-"
    "${value.month.toString().padLeft(2, '0')}-"
    "${value.day.toString().padLeft(2, '0')}";
