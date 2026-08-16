import 'package:flutter_test/flutter_test.dart';
import 'package:my_api/finance.dart';

void main() {
  test('aligns transaction dates to the current month', () {
    final source = [
      {
        'paid_date': '2024-01-31',
        'calculated_date': '2024-01-15',
      },
      {
        'paid_date': 'invalid',
      },
    ];

    final result = alignDemoTransactionDates(
      source,
      now: DateTime(2026, 2, 10),
    );

    expect(result.first['paid_date'], '2026-02-28');
    expect(result.first['calculated_date'], '2026-02-15');
    expect(result.last['paid_date'], 'invalid');
    expect(source.first['paid_date'], '2024-01-31');
  });
}
