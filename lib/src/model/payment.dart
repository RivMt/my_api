library my_api;

import 'dart:math';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:my_api/src/model/currency.dart';
import 'package:my_api/src/model/model.dart';

class Payment extends FinanceModel {

  static const String keyViewers = "viewers";
  static const String keyIcon = "icon";
  static const String keyPriority = "priority";
  static const String keyLimitation = "limitation";
  static const String keyIsCredit = "is_credit";
  static const String keyCurrency = "currency";
  static const String keySerialNumber = "serial_number";
  static const String keyForeground = "foreground";
  static const String keyBackground = "background";
  static const String keyPayBegin = "keyPayBegin";
  static const String keyPayEnd = "keyPayEnd";
  static const String keyPayDate = "keyPayDate";

  /// Minimum day of payment day
  static const int payDayMin = 1;

  /// Maximum day of payment day
  ///
  /// 31th day is regarded as 30th
  static const int payDayMax = 30;

  /// Unknown payment
  static final Payment unknown = Payment({});

  Payment(super.map);

  /// List of viewers id
  List<String> get viewers => getValue(keyViewers, []);

  set viewers(List<String> list) => map[keyViewers] = list;

  /// Index of icon
  PaymentIcon get icon => PaymentIcon.fromId(getValue(keyIcon, PaymentIcon.card.id));

  set icon(PaymentIcon icon) => map[keyIcon] = icon.id;

  /// Priority
  ///
  /// Default value is `0`
  int get priority => getValue(keyPriority, 0);

  set priority(int value) => map[keyPriority] = value;

  /// Limitation of this account
  Decimal get limitation => Decimal.parse(getValue(keyLimitation, "0"));

  set limitation(Decimal value) => map[keyLimitation] = value.toString();

  /// Is this account handled as cash or not
  bool get isCredit => getValue(keyIsCredit, false);

  set isCredit(bool value) => map[keyIsCredit] = value;

  /// Currency of this payment
  Currency get currency => Currency.fromValue(getValue(keyCurrency, Currency.unknown.value));

  set currency(Currency currency) => map[keyCurrency] = currency.value;

  /// Serial number
  String get serialNumber => getValue(keySerialNumber, "");

  set serialNumber(String value) => map[keySerialNumber] = value;

  /// Foreground color
  Color get foreground => Color(getValue(keyForeground, Colors.white.value));

  set foreground(Color color) => map[keyForeground] = color.value;

  /// Background color
  Color get background => Color(getValue(keyBackground, Colors.black.value));

  set background(Color color) => map[keyBackground] = color.value;

  /// Beginning day of range when this payment paid
  PaymentRangePoint get payBegin => PaymentRangePoint.fromCode(getValue(keyPayBegin, PaymentRangePoint.defaultBegin.code));

  set payBegin(PaymentRangePoint point) => map[keyPayBegin] = point.code;

  /// End day of range when this payment paid
  PaymentRangePoint get payEnd => PaymentRangePoint.fromCode(getValue(keyPayEnd, PaymentRangePoint.defaultEnd.code));

  set payEnd(PaymentRangePoint point) => map[keyPayEnd] = point.code;

  /// Date of this payment paid on current month
  int get payDate => getValue(keyPayDate, 14);

  set payDate(int value) {
    final list = [payDayMin, value, payDayMax];
    list.sort();
    map[keyPayDate] = list[1];
  }

  /// Get date which transaction will be calculated from [paidDate]
  DateTime getCalculatedDate(DateTime paidDate) {
    // Month
    late int delta;
    if (payBegin.month == payEnd.month) {
      assert(payBegin.day <= payEnd.day);
      delta = payBegin.month;
    } else {
      assert(payBegin.month > payEnd.month);
      final int day = min(paidDate.day, payDayMax);
      final last = DateTime(paidDate.year, paidDate.month + 1, 0); // Last day of paidDate' month
      assert(payBegin.day > payEnd.day);
      if (payBegin.day <= day && day <= last.day) {
        delta = payBegin.month;
      } else if (day >= 1 && day <= payEnd.day) {
        delta = payEnd.month;
      }
    }
    // Day
    final int last = DateTime(paidDate.year, paidDate.month + delta + 1, 0).day;
    // Return
    return DateTime(paidDate.year, paidDate.month + delta, min(payDate, last));
  }

}

class PaymentRangePoint {

  static final defaultBegin = PaymentRangePoint(1, Payment.payDayMin);

  static final defaultEnd = PaymentRangePoint(1, Payment.payDayMax);

  /// Point of payment range
  ///
  /// [month] must be bigger than or equal to `0`, otherwise it will be `0`.
  /// And [day] must be bigger than or equal to [Payment.payDayMin] - `1` and
  /// smaller than or equal to [Payment.payDayMax].
  PaymentRangePoint(int month, int day) {
    this.month = max(month, 0);
    final days = [Payment.payDayMin, day, Payment.payDayMax];
    days.sort();
    this.day = days[1];
  }

  /// Point of payment range
  ///
  /// [month] is quotient of value which divide [code] by `100`.
  /// [day] is remainder of value which divide [code] by `100`.
  PaymentRangePoint.fromCode(int code) {
    month = code ~/ 100;
    day = code % 100;
  }

  /// How many months before
  ///
  /// `0` means current month, and `1` is last month. Of course `100` means 100
  /// months before
  late final int month;

  /// Day
  ///
  /// `1` means first day of month. [Payment.payDayMax] means last day of month.
  late final int day;

  /// Code
  ///
  /// This is value which is saved at DB.
  int get code => month * 100 + day;

  /// Compare this and other [PaymentRangePoint]
  ///
  /// If returned value is `0`, this and [other] is exactly same point.
  /// And value is bigger than `0`, this is after (more future) than [other].
  /// Finally, value is smaller than `0`, this is before (more past) than [other].
  ///
  /// Also, absolute value of returned is how many days between this and [other].
  /// This method asserts one month is **ALWAYS 30 days**.
  int compareTo(PaymentRangePoint other) {
    if (month > other.month) {
      return ((Payment.payDayMax - day + 1) + other.day) * -1;
    } else if (month < other.month) {
      return (day + (Payment.payDayMax - other.day + 1));
    } else {
      if (day < other.day) {
        return (other.day - day + 1) * -1;
      } else if (day > other.day) {
        return day - other.day + 1;
      } else {
        return 0;
      }
    }
  }

  @override
  int get hashCode => code;

  @override
  bool operator ==(Object other) {
    if (other is PaymentRangePoint) {
      return compareTo(other) == 0;
    }
    return super==(other);
  }

  bool operator <(PaymentRangePoint other) => compareTo(other) < 0;

  bool operator <=(PaymentRangePoint other) => compareTo(other) <= 0;

  bool operator >=(PaymentRangePoint other) => compareTo(other) >= 0;

  bool operator >(PaymentRangePoint other) => compareTo(other) > 0;
}

enum PaymentIcon {
  card(0, Icons.credit_card),
  cash(1, Icons.money),
  point(2, Icons.card_giftcard_rounded),
  transportation(3, Icons.train_outlined),
  membership(4, Icons.card_membership),
  transfer(5, Icons.swap_horiz_outlined),
  market(6, Icons.local_mall_outlined),
  prepaid(7, Icons.local_atm),
  mileage(8, Icons.flight_outlined),
  toll(9, Icons.toll_outlined);


  const PaymentIcon(this.id, this.icon);

  /// Unique value
  final int id;

  /// [IconData]
  final IconData icon;

  factory PaymentIcon.fromId(int id) {
    // Check id
    if (id < 0 || id >= PaymentIcon.values.length) {
      return PaymentIcon.card;
    }
    return PaymentIcon.values[id];
  }

  /// Key for localization
  String get key {
    return "paymentType${name.substring(0,1).toUpperCase()}${name.substring(1,name.length)}";
  }

}