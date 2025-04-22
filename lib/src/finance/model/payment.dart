library my_api;

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:my_api/src/core/model/base_model.dart';
import 'package:my_api/src/core/model/model_keys.dart';
import 'package:my_api/src/finance/model/currency.dart';
import 'package:my_api/src/finance/model/wallet_item.dart';

/// A payment handler class
///
/// Distinct to other models, payment has two default instance [unknown] and [none].
/// [unknown] is same role of any other models, however, [none] is somewhat different.
/// If an user defined a transaction does not have payment, [none] is plausible.
class Payment extends WalletItem {

  /// Path of API server endpoint
  static const String endpoint = "api/finance/payments";

  /// UUID of none payment
  static const String noneUuid = "0";

  /// Minimum day of payment day
  static const int payDayMin = 1;

  /// Maximum day of payment day
  ///
  /// 31th day is regarded as 30th
  static const int payDayMax = 30;

  /// Unknown payment instance
  static final Payment unknown = Payment({
    ModelKeys.keyUuid: BaseModel.unknownUuid,
    ModelKeys.keyCurrencyId: Currency.unknownUuid,
  });

  /// No payment
  static final Payment none = Payment({
    ModelKeys.keyUuid: noneUuid,
    ModelKeys.keyCurrencyId: Currency.unknownUuid,
  });

  /// Initialize payment from given [map]
  Payment(super.map);

  /// Whether this payment is valid or not
  bool get isValid {
    // Pid
    if (uuid == BaseModel.unknownUuid) {
      return false;
    }
    // Description
    if (name.isEmpty) {
      return false;
    }
    // Currency
    if (currencyId == Currency.unknownUuid) {
      return false;
    }
    // Pay range
    if (isCredit) {
      if (payEnd < payBegin ||
          (payBegin.month - payEnd.month > 0 && payBegin.day != payEnd.day + 1) ||
          (payEnd.month == 0 && payDate <= payEnd.day) ||
          (payBegin.month == payEnd.month && (payBegin.day != payDayMin || payEnd.day != payDayMax))) {
        return false;
      }
    }
    // Otherwise
    return true;
  }

  /// Whether this payment handles credit transaction or not
  ///
  /// Default value is `false`.
  bool get isCredit => getBool(ModelKeys.keyIsCredit, false);

  set isCredit(bool value) => setBool(ModelKeys.keyIsCredit, value);

  /// Icon of this payment
  ///
  /// Default value is [PaymentSymbol.card]
  PaymentSymbol get icon => PaymentSymbol.fromId(getInt(ModelKeys.keyIcon, PaymentSymbol.card.id));

  set icon(PaymentSymbol icon) => setInt(ModelKeys.keyIcon, icon.id);

  /// Beginning day of range for each payment period
  ///
  /// Default value is [PaymentRangePoint.defaultBegin].
  PaymentRangePoint get payBegin => PaymentRangePoint.fromCode(getInt(ModelKeys.keyPayBegin, PaymentRangePoint.defaultBegin.code));

  set payBegin(PaymentRangePoint point) => setInt(ModelKeys.keyPayBegin, point.code);

  /// End day of range for each payment period
  ///
  /// Default value is [PaymentRangePoint.defaultEnd].
  PaymentRangePoint get payEnd => PaymentRangePoint.fromCode(getInt(ModelKeys.keyPayEnd, PaymentRangePoint.defaultEnd.code));

  set payEnd(PaymentRangePoint point) => setInt(ModelKeys.keyPayEnd, point.code);

  /// Withdrawal date of each payment period
  ///
  /// Default value is `14`.
  int get payDate => getInt(ModelKeys.keyPayDate, 14);

  set payDate(int value) {
    final list = [payDayMin, value, payDayMax];
    list.sort();
    setInt(ModelKeys.keyPayDate, list[1]);
  }

  /// Gets withdrawal date of the transaction based on given [paidDate]
  ///
  /// If [isCredit] is `false`, returns [paidDate].
  ///
  /// This method calculates [DateTime] in LOCAL time. If you want UTC time,
  /// you must call `toUtc` returned value.
  DateTime getCalculatedDate(DateTime paidDate) {
    // Check is credit
    if (!isCredit) {
      return paidDate;
    }
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

  @override
  String toString() => "$name (${isCredit ? '${payBegin.code}-${payEnd.code}/$payDate' : 'now' })";

}

/// A point of payment range
class PaymentRangePoint {

  /// Default beginning point
  static final defaultBegin = PaymentRangePoint(1, Payment.payDayMin);

  /// Default end point
  static final defaultEnd = PaymentRangePoint(1, Payment.payDayMax);

  /// Initialize a point from given [month] and [day]
  ///
  /// [month] must be bigger than or equal to `0`, otherwise it will be `0`.
  /// And [day] must be bigger than or equal to [Payment.payDayMin] and
  /// smaller than or equal to [Payment.payDayMax].
  PaymentRangePoint(int month, int day) {
    this.month = max(month, 0);
    final days = [Payment.payDayMin, day, Payment.payDayMax];
    days.sort();
    this.day = days[1];
  }

  /// Initialize a point from given [code]
  ///
  /// [month] will be quotient of value which divide [code] by `100`.
  /// [day] will be remainder of value which divide [code] by `100`.
  PaymentRangePoint.fromCode(int code) {
    month = code ~/ 100;
    day = code % 100;
  }

  /// How many months before
  ///
  /// `0` means current month, and `1` is last month. Of course `100` means 100
  /// months before.
  late final int month;

  /// Day of [month]
  ///
  /// `1` means first day of month. [Payment.payDayMax] means last day of month.
  /// 31st day is assumed as `30`th because some month does not have that day.
  late final int day;

  /// Code of this point
  ///
  /// The value is `month*100+day`.
  int get code => month * 100 + day;

  /// Compare this and other [PaymentRangePoint]
  ///
  /// If returned value is `0`, this and [other] is exactly same point.
  /// And the value is bigger than `0`, this is after (more future) than [other].
  /// Otherwise, value is smaller than `0`, this is before (more past) than [other].
  ///
  /// Also, absolute value of the returned is how many days between this and [other].
  /// For example, this is `101` and the other is `102`, `-1` will be returned.
  ///
  /// This method asserts one month is **ALWAYS** 30 days.
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

/// A symbol of payment
enum PaymentSymbol {
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

  /// Initialize instance
  const PaymentSymbol(this.id, this.icon);

  /// Unique value of this symbol
  final int id;

  /// [IconData] of this symbol
  final IconData icon;

  /// Find corresponding symbol from given [id]
  ///
  /// Default value is [PaymentSymbol.card].
  factory PaymentSymbol.fromId(int id) {
    // Check id
    if (id < 0 || id >= PaymentSymbol.values.length) {
      return PaymentSymbol.card;
    }
    return PaymentSymbol.values[id];
  }

  /// Key for localization
  String get key {
    return "paymentType${name.substring(0,1).toUpperCase()}${name.substring(1,name.length)}";
  }

}