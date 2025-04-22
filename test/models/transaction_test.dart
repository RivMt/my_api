import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_api/src/core/model/model_keys.dart';
import 'package:my_api/src/finance/model/currency.dart';
import 'package:my_api/src/finance/model/transaction.dart';

void main() {
  group("Property Test", () {
    test('Utility end to utility days conversion', () {
      final t = Transaction({});
      t.paidDate = DateTime(2022, 10, 1);
      t.utilityEnd = DateTime(2022, 10, 3);
      assert(t.utilityDays == 3);
    });
    test('Utility days to utility end conversion', () {
      final t = Transaction({});
      t.paidDate = DateTime(2022, 10, 1);
      t.utilityDays = 3;
      assert(DateTime(t.utilityEnd.year, t.utilityEnd.month, t.utilityEnd.day) == DateTime(2022, 10, 3));
    });
    test('Date', () {
      final t = Transaction();
      final local = DateTime(2001, 1, 1, 12, 30, 15);
      t.paidDate = local;
      assert(t.paidDate == DateTime(local.year, local.month, local.day));
    });
    test('DateTime', () {
      final t = Transaction();
      final local = DateTime(2001, 1, 1, 12, 30, 15);
      t.setDateTime(ModelKeys.keyLastUsed, local);
      assert(t.lastUsed == local);
    });
    test('UUID hashcode', () {
      final a = Transaction();
      final b = Transaction();
      a.map[ModelKeys.keyUuid] = "abc";
      b.map[ModelKeys.keyUuid] = "abc";
      assert(a.representativeCode == b.representativeCode);
      assert(a.isEquivalent(b));
    });
  });
  group("Amount Verification Test (Integer part only currency)", () {
    final data = Transaction({});
    String gen(length) {
      return List.generate(length, (index) => index%9+1).join("");
    }
    test('Extra integer part with no decimal part', () {
      final currency = Currency.instance(decimalPoint: 0);
      data.amount = Decimal.parse(
          gen(Transaction.maxIntegerPartDigits + 2)
      );
      expect(Transaction.getAmountRegex(currency).hasMatch(data.amount.toString()), false);
    });
    test('Extra integer part with extra decimal part', () {
      final currency = Currency.instance(decimalPoint: 0);
      data.amount = Decimal.parse(
          "${gen(Transaction.maxIntegerPartDigits + 2)}.${gen(Transaction.maxDecimalPartDigits + 2)}"
      );
      expect(Transaction.getAmountRegex(currency).hasMatch(data.amount.toString()), false);
    });
    test('Extra integer part with appropriate decimal part', () {
      final currency = Currency.instance(decimalPoint: 0);
      data.amount = Decimal.parse(
          "${gen(Transaction.maxIntegerPartDigits + 2)}.${gen(Transaction.maxDecimalPartDigits - 1)}"
      );
      expect(Transaction.getAmountRegex(currency).hasMatch(data.amount.toString()), false);
    });
    test('Appropriate integer part with no decimal part', () {
      final currency = Currency.instance(decimalPoint: 0);
      data.amount = Decimal.parse(
          gen(Transaction.maxIntegerPartDigits - 2)
      );
      expect(Transaction.getAmountRegex(currency).hasMatch(data.amount.toString()), true);
    });
    test('Appropriate integer part with extra decimal part', () {
      final currency = Currency.instance(decimalPoint: 0);
      data.amount = Decimal.parse(
          "${gen(Transaction.maxIntegerPartDigits - 2)}.${gen(Transaction.maxDecimalPartDigits + 2)}"
      );
      expect(Transaction.getAmountRegex(currency).hasMatch(data.amount.toString()), false);
    });
    test('Appropriate integer part with appropriate decimal part', () {
      final currency = Currency.instance(decimalPoint: 0);
      data.amount = Decimal.parse(
          "${gen(Transaction.maxIntegerPartDigits - 2)}.${gen(Transaction.maxDecimalPartDigits - 1)}"
      );
      expect(Transaction.getAmountRegex(currency).hasMatch(data.amount.toString()), false);
    });
  });
  group("Amount Verification Test (Integer part with decimal part currency)", () {
    final data = Transaction({});
    String gen(length) {
      return List.generate(length, (index) => index % 9 + 1).join("");
    }
    test('Extra integer part with no decimal part', () {
      final currency = Currency.unknown;
      data.amount = Decimal.parse(
          gen(Transaction.maxIntegerPartDigits + 2)
      );
      expect(Transaction.getAmountRegex(currency).hasMatch(data.amount.toString()), false);
    });
    test('Extra integer part with extra decimal part', () {
      final currency = Currency.instance(decimalPoint: 2);
      data.amount = Decimal.parse(
          "${gen(Transaction.maxIntegerPartDigits + 2)}.${gen(
              Transaction.maxDecimalPartDigits + 2)}"
      );
      expect(Transaction.getAmountRegex(currency).hasMatch(data.amount.toString()), false);
    });
    test('Extra integer part with appropriate decimal part', () {
      final currency = Currency.instance(decimalPoint: 2);
      data.amount = Decimal.parse(
          "${gen(Transaction.maxIntegerPartDigits + 2)}.${gen(
              Transaction.maxDecimalPartDigits - 1)}"
      );
      expect(Transaction.getAmountRegex(currency).hasMatch(data.amount.toString()), false);
    });
    test('Appropriate integer part with no decimal part', () {
      final currency = Currency.instance(decimalPoint: 2);
      data.amount = Decimal.parse(
          gen(Transaction.maxIntegerPartDigits - 2)
      );
      expect(Transaction.getAmountRegex(currency).hasMatch(data.amount.toString()), true);
    });
    test('Appropriate integer part with extra decimal part', () {
      final currency = Currency.instance(decimalPoint: 2);
      data.amount = Decimal.parse(
          "${gen(Transaction.maxIntegerPartDigits - 2)}.${gen(
              Transaction.maxDecimalPartDigits + 2)}"
      );
      expect(Transaction.getAmountRegex(currency).hasMatch(data.amount.toString()), false);
    });
    test('Appropriate integer part with appropriate decimal part', () {
      final currency = Currency.instance(decimalPoint: 2);
      data.amount = Decimal.parse(
          "${gen(Transaction.maxIntegerPartDigits - 2)}.${gen(
              Transaction.maxDecimalPartDigits - 1)}"
      );
      expect(Transaction.getAmountRegex(currency).hasMatch(data.amount.toString()), true);
    });
  });
}
