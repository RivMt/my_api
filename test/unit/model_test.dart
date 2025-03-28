import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_api/core/model/preference.dart';
import 'package:my_api/core/model/preference_element.dart';
import 'package:my_api/core/model/preference_root.dart';
import 'package:my_api/finance/model/account.dart';
import 'package:my_api/finance/model/currency.dart';
import 'package:my_api/finance/model/payment.dart';
import 'package:my_api/finance/model/transaction.dart';

void main() {
  group("Account Test", () {
    test('Account BigInt copy identification', () {
      Account a = Account({});
      a.balance = Decimal.parse("1000");
      Account b = Account(a.map);
      expect(b.balance, a.balance);
    });
  });
  group("Payment Calculated Date Generation Test", () {
    const int year = 2020;
    Payment payment = Payment({});
    payment.isCredit = true;
    DateTime? date;

    test('First day to last day, a month before', () {
      payment.payBegin = PaymentRangePoint(1, Payment.payDayMin);
      payment.payEnd = PaymentRangePoint(1, Payment.payDayMax);
      payment.payDate = 14;
      date = payment.getCalculatedDate(DateTime(year, 10, 27));
      expect(date, DateTime(year, 11, payment.payDate));
      date = payment.getCalculatedDate(DateTime(year, 9, 3));
      expect(date, DateTime(year, 10, payment.payDate));
    });
    test('First day to last day, a month before (Feb)', () {
      payment.payBegin = PaymentRangePoint(1, Payment.payDayMin);
      payment.payEnd = PaymentRangePoint(1, Payment.payDayMax);
      payment.payDate = 30;
      date = payment.getCalculatedDate(DateTime(year, 1, 16));
      expect(date, DateTime(year, 2, 29));
      date = payment.getCalculatedDate(DateTime(year, 1, 31));
      expect(date, DateTime(year, 2, 29));
    });
    test('18th day of two month before to 17th day of a month before', () {
      payment.payBegin = PaymentRangePoint(2, 18);
      payment.payEnd = PaymentRangePoint(1, 17);
      payment.payDate = 27;
      date = payment.getCalculatedDate(DateTime(year, 10, 27));
      expect(date, DateTime(year, 12, payment.payDate));
      date = payment.getCalculatedDate(DateTime(year, 9, 3));
      expect(date, DateTime(year, 10, payment.payDate));
      date = payment.getCalculatedDate(DateTime(year, 2, 28));
      expect(date, DateTime(year, 4, payment.payDate));
      date = payment.getCalculatedDate(DateTime(year, 2, 29));
      expect(date, DateTime(year, 4, payment.payDate));
    });
    test('Last day of a month before to 29th day of current month', () {
      payment.payBegin = PaymentRangePoint(1, Payment.payDayMax);
      payment.payEnd = PaymentRangePoint(0, 29);
      payment.payDate = 30;
      date = payment.getCalculatedDate(DateTime(year, 8, 31));
      expect(date, DateTime(year, 9, payment.payDate));
      date = payment.getCalculatedDate(DateTime(year, 8, 29));
      expect(date, DateTime(year, 8, payment.payDate));
    });
  });
  group("Transaction", () {
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
  });
  group("Transaction Amount Verification Test (Integer part only currency)", () {
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
  group("Transaction Amount Verification Test (Integer part with decimal part currency)", () {
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
  // Preference
  group('Preferences Test', () {
    const key = "test";
    final root = PreferenceRoot("test");
    test('Integer', () {
      const value = 0;
      final PreferenceElement pref = PreferenceElement(parent: root, key: key, value: value);
      expect(pref.value, value);
    });
    test('String', () {
      const value = "TEST";
      final PreferenceElement pref = PreferenceElement(parent: root, key: key, value: value);
      expect(pref.value, value);
    });
    test('Decimal', () {
      final value = Decimal.parse("1.52");
      final PreferenceElement pref = PreferenceElement(parent: root, key: key, value: value);
      expect(pref.value, value);
    });
    test('double', () {
      const value = 0.5;
      final PreferenceElement pref = PreferenceElement(parent: root, key: key, value: value);
      expect(pref.value, value);
    });
    test('Bool', () {
      const value = false;
      final PreferenceElement pref = PreferenceElement(parent: root, key: key, value: value);
      expect(pref.value, value);
    });
    test('List', () {
      const value = ["A", "B", "C"];
      final PreferenceElement pref = PreferenceElement(parent: root, key: key, value: value);
      expect(pref.value, value);
    });
    test('Nested List', () {
      const value = [["A", 1, ["N!=1"]], "B", ",,,,,"];
      final PreferenceElement pref = PreferenceElement(parent: root, key: key, value: value);
      expect(pref.value, value);
    });
    test('Map', () {
      final value = {
        "A": 0,
        "B": Decimal.zero,
        "0": "Hi"
      };
      final PreferenceElement pref = PreferenceElement(parent: root, key: key, value: value);
      expect(pref.map, value);
    });
    test('Nested Map', () {
      final value = {
        "A": {
          "1": "one",
          "Two": 2,
          "Decimal.one": "Data"
        },
        "B": [1, 2, "::::"],
        "0": "Hi"
      };
      final PreferenceElement pref = PreferenceElement(parent: root, key: key, value: value);
      expect(pref.map, value);
    });
    test('Complex Structure', () {
      final value = {
        "M{I0:I1}": {0:1},
        "L[0,1]": [0,1],
        "M{L[0]:L[1]}": {[0]: [1]},
        "L[M{I0:I0}]": [{0:1}],
      };
      final PreferenceElement pref = PreferenceElement(parent: root, key: key, value: value);
      expect(pref.rawValue, Preference.encode(value));
    });
    test('DateTime', () {
      final value = DateTime.now();
      final PreferenceElement pref = PreferenceElement(parent: root, key: key, value: value);
      expect(pref.value.year, value.year);
      expect(pref.value.month, value.month);
      expect(pref.value.day, value.day);
      expect(pref.value.hour, value.hour);
      expect(pref.value.minute, value.minute);
      expect(pref.value.second, value.second);
      expect(pref.value.millisecond, value.millisecond);
      expect(pref.value.isUtc, value.isUtc);
    });
    test('Equality', () {
      const value = 0;
      final PreferenceElement a = PreferenceElement(parent: root, key: key, value: value);
      final PreferenceElement b = PreferenceElement(parent: root, key: key, value: value);
      expect(a, b);
    });
    test('Root conversion', () {
      final root = PreferenceRoot("abc");
      const raw = [
        {
          "section": "abc",
          "owner_id": "",
          "key": "key1",
          "value": "I0"
        }, {
          "section": "abc",
          "owner_id": "",
          "key": "key2",
          "value": "Btrue"
        }
      ];
      root.apply(raw);
      final children = [];
      for (var child in root.children) {
        children.add(child.rawValue);
      }
      expect(root.rawChildren(""), raw);
    });
  });
}
