library my_api;
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
  int get payBegin => getValue(keyPayBegin, payDayMin);

  set payBegin(int value) {
    final list = [payDayMin, value, payDayMax];
    list.sort();
    map[keyPayBegin] = list[1];
  }

  /// End day of range when this payment paid
  int get payEnd => getValue(keyPayEnd, payDayMax);

  set payEnd(int value) {
    final list = [payDayMin, value, payDayMax];
    list.sort();
    map[keyPayEnd] = list[1];
  }

  /// Date of this payment paid on current month
  int get payDate => getValue(keyPayDate, 14);

  set payDate(int value) {
    final list = [payDayMin, value, payDayMax];
    list.sort();
    map[keyPayDate] = list[1];
  }

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