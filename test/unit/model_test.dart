import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_api/src/model/account.dart';
import 'package:my_api/src/model/payment.dart';

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
}
