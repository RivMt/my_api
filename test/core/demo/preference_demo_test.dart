import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_api/core.dart';

void main() {
  test('aligns target balances to the current month end', () {
    final source = [
      {
        ModelKeys.keyPreferenceKey: PreferenceKeys.defaultCurrency,
        ModelKeys.keyPreferenceValue: Preference.encode('USD'),
      },
      {
        ModelKeys.keyPreferenceKey: PreferenceKeys.targetBalance,
        ModelKeys.keyPreferenceValue: Preference.encode({
          'USD': {
            '2024-12-31T00:00:00.000': Decimal.parse('3000'),
          },
        }),
      },
    ];

    final result = alignDemoTargetBalanceDates(
      source,
      now: DateTime(2028, 2, 10),
    );
    final targets = Preference.decode(
      result.last[ModelKeys.keyPreferenceValue],
    ) as Map;
    final usdTargets = targets['USD'] as Map;

    expect(usdTargets.keys.single, '2028-02-29T00:00:00.000');
    expect(usdTargets.values.single, Decimal.parse('3000'));
    expect(
      Preference.decode(result.first[ModelKeys.keyPreferenceValue]),
      'USD',
    );
    expect(
      Preference.decode(source.last[ModelKeys.keyPreferenceValue]!).toString(),
      contains('2024-12-31'),
    );
  });
}
