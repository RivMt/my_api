import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_api/src/core/model/model_keys.dart';
import 'package:my_api/src/finance/model/category.dart';
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
      assert(
          DateTime(t.utilityEnd.year, t.utilityEnd.month, t.utilityEnd.day) ==
              DateTime(2022, 10, 3));
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
      t.setDateTime(ModelKeys.keyModifiedAt, local);
      assert(t.modifiedAt == local);
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
  group("Primary and secondary amount Test", () {
    Transaction transaction({required String categoryId}) {
      final data = Transaction({});
      data.categoryId = categoryId;
      data.currencyId = "USD";
      data.amount = Decimal.fromInt(10);
      data.altCurrencyId = "JPY";
      data.altAmount = Decimal.fromInt(1500);
      return data;
    }

    test("Alternative amount is primary for a regular transaction", () {
      final data = transaction(categoryId: "regular-category");

      expect(data.hasAlt, isTrue);
      expect(data.primaryCurrencyId, "JPY");
      expect(data.primaryAmount, Decimal.fromInt(1500));
      expect(data.secondaryCurrencyId, "USD");
      expect(data.secondaryAmount, Decimal.fromInt(10));
    });

    for (final category in [Category.transferTo, Category.transferFrom]) {
      test("Alternative amount is secondary for transfer ${category.uuid}", () {
        final data = transaction(categoryId: category.uuid);

        expect(data.isTransfer, isTrue);
        expect(data.hasAlt, isTrue);
        expect(data.primaryCurrencyId, "USD");
        expect(data.primaryAmount, Decimal.fromInt(10));
        expect(data.secondaryCurrencyId, "JPY");
        expect(data.secondaryAmount, Decimal.fromInt(1500));
      });
    }

    test("Original amount is primary without an alternative", () {
      final data = transaction(categoryId: "regular-category");
      data.altCurrencyId = Currency.unknownUuid;
      data.altAmount = Decimal.zero;

      expect(data.primaryCurrencyId, "USD");
      expect(data.primaryAmount, Decimal.fromInt(10));
      expect(data.secondaryCurrencyId, Currency.unknownUuid);
      expect(data.secondaryAmount, Decimal.zero);
    });

    test("Transfer has no alternative when both currencies are equal", () {
      final data = transaction(categoryId: Category.transferTo.uuid);
      data.altCurrencyId = data.currencyId;

      expect(data.hasAlt, isFalse);
    });

    test("Regular transaction keeps alternative with equal currencies", () {
      final data = transaction(categoryId: "regular-category");
      data.altCurrencyId = data.currencyId;

      expect(data.hasAlt, isTrue);
    });
  });
  group("Amount Verification Test (Integer part only currency)", () {
    final data = Transaction({});
    String gen(length) {
      return List.generate(length, (index) => index % 9 + 1).join("");
    }

    test('Extra integer part with no decimal part', () {
      final currency = Currency.instance(decimalPoint: 0);
      data.amount = Decimal.parse(gen(Transaction.maxIntegerPartDigits + 2));
      expect(
          Transaction.getAmountRegex(currency).hasMatch(data.amount.toString()),
          false);
    });
    test('Extra integer part with extra decimal part', () {
      final currency = Currency.instance(decimalPoint: 0);
      data.amount = Decimal.parse(
          "${gen(Transaction.maxIntegerPartDigits + 2)}.${gen(Transaction.maxDecimalPartDigits + 2)}");
      expect(
          Transaction.getAmountRegex(currency).hasMatch(data.amount.toString()),
          false);
    });
    test('Extra integer part with appropriate decimal part', () {
      final currency = Currency.instance(decimalPoint: 0);
      data.amount = Decimal.parse(
          "${gen(Transaction.maxIntegerPartDigits + 2)}.${gen(Transaction.maxDecimalPartDigits - 1)}");
      expect(
          Transaction.getAmountRegex(currency).hasMatch(data.amount.toString()),
          false);
    });
    test('Appropriate integer part with no decimal part', () {
      final currency = Currency.instance(decimalPoint: 0);
      data.amount = Decimal.parse(gen(Transaction.maxIntegerPartDigits - 2));
      expect(
          Transaction.getAmountRegex(currency).hasMatch(data.amount.toString()),
          true);
    });
    test('Appropriate integer part with extra decimal part', () {
      final currency = Currency.instance(decimalPoint: 0);
      data.amount = Decimal.parse(
          "${gen(Transaction.maxIntegerPartDigits - 2)}.${gen(Transaction.maxDecimalPartDigits + 2)}");
      expect(
          Transaction.getAmountRegex(currency).hasMatch(data.amount.toString()),
          false);
    });
    test('Appropriate integer part with appropriate decimal part', () {
      final currency = Currency.instance(decimalPoint: 0);
      data.amount = Decimal.parse(
          "${gen(Transaction.maxIntegerPartDigits - 2)}.${gen(Transaction.maxDecimalPartDigits - 1)}");
      expect(
          Transaction.getAmountRegex(currency).hasMatch(data.amount.toString()),
          false);
    });
  });
  group("Amount Verification Test (Integer part with decimal part currency)",
      () {
    final data = Transaction({});
    String gen(length) {
      return List.generate(length, (index) => index % 9 + 1).join("");
    }

    test('Extra integer part with no decimal part', () {
      final currency = Currency.unknown;
      data.amount = Decimal.parse(gen(Transaction.maxIntegerPartDigits + 2));
      expect(
          Transaction.getAmountRegex(currency).hasMatch(data.amount.toString()),
          false);
    });
    test('Extra integer part with extra decimal part', () {
      final currency = Currency.instance(decimalPoint: 2);
      data.amount = Decimal.parse(
          "${gen(Transaction.maxIntegerPartDigits + 2)}.${gen(Transaction.maxDecimalPartDigits + 2)}");
      expect(
          Transaction.getAmountRegex(currency).hasMatch(data.amount.toString()),
          false);
    });
    test('Extra integer part with appropriate decimal part', () {
      final currency = Currency.instance(decimalPoint: 2);
      data.amount = Decimal.parse(
          "${gen(Transaction.maxIntegerPartDigits + 2)}.${gen(Transaction.maxDecimalPartDigits - 1)}");
      expect(
          Transaction.getAmountRegex(currency).hasMatch(data.amount.toString()),
          false);
    });
    test('Appropriate integer part with no decimal part', () {
      final currency = Currency.instance(decimalPoint: 2);
      data.amount = Decimal.parse(gen(Transaction.maxIntegerPartDigits - 2));
      expect(
          Transaction.getAmountRegex(currency).hasMatch(data.amount.toString()),
          true);
    });
    test('Appropriate integer part with extra decimal part', () {
      final currency = Currency.instance(decimalPoint: 2);
      data.amount = Decimal.parse(
          "${gen(Transaction.maxIntegerPartDigits - 2)}.${gen(Transaction.maxDecimalPartDigits + 2)}");
      expect(
          Transaction.getAmountRegex(currency).hasMatch(data.amount.toString()),
          false);
    });
    test('Appropriate integer part with appropriate decimal part', () {
      final currency = Currency.instance(decimalPoint: 2);
      data.amount = Decimal.parse(
          "${gen(Transaction.maxIntegerPartDigits - 2)}.${gen(Transaction.maxDecimalPartDigits - 1)}");
      expect(
          Transaction.getAmountRegex(currency).hasMatch(data.amount.toString()),
          true);
    });
  });
}
